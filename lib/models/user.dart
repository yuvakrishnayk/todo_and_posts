// models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });

  static List<User> dummyData() {
    return [
      User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        avatar: 'https://i.pravatar.cc/150?img=1',
      ),
      User(
        id: 2,
        name: 'Jane Smith',
        email: 'jane@example.com',
        avatar: 'https://i.pravatar.cc/150?img=2',
      ),
      // Add more dummy users...
    ];
  }
}
