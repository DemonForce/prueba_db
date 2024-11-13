import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://api-production-559c.up.railway.app';

  /// Método para iniciar sesión
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        print('Credenciales inválidas: ${response.body}');
        return null;
      } else {
        print('Error en login: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción en login: $e');
      return null;
    }
  }

  /// Obtener tareas de un usuario por ID
  Future<List<dynamic>?> getUserTasks(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('Error al obtener tareas: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener tareas: $e');
      return null;
    }
  }

  /// Crear una nueva tarea
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
        print('Error al crear tarea: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al crear tarea: $e');
      return null;
    }
  }

  /// Actualizar el estado de una tarea
  Future<bool> updateTask(int taskId, bool completed) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'completada': completed}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Error al actualizar tarea: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al actualizar tarea: $e');
      return false;
    }
  }

  /// Eliminar una tarea por ID
  Future<bool> deleteTask(int taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Error al eliminar tarea: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al eliminar tarea: $e');
      return false;
    }
  }

  /// Obtener una tarea por su ID
  Future<Map<String, dynamic>?> getTaskById(int taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/task/$taskId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        print('Tarea no encontrada: ${response.body}');
        return null;
      } else {
        print('Error al obtener tarea: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener tarea: $e');
      return null;
    }
  }

  /// Guardar un UID NFC en el backend
  Future<bool> saveNfcUid(String uid) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/nfc'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uid': uid}),
      );

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 409) {
        print('El UID NFC ya existe en el servidor.');
        return false;
      } else {
        print('Error al guardar el UID NFC: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al guardar el UID NFC: $e');
      return false;
    }
  }
}
