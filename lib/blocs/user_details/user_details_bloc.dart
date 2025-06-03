import 'package:assignment/screens/create_post_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'user_details_event.dart';
import 'user_details_state.dart';

class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  final ApiService apiService;

  UserDetailsBloc({required this.apiService}) : super(UserDetailsInitial()) {
    on<FetchUserDetailsEvent>(_onFetchUserDetails);
    on<RefreshUserDetailsEvent>(_onRefreshUserDetails);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<EditTodoEvent>(_onEditTodo);
  }

  Future<void> _onFetchUserDetails(
    FetchUserDetailsEvent event,
    Emitter<UserDetailsState> emit,
  ) async {
    emit(UserDetailsLoading());
    try {
      final postsData = await apiService.getUserPosts(event.userId);
      final todosData = await apiService.getUserTodos(event.userId);

      // Get local posts for this user
      final localPosts =
          PostRepository.posts
              .where((post) => post['userId'] == event.userId)
              .toList();

      final posts = [
        ...List<Map<String, dynamic>>.from(postsData['posts'] ?? []),
        ...localPosts,
      ];
      final todos = List<Map<String, dynamic>>.from(todosData['todos'] ?? []);

      if (state is UserDetailsLoaded) {
        final currentState = state as UserDetailsLoaded;
        emit(currentState.copyWith(posts: posts, todos: todos));
      }
    } catch (e) {
      emit(UserDetailsError(e.toString()));
    }
  }

  Future<void> _onRefreshUserDetails(
    RefreshUserDetailsEvent event,
    Emitter<UserDetailsState> emit,
  ) async {
    try {
      final postsData = await apiService.getUserPosts(event.userId);
      final todosData = await apiService.getUserTodos(event.userId);

      // Get local posts for this user
      final localPosts =
          PostRepository.posts
              .where((post) => post['userId'] == event.userId)
              .toList();

      final posts = [
        ...List<Map<String, dynamic>>.from(postsData['posts'] ?? []),
        ...localPosts,
      ];
      final todos = List<Map<String, dynamic>>.from(todosData['todos'] ?? []);

      if (state is UserDetailsLoaded) {
        final currentState = state as UserDetailsLoaded;
        emit(currentState.copyWith(posts: posts, todos: todos));
      }
    } catch (e) {
      emit(UserDetailsError(e.toString()));
    }
  }

  void _onAddTodo(AddTodoEvent event, Emitter<UserDetailsState> emit) {
    if (state is UserDetailsLoaded) {
      final currentState = state as UserDetailsLoaded;
      final updatedTodos = List<Map<String, dynamic>>.from(currentState.todos)
        ..add({'todo': 'New Todo', 'completed': false});
      emit(currentState.copyWith(todos: updatedTodos));
    }
  }

  void _onToggleTodo(ToggleTodoEvent event, Emitter<UserDetailsState> emit) {
    if (state is UserDetailsLoaded) {
      final currentState = state as UserDetailsLoaded;
      final updatedTodos = List<Map<String, dynamic>>.from(currentState.todos);
      updatedTodos[event.index]['completed'] = event.value;
      emit(currentState.copyWith(todos: updatedTodos));
    }
  }

  void _onEditTodo(EditTodoEvent event, Emitter<UserDetailsState> emit) {
    if (state is UserDetailsLoaded) {
      final currentState = state as UserDetailsLoaded;
      final updatedTodos = List<Map<String, dynamic>>.from(currentState.todos);
      updatedTodos[event.index]['todo'] = event.newTitle;
      emit(currentState.copyWith(todos: updatedTodos));
    }
  }
}
