// screens/user_detail_screen.dart
import 'package:assignment/screens/create_post_screen.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreatePost(context),
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
                      backgroundImage: NetworkImage(widget.user.avatar),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.user.name,
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
                  ListView.builder(
                    itemCount: 3, // Replace with actual todos
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text('Todo Item $index'),
                        value: index.isEven,
                        onChanged: (value) {},
                      );
                    },
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
