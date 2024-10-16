import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://api-production-559c.up.railway.app'; // Reemplaza con tu URL de la API

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Manejar error de login
      return null;
    }
  }

  Future<List<dynamic>?> getUserTasks(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/tasks/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Manejar error al obtener tareas
      return null;
    }
  }

  Future<Map<String, dynamic>?> createTask(int userId, String description) async {
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
      // Manejar error al crear tarea
      return null;
    }
  }

  Future<bool> updateTask(int taskId, bool completed) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'completada': completed}),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteTask(int taskId) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$taskId'));

    return response.statusCode == 200;
  }

  // Agrega el método getTaskById aquí
  Future<Map<String, dynamic>?> getTaskById(int taskId) async {
    final response = await http.get(Uri.parse('$baseUrl/tasks/task/$taskId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Manejar error al obtener la tarea
      return null;
    }
  }
}