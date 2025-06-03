// models/user.dart
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String maidenName;
  final int age;
  final String gender;
  final String email;
  final String phone;
  final String username;
  final String birthDate;
  final String image;
  final String bloodGroup;
  final double height;
  final double weight;
  final String eyeColor;
  final String hairColor;
  final String hairType;
  final Address address;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.maidenName,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.username,
    required this.birthDate,
    required this.image,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
    required this.hairType,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      maidenName: json['maidenName'],
      age: json['age'],
      gender: json['gender'],
      email: json['email'],
      phone: json['phone'],
      username: json['username'],
      birthDate: json['birthDate'],
      image: json['image'],
      bloodGroup: json['bloodGroup'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      eyeColor: json['eyeColor'],
      hairColor: json['hair']['color'],
      hairType: json['hair']['type'],
      address: Address(
        city: json['address']['city'],
        state: json['address']['state'],
      ),
    );
  }

  static List<User> dummyData() {
    return [
      User(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        maidenName: 'Smith',
        age: 28,
        gender: 'male',
        email: 'john@example.com',
        phone: '123-456-7890',
        username: 'johndoe',
        birthDate: '1995-01-01',
        image: 'https://i.pravatar.cc/150?img=1',
        bloodGroup: 'A+',
        height: 180.5,
        weight: 75.0,
        eyeColor: 'brown',
        hairColor: 'black',
        hairType: 'curly',
        address: Address(
          city: 'New York',
          state: 'NY',
        ),
      ),
      User(
        id: 2,
        firstName: 'Jane',
        lastName: 'Smith',
        maidenName: 'Doe',
        age: 25,
        gender: 'female',
        email: 'jane@example.com',
        phone: '098-765-4321',
        username: 'janesmith',
        birthDate: '1998-02-02',
        image: 'https://i.pravatar.cc/150?img=2',
        bloodGroup: 'B-',
        height: 165.0,
        weight: 60.0,
        eyeColor: 'blue',
        hairColor: 'blonde',
        hairType: 'straight',
        address: Address(
          city: 'Los Angeles',
          state: 'CA',
        ),
      ),
      // Add more dummy users...
    ];
  }
}

class Address {
  final String city;
  final String state;

  Address({
    required this.city,
    required this.state,
  });
}
