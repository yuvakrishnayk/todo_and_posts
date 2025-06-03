import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUsers extends UserEvent {}

class LoadUserDetails extends UserEvent {
  final int userId;

  const LoadUserDetails(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserPosts extends UserEvent {
  final int userId;

  const LoadUserPosts(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserTodos extends UserEvent {
  final int userId;

  const LoadUserTodos(this.userId);

  @override
  List<Object> get props => [userId];
}

class RefreshUsers extends UserEvent {}
