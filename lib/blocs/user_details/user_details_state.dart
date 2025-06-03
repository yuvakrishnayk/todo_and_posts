import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class UserDetailsState extends Equatable {
  const UserDetailsState();

  @override
  List<Object?> get props => [];
}

class UserDetailsInitial extends UserDetailsState {}

class UserDetailsLoading extends UserDetailsState {}

class UserDetailsError extends UserDetailsState {
  final String message;

  const UserDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserDetailsLoaded extends UserDetailsState {
  final User user;
  final List<Map<String, dynamic>> posts;
  final List<Map<String, dynamic>> todos;

  const UserDetailsLoaded({
    required this.user,
    required this.posts,
    required this.todos,
  });

  UserDetailsLoaded copyWith({
    User? user,
    List<Map<String, dynamic>>? posts,
    List<Map<String, dynamic>>? todos,
  }) {
    return UserDetailsLoaded(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      todos: todos ?? this.todos,
    );
  }

  @override
  List<Object?> get props => [user, posts, todos];
}
