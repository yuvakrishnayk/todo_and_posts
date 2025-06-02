// screens/user_detail_screen.dart
import 'package:assignment/screens/create_post_screen.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
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
                    tag: 'avatar-${user.id}',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.avatar),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    user.email,
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
                  ListView.builder(
                    itemCount: 5, // Replace with actual posts
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('Post Title $index'),
                          subtitle: Text('Post content...'),
                        ),
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

  void _navigateToCreatePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
  }
}
