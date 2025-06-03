import 'package:equatable/equatable.dart';

abstract class UserDetailsEvent extends Equatable {
  const UserDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserDetailsEvent extends UserDetailsEvent {
  final int userId;

  const FetchUserDetailsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshUserDetailsEvent extends UserDetailsEvent {
  final int userId;

  const RefreshUserDetailsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddTodoEvent extends UserDetailsEvent {
  final int userId;

  const AddTodoEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ToggleTodoEvent extends UserDetailsEvent {
  final int index;
  final bool value;

  const ToggleTodoEvent({required this.index, required this.value});

  @override
  List<Object?> get props => [index, value];
}

class EditTodoEvent extends UserDetailsEvent {
  final int index;
  final String newTitle;

  const EditTodoEvent({required this.index, required this.newTitle});

  @override
  List<Object?> get props => [index, newTitle];
}
