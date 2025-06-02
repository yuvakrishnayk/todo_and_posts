// screens/user_list_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/orbital_user_avatar.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _loadUsers() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        users = User.dummyData();
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load users';
        isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers =
          users.where((user) {
            return user.name.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query);
          }).toList();
    });
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
              // Search "Sun"
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Hero(
                  tag: 'search-sun',
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search),
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
              ),

              // User List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error.isNotEmpty
                        ? Center(child: Text(error))
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              setState(() {
                                _controller.value =
                                    notification.metrics.pixels / 1000;
                              });
                              return false;
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(""),
                                      radius: 25,
                                    ),
                                    title: Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(user.email),
                                    onTap: () {
                                      // Handle user tap
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrbitPainter extends CustomPainter {
  final double animationValue;

  OrbitPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..color = Colors.deepPurple.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Draw multiple orbits
    for (var i = 1; i <= 5; i++) {
      final radius = 50.0 * i;
      canvas.drawCircle(
        center,
        radius + sin(animationValue * 2 * pi) * 10,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
