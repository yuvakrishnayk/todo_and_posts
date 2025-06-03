// screens/user_detail_screen.dart
import 'package:assignment/screens/create_post_screen.dart';
import 'package:assignment/screens/full_user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../models/user.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Future<void> _onRefresh() async {
    _fetchUserData();
  }
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _posts = [];

  void _navigateToCreatePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(userId: widget.user.id),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    if (widget.user.id.toString().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid user ID')));
      return;
    }

    // Dispatch events to load user posts and todos
    context.read<UserBloc>().add(LoadUserPosts(widget.user.id));
    context.read<UserBloc>().add(LoadUserTodos(widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserPostsLoaded && state.userId == widget.user.id) {
            setState(() {
              _posts = state.posts;
            });
          } else if (state is UserTodosLoaded &&
              state.userId == widget.user.id) {
            setState(() {
              _todos = state.todos;
            });
          } else if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 300,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'avatar-${widget.user.id}',
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(widget.user.image),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${widget.user.firstName} ${widget.user.lastName}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.user.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _navigateToCreatePost(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info, color: Colors.white),
                      onPressed: () => _navigateToUserDetails(context),
                    ),
                  ],
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.article),
                              const SizedBox(width: 8),
                              Text('Posts (${_posts.length})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle),
                              const SizedBox(width: 8),
                              Text('Todos (${_todos.length})'),
                            ],
                          ),
                        ),
                      ],
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                // Posts Tab
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _posts.isEmpty && _todos.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : AnimatedList(
                          initialItemCount: _posts.length,
                          itemBuilder: (context, index, animation) {
                            return SlideTransition(
                              position: animation.drive(Tween(
                                begin: const Offset(1, 0),
                                end: const Offset(0, 0),
                              )),
                              child: _buildPostCard(_posts[index]),
                            );
                          },
                        ),
                ),

                // Todos Tab
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _posts.isEmpty && _todos.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _buildTodoList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final tags = List<String>.from(post['tags'] ?? []);
    final reactions = post['reactions'] as Map<String, dynamic>? ?? {};
    final views = post['views'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'] ?? 'No Title',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  post['body'] ?? 'No Content',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    children: tags.map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    )).toList(),
                  ),
                ],
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildReactionButton(
                          Icons.thumb_up,
                          reactions['likes'] ?? 0,
                          Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        _buildReactionButton(
                          Icons.thumb_down,
                          reactions['dislikes'] ?? 0,
                          Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                    _buildViewsCounter(views),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  void _navigateToUserDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullUserDetailScreen(user: widget.user),
      ),
    );
  }

  Widget _buildTodoList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              final todo = _todos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Checkbox(
                    value: todo['completed'] ?? false,
                    onChanged: (value) => _toggleTodo(index, value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    todo['todo'] ?? 'No Title',
                    style: TextStyle(
                      decoration: todo['completed'] == true
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo['completed'] == true
                          ? Colors.grey
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editTodoTitle(index),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addTodo,
            icon: const Icon(Icons.add),
            label: const Text('Add Todo'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleTodo(int index, bool? value) {
    setState(() {
      _todos[index]['completed'] = value ?? false;
    });
  }

  void _addTodo() {
    setState(() {
      _todos.add({'todo': 'New Todo', 'completed': false});
    });
  }

  void _editTodoTitle(int index) {
    final todo = _todos[index];
    final controller = TextEditingController(text: todo['todo'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _todos[index]['todo'] = controller.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReactionButton(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildViewsCounter(int views) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.remove_red_eye,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '$views views',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
