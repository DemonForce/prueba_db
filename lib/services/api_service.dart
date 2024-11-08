// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://api-production-559c.up.railway.app';

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Error en login: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción en login: $e');
      return null;
    }
  }

  // Implementa manejo de excepciones similar en los siguientes métodos

  Future<List<dynamic>?> getUserTasks(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks/$userId'));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('Error al obtener tareas: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener tareas: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createTask(int userId, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario_id': userId,
          'descripcion': description,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Error al crear tarea: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al crear tarea: $e');
      return null;
    }
  }

  Future<bool> updateTask(int taskId, bool completed) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'completada': completed}),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Excepción al actualizar tarea: $e');
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/tasks/$taskId'));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Excepción al eliminar tarea: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTaskById(int taskId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks/task/$taskId'));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Error al obtener tarea: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener tarea: $e');
      return null;
    }
  }
}
