// screens/user_detail_screen.dart
import 'package:assignment/screens/create_post_screen.dart';
import 'package:assignment/screens/full_user_detail_screen.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  List<Map<String, dynamic>> _todos = [
    {'title': 'Todo Item 0', 'completed': true},
    {'title': 'Todo Item 1', 'completed': false},
    {'title': 'Todo Item 2', 'completed': true},
  ];

  void _addTodo() {
    setState(() {
      _todos.add({'title': 'Todo Item ${_todos.length}', 'completed': false});
    });
  }

  void _toggleTodo(int index, bool? value) {
    setState(() {
      _todos[index]['completed'] = value ?? false;
    });
  }

  void _editTodoTitle(int index) async {
    final controller = TextEditingController(text: _todos[index]['title']);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Todo'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Todo Title'),
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
        _todos[index]['title'] = result.trim();
      });
    }
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
                  Builder(
                    builder: (context) {
                      final userPosts =
                          PostRepository.posts
                              .where((post) => post['userId'] == widget.user.id)
                              .toList();
                      return ListView.builder(
                        itemCount: userPosts.length,
                        itemBuilder: (context, index) {
                          final post = userPosts[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(post['title'] ?? ''),
                              subtitle: Text(post['body'] ?? ''),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Todos Tab
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _todos.length,
                          itemBuilder: (context, index) {
                            final todo = _todos[index];
                            return CheckboxListTile(
                              title: Row(
                                children: [
                                  Expanded(child: Text(todo['title'])),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _editTodoTitle(index),
                                  ),
                                ],
                              ),
                              value: todo['completed'],
                              onChanged: (value) => _toggleTodo(index, value),
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
      setState(() {}); // Refresh posts
    }
  }
}
