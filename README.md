# Flutter User Management App

A modern Flutter application showcasing clean architecture, BLoC pattern, and API integration.

![Flutter Version](https://img.shields.io/badge/flutter->=3.0.0-blue.svg)
![Dart Version](https://img.shields.io/badge/dart->=3.0.0-blue.svg)


## 🌟 Features

- **User Management**

  - View user list with pagination
  - Search users by name
  - Infinite scrolling
  - User details view

- **Posts & Todos**

  - View user posts
  - Manage user todos
  - Create new posts
  - Real-time updates

- **Advanced UI**
  - Material Design 3
  - Light/Dark theme support
  - Pull-to-refresh
  - Smooth animations
  - Loading indicators

## 🏗️ Architecture

```
lib/
├── bloc/           # BLoC pattern implementation
├── models/         # Data models
├── repositories/   # Data handling
├── screens/        # UI screens
├── services/       # API services
└── widgets/        # Reusable widgets
```

## 🚀 Getting Started

### Prerequisites
```bash
flutter --version
# Flutter >= 3.0.0
# Dart >= 3.0.0
```

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yuvakrishnayk/todo_and_posts
   ```

2. **Navigate to the project directory**:
   ```bash
   cd flutter-todo_and_posts
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

### Running the Application

#### Mobile Development
1. Connect a device or start an emulator
2. Run the application:
   ```bash
   flutter run
   ```

#### Web Development
1. Run the application in a web browser:
   ```bash
   flutter run -d chrome
   ```

### Build Instructions

Generate a release build:

- **For Android**:
  ```bash
  flutter build apk --release
  ```
- **For iOS**:
  ```bash
  flutter build ios --release
  ```
- **For Web**:
  ```bash
  flutter build web --release
  ```

## 🔌 API Integration

The app integrates with DummyJSON APIs:

- Users API: `https://dummyjson.com/users`
- Posts API: `https://dummyjson.com/posts/user/{userId}`
- Todos API: `https://dummyjson.com/todos/user/{userId}`

## 🎯 State Management

Using BLoC pattern for:

- User listing and pagination
- Search functionality
- Post/Todo management
- Error handling

## 🛠️ Built With

- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - State Management
- [http](https://pub.dev/packages/http) - API Integration
- [cached_network_image](https://pub.dev/packages/cached_network_image) - Image Caching
- [shimmer](https://pub.dev/packages/shimmer) - Loading Effects





## 🙏 Acknowledgments

- DummyJSON for providing the API
- Flutter team for the amazing framework
- BLoC library maintainers

## 👤 Author

- LinkedIn: [linkedin.com/in/yuvakrishnai](https://linkedin.com/in/yourprofile)

---

⭐️ Star this repo if you find it helpful!
