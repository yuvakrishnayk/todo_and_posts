import 'dart:convert';
import 'package:assignment/bloc/user_event.dart';
import 'package:assignment/bloc/user_state.dart';
import 'package:assignment/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;


class UserBloc extends Bloc<UserEvent, UserState> {
  final ApiService apiService;
  int currentPage = 1;

  UserBloc({required this.apiService}) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadUserDetails>(_onLoadUserDetails);
    on<RefreshUsers>(_onRefreshUsers);
    on<LoadUserPosts>(_onLoadUserPosts);
    on<LoadUserTodos>(_onLoadUserTodos);
  }
  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final users = await apiService.getUsers(currentPage);
      emit(UsersLoaded(users));
      // Increment page for the next load
      currentPage++;
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLoadUserDetails(
    LoadUserDetails event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());
      // We don't have a getUser(id) method in the API service,
      // so for now let's use dummy data or get users and filter
      final users = await apiService.getUsers(1);
      final user = users.firstWhere(
        (user) => user.id == event.userId,
        orElse: () => throw Exception('User not found'),
      );
      emit(UserDetailLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onRefreshUsers(
    RefreshUsers event,
    Emitter<UserState> emit,
  ) async {
    currentPage = 1;
    try {
      emit(UserLoading());
      final users = await apiService.getUsers(currentPage);
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLoadUserPosts(
    LoadUserPosts event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());
      final response = await http.get(
        Uri.parse('https://dummyjson.com/posts/user/${event.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = List<Map<String, dynamic>>.from(data['posts']);
        emit(UserPostsLoaded(posts, event.userId));
      } else {
        emit(UserError('Failed to load posts: ${response.statusCode}'));
      }
    } catch (e) {
      emit(UserError('Error loading posts: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUserTodos(
    LoadUserTodos event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());
      final response = await http.get(
        Uri.parse('https://dummyjson.com/todos/user/${event.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final todos = List<Map<String, dynamic>>.from(data['todos']);
        emit(UserTodosLoaded(todos, event.userId));
      } else {
        emit(UserError('Failed to load todos: ${response.statusCode}'));
      }
    } catch (e) {
      emit(UserError('Error loading todos: ${e.toString()}'));
    }
  }
}
