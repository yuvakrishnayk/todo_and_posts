// widgets/orbital_user_avatar.dart
import 'dart:math';

import 'package:assignment/models/user.dart';
import 'package:assignment/screens/user_detail_screen.dart';
import 'package:flutter/material.dart';

class OrbitalUserAvatar extends StatelessWidget {
  final User user;
  final double animationValue;

  const OrbitalUserAvatar({
    super.key,
    required this.user,
    required this.animationValue, required int size,
  });

  @override
  Widget build(BuildContext context) {
    final angle = animationValue * 2 * pi;
    final offsetX = cos(angle) * 10;
    final offsetY = sin(angle) * 10;

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: GestureDetector(
        onTap: () => _navigateToUserDetail(context),
        child: Column(
          children: [
            Hero(
              tag: 'avatar-${user.id}',
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(user.image),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.firstName,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToUserDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailScreen(user: user)),
    );
  }
}
