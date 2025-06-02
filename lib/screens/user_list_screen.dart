import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../widgets/orbital_user_avatar.dart';
import '../screens/user_detail_screen.dart'; // Add this import

class UserListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const UserListScreen({super.key, required this.onToggleTheme});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<User> users = [];
  List<User> filteredUsers = [];
  bool isLoading = true;
  String error = '';
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  int _currentPage = 1;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        _isFetchingMore = true;
      });
    }
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/users?page=$_currentPage'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          final newUsers = (data['users'] as List).map((user) => User.fromJson(user)).toList();
          users = loadMore ? [...users, ...newUsers] : newUsers;
          filteredUsers = users;
          isLoading = false;
          _isFetchingMore = false;
          _currentPage++;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load users';
        isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && !_isFetchingMore) {
      _loadUsers(loadMore: true);
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers =
          users.where((user) {
            return user.firstName.toLowerCase().contains(query) ||
                user.lastName.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query);
          }).toList();
    });
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _currentPage = 1;
      isLoading = true;
    });
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: OrbitPainter(_controller.value),
                size: Size.infinite,
              );
            },
          ),

          Column(
            children: [
              // App bar with search
              _buildAppBar(context),

              // Main content
              Expanded(child: _buildUserList()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'User Directory',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(
                          context,
                        ).colorScheme.onSurface, // Dynamic text color
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.brightness_6, color: Colors.black87),
                onPressed: widget.onToggleTheme,
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Hero(
            tag: 'search-sun',
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.onSurface, // Dynamic text color
                ), // Light theme text color
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintText: 'Search users...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(
                      0.6,
                    ), // Dynamic hint text color
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (isLoading && filteredUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(
        child: Text(
          error,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    if (filteredUsers.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredUsers.length + (_isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredUsers.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = filteredUsers[index];
          return _buildUserCard(user, index);
        },
      ),
    );
  }

  Widget _buildUserCard(User user, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _navigateToUserDetail(user),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Orbital Avatar
              OrbitalUserAvatar(
                user: user,
                animationValue: _controller.value + index * 0.1,
                size: 60,
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSurface, // Dynamic text color
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSurface, // Dynamic text color
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action button
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.onSurface, // Dynamic icon color
                ),
                onPressed: () => _navigateToUserDetail(user),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUserDetail(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailScreen(user: user)),
    );
  }
}

// Custom painter for animated orbits in the background
class OrbitPainter extends CustomPainter {
  final double animationValue;

  OrbitPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..color = Colors.deepPurple.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // Draw multiple subtle orbits
    for (var i = 1; i <= 3; i++) {
      final radius = 100.0 * i;
      canvas.drawCircle(
        center,
        radius + sin(animationValue * 2 * pi) * 5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
