import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../models/user.dart';
import '../screens/user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const UserListScreen({super.key, required this.onToggleTheme});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<User> filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  static const _pageSize = 20;
  final PagingController<int, User> _pagingController = PagingController(
    firstPageKey: 1,
  );
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _pagingController.addPageRequestListener(_fetchPage);
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      context.read<UserBloc>().add(LoadUsers());

      // Listen for state changes to update the paging controller
      final userBloc = context.read<UserBloc>();
      final currentState = userBloc.state;

      if (currentState is UsersLoaded) {
        final newItems = currentState.users;
        final isLastPage = newItems.length < _pageSize;

        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          _pagingController.appendPage(newItems, pageKey + 1);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    final currentState = context.read<UserBloc>().state;

    if (currentState is UsersLoaded) {
      setState(() {
        if (query.isEmpty) {
          filteredUsers = currentState.users;
        } else {
          filteredUsers =
              currentState.users.where((user) {
                return user.firstName.toLowerCase().contains(query) ||
                    user.lastName.toLowerCase().contains(query) ||
                    user.email.toLowerCase().contains(query);
              }).toList();
        }
      });

      // Reset paging controller when filter changes
      _pagingController.refresh();
    }
  }

  Future<void> _refreshUsers() async {
    _pagingController.refresh();
    context.read<UserBloc>().add(RefreshUsers());
    // The RefreshUsers event will reset the currentPage to 1 in the UserBloc
    return Future.delayed(
      const Duration(milliseconds: 300),
    ); // Give time for state to update
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
              Expanded(
                child: BlocConsumer<UserBloc, UserState>(
                  listener: (context, state) {
                    if (state is UsersLoaded) {
                      // Update filtered users for search
                      setState(() {
                        filteredUsers =
                            _searchController.text.isEmpty
                                ? state.users
                                : state.users.where((user) {
                                  final query =
                                      _searchController.text.toLowerCase();
                                  return user.firstName.toLowerCase().contains(
                                        query,
                                      ) ||
                                      user.lastName.toLowerCase().contains(
                                        query,
                                      ) ||
                                      user.email.toLowerCase().contains(query);
                                }).toList();
                      });

                      // Update paging controller when new users are loaded
                      final currentPageKey = _pagingController.nextPageKey ?? 1;
                      final isLastPage = state.users.length < _pageSize;

                      if (isLastPage) {
                        _pagingController.appendLastPage(state.users);
                      } else {
                        _pagingController.appendPage(
                          state.users,
                          currentPageKey + 1,
                        );
                      }
                    }

                    if (state is UserError) {
                      _pagingController.error = state.message;
                    }
                  },
                  builder: (context, state) {
                    if (state is UserInitial) {
                      // Trigger loading on initial state
                      context.read<UserBloc>().add(LoadUsers());
                    }

                    if (state is UserError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    }

                    return _buildUserList(state is UserLoading);
                  },
                ),
              ),
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.brightness_6,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintText: 'Search users...',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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

  Widget _buildUserList(bool isLoadingMore) {
    final query = _searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      // If we have an active search query, use the filtered list
      return RefreshIndicator(
        onRefresh: _refreshUsers,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _buildUserCard(user, index);
          },
        ),
      );
    }

    // Use PagedListView for normal mode (no filter)
    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: PagedListView<int, User>(
        pagingController: _pagingController,
        padding: const EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<User>(
          itemBuilder: (context, user, index) => _buildUserCard(user, index),
          firstPageProgressIndicatorBuilder:
              (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          newPageProgressIndicatorBuilder:
              (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          noItemsFoundIndicatorBuilder:
              (_) => Center(
                child: Text(
                  'No users found',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
        ),
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
              // Simple Circle Avatar
              Hero(
                tag: 'avatar-${user.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user.image),
                ),
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

  void _navigateToUserDetail(User user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailScreen(user: user)),
    );
    // Re-run the search filter
    _filterUsers();
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
