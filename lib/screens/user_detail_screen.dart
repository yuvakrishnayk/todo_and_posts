// screens/user_detail_screen.dart
import 'package:assignment/screens/create_post_screen.dart';
import 'package:assignment/screens/full_user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user_details/user_details_bloc.dart';
import '../blocs/user_details/user_details_event.dart';
import '../blocs/user_details/user_details_state.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late final UserDetailsBloc _userDetailsBloc;

  @override
  void initState() {
    super.initState();
    _userDetailsBloc = UserDetailsBloc(apiService: ApiService())
      ..add(FetchUserDetailsEvent(userId: widget.user.id));
  }

  @override
  void dispose() {
    _userDetailsBloc.close();
    super.dispose();
  }

  void _navigateToUserDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullUserDetailScreen(user: widget.user),
      ),
    );
  }

  Future<void> _onRefresh() async {
    _userDetailsBloc.add(RefreshUserDetailsEvent(userId: widget.user.id));
  }

  void _editTodoTitle(int index) async {
    if (_userDetailsBloc.state is! UserDetailsLoaded) return;

    final state = _userDetailsBloc.state as UserDetailsLoaded;
    final controller = TextEditingController(text: state.todos[index]['todo']);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Todo'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Todo Description'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (result != null && result.trim().isNotEmpty) {
      _userDetailsBloc.add(
        EditTodoEvent(index: index, newTitle: result.trim()),
      );
    }
  }

  void _addTodo() {
    _userDetailsBloc.add(AddTodoEvent(userId: widget.user.id));
  }

  void _toggleTodo(int index, bool? value) {
    _userDetailsBloc.add(ToggleTodoEvent(index: index, value: value ?? false));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _userDetailsBloc,
      child: BlocConsumer<UserDetailsBloc, UserDetailsState>(
        listener: (context, state) {
          if (state is UserDetailsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${widget.user.firstName} ${widget.user.lastName}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _navigateToCreatePost(context),
                ),
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () => _navigateToUserDetails(context),
                ),
              ],
            ),
            body: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // User Profile Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'avatar-${widget.user.id}',
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(widget.user.image),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${widget.user.firstName} ${widget.user.lastName}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          widget.user.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: const TabBar(
                      tabs: [Tab(text: 'Posts'), Tab(text: 'Todos')],
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Posts Tab
                        RefreshIndicator(
                          onRefresh: _onRefresh,
                          child:
                              state is UserDetailsLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : state is UserDetailsLoaded
                                  ? ListView.builder(
                                    itemCount: state.posts.length,
                                    itemBuilder: (context, index) {
                                      final post = state.posts[index];
                                      final tags = List<String>.from(
                                        post['tags'] ?? [],
                                      );
                                      final reactions =
                                          post['reactions']
                                              as Map<String, dynamic>? ??
                                          {};
                                      final views = post['views'] ?? 0;

                                      return Card(
                                        margin: const EdgeInsets.all(8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post['title'] ?? 'No Title',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleLarge,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                post['body'] ?? 'No Content',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 12),
                                              if (tags.isNotEmpty)
                                                Wrap(
                                                  spacing: 4,
                                                  children:
                                                      tags
                                                          .map(
                                                            (tag) => Chip(
                                                              label: Text(tag),
                                                              backgroundColor:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .secondaryContainer,
                                                              labelStyle: TextStyle(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onSecondaryContainer,
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.thumb_up,
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${reactions['likes'] ?? 0}',
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Icon(
                                                        Icons.thumb_down,
                                                        color:
                                                            Theme.of(
                                                              context,
                                                            ).colorScheme.error,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${reactions['dislikes'] ?? 0}',
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.remove_red_eye,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text('$views views'),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                  : const Center(
                                    child: Text('No posts available'),
                                  ),
                        ),

                        // Todos Tab
                        RefreshIndicator(
                          onRefresh: _onRefresh,
                          child:
                              state is UserDetailsLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : state is UserDetailsLoaded
                                  ? Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount: state.todos.length,
                                          itemBuilder: (context, index) {
                                            final todo = state.todos[index];
                                            return Card(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            todo['todo'] ??
                                                                'No Title',
                                                            style: Theme.of(
                                                              context,
                                                            ).textTheme.titleMedium?.copyWith(
                                                              decoration:
                                                                  todo['completed'] ==
                                                                          true
                                                                      ? TextDecoration
                                                                          .lineThrough
                                                                      : null,
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            size: 20,
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  _editTodoTitle(
                                                                    index,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Switch(
                                                          value:
                                                              todo['completed'] ??
                                                              false,
                                                          onChanged:
                                                              (value) =>
                                                                  _toggleTodo(
                                                                    index,
                                                                    value,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add Todo'),
                                          onPressed: _addTodo,
                                        ),
                                      ),
                                    ],
                                  )
                                  : const Center(
                                    child: Text('No todos available'),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToCreatePost(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(userId: widget.user.id),
      ),
    );
    if (result == true) {
      _userDetailsBloc.add(RefreshUserDetailsEvent(userId: widget.user.id));
    }
  }
}
