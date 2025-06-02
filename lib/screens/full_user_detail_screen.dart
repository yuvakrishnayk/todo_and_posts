import 'package:flutter/material.dart';
import '../models/user.dart';

class FullUserDetailScreen extends StatelessWidget {
  final User user;
  const FullUserDetailScreen({super.key, required this.user});

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('${user.firstName} ${user.lastName}'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    user.image,
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard('Email', user.email, Icons.email),
                const SizedBox(height: 8),
                _buildInfoCard('Phone', user.phone, Icons.phone),
                const SizedBox(height: 8),
                _buildInfoCard('Age', '${user.age} years', Icons.cake),
                const SizedBox(height: 8),
                _buildInfoCard('Gender', user.gender, Icons.person),
                const SizedBox(height: 8),
                _buildInfoCard('Blood Group', user.bloodGroup, Icons.bloodtype),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Physical Characteristics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.height, color: Colors.blue),
                                const SizedBox(height: 4),
                                Text('${user.height} cm'),
                                const Text('Height'),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.monitor_weight, color: Colors.blue),
                                const SizedBox(height: 4),
                                Text('${user.weight} kg'),
                                const Text('Weight'),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.remove_red_eye, color: Colors.blue),
                                const SizedBox(height: 4),
                                Text(user.eyeColor),
                                const Text('Eye Color'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.face, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('Hair: ${user.hairType}, ${user.hairColor}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
