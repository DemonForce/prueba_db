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

  // Corrección aquí: Actualizar la ruta para obtener todas las tareas de un usuario
  Future<List<dynamic>?> getUserTasks(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/tasks/user/$userId'));

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

  // Corrección aquí: Verificar y manejar correctamente el estado HTTP en updateTask
  Future<bool> updateTask(int taskId, bool completed) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'completada': completed}),
    );

    // Aceptamos tanto 200 como 204 como respuestas exitosas
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteTask(int taskId) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$taskId'));

    // Aceptamos tanto 200 como 204 como respuestas exitosas
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // Método getTaskById ya agregado correctamente
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
