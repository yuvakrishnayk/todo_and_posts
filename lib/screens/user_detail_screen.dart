// screens/user_detail_screen.dart
import 'package:assignment/screens/create_post_screen.dart';
import 'package:assignment/screens/full_user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (widget.user.id == null || widget.user.id.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid user ID'))
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final postsResponse = await http.get(
        Uri.parse('https://dummyjson.com/posts/user/${widget.user.id}'),
      );
      final todosResponse = await http.get(
        Uri.parse('https://dummyjson.com/todos/user/${widget.user.id}'),
      );

      if (postsResponse.statusCode == 200 && todosResponse.statusCode == 200) {
        final postsData = json.decode(postsResponse.body);
        final todosData = json.decode(todosResponse.body);

        // Get local posts for this user
        final localPosts = PostRepository.posts
            .where((post) => post['userId'] == widget.user.id)
            .toList();

        setState(() {
          _posts = [
            ...List<Map<String, dynamic>>.from(postsData['posts'] ?? []),
            ...localPosts
          ];
          _todos = List<Map<String, dynamic>>.from(todosData['todos'] ?? []);
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data'))
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e'))
      );
    }
  }

  void _editTodoTitle(int index) async {
    final controller = TextEditingController(text: _todos[index]['todo']);
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
      setState(() {
        _todos[index]['todo'] = result.trim();
      });
    }
  }

  void _addTodo() {
    setState(() {
      _todos.add({'todo': 'New Todo', 'completed': false});
    });
  }

  void _toggleTodo(int index, bool? value) {
    setState(() {
      _todos[index]['completed'] = value ?? false;
    });
  }

  void _navigateToUserDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullUserDetailScreen(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          final tags = List<String>.from(post['tags'] ?? []);
                          final reactions =
                              post['reactions'] as Map<String, dynamic>? ?? {};
                          final views = post['views'] ?? 0;

                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['title'] ?? 'No Title',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post['body'] ?? 'No Content',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  // Tags
                                  if (tags.isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      children:
                                          tags
                                              .map(
                                                (tag) => Chip(
                                                  label: Text(tag),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                  labelStyle: TextStyle(
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onSecondaryContainer,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  const SizedBox(height: 8),
                                  // Reactions and Views
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.thumb_up,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text('${reactions['likes'] ?? 0}'),
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
                                          Text('${reactions['dislikes'] ?? 0}'),
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
                      ),

                  // Todos Tab
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: _todos.length,
                              itemBuilder: (context, index) {
                                final todo = _todos[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                todo['todo'] ?? 'No Title',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
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
                                                  () => _editTodoTitle(index),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Switch(
                                              value: todo['completed'] ?? false,
                                              onChanged:
                                                  (value) =>
                                                      _toggleTodo(index, value),
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
                      ),
                ],
              ),
            ),
          ],
        ),
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
      _fetchUserData(); // Refresh posts when returning from create screen
    }
  }
}
