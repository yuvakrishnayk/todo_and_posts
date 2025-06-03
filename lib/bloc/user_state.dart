import 'package:equatable/equatable.dart';
import '../models/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<User> users;

  const UsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class UserDetailLoaded extends UserState {
  final User user;

  const UserDetailLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserPostsLoaded extends UserState {
  final List<Map<String, dynamic>> posts;
  final int userId;

  const UserPostsLoaded(this.posts, this.userId);

  @override
  List<Object> get props => [posts, userId];
}

class UserTodosLoaded extends UserState {
  final List<Map<String, dynamic>> todos;
  final int userId;

  const UserTodosLoaded(this.todos, this.userId);

  @override
  List<Object> get props => [todos, userId];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}
