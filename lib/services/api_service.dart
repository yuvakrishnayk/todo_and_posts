import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../utils/api_exception.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  Future<Map<String, dynamic>> getUserPosts(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/user/$userId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw ApiException('Failed to fetch user posts', response.statusCode);
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getUserTodos(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/todos/user/$userId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw ApiException('Failed to fetch user todos', response.statusCode);
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<List<User>> getUsers(int page) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users?page=$page'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['users'] as List)
            .map((user) => User.fromJson(user))
            .toList();
      }
      throw ApiException('Failed to load users', response.statusCode);
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }
}
