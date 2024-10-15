import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://your-api-url.com'; // Replace with your API URL

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserTasks(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/tasks/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> tasksJson = json.decode(response.body);
      return tasksJson.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Map<String, dynamic>> createTask(int userId, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuario_id': userId,
        'descripcion': description,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTask(int taskId, bool completed) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'completada': completed,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int taskId) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$taskId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}