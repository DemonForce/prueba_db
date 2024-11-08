// pages/admin_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AdminPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdminPage({super.key, required this.userData});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<Map<String, dynamic>> _todoItems = [];
  final ApiService apiService = ApiService();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _loadUserTasks();
  }

  Future<void> _loadUserTasks() async {
    try {
      final tasks = await apiService.getUserTasks(widget.userData['id']);
      if (tasks != null) {
        setState(() {
          _todoItems.clear();
          _todoItems.addAll(tasks.cast<Map<String, dynamic>>());
        });
      } else {
        _showSnackBar('Error al cargar tareas', Colors.red);
      }
    } catch (e) {
      print('Error en _loadUserTasks: $e');
      _showSnackBar('Error al cargar tareas', Colors.red);
    }
  }

  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      _saveTaskToApi(task);
    }
  }

  Future<void> _saveTaskToApi(String task) async {
    try {
      final newTask = await apiService.createTask(widget.userData['id'], task);
      if (newTask != null) {
        setState(() {
          _todoItems.add(newTask);
        });
      } else {
        _showSnackBar('Error al guardar tarea', Colors.red);
      }
    } catch (e) {
      print('Error en _saveTaskToApi: $e');
      _showSnackBar('Error al guardar tarea', Colors.red);
    }
  }

  void _removeTodoItem(int index) {
    if (index >= 0 && index < _todoItems.length) {
      final taskId = _todoItems[index]['id'];
      _deleteTaskFromApi(taskId, index);
    }
  }

  Future<void> _deleteTaskFromApi(int taskId, int index) async {
    try {
      final success = await apiService.deleteTask(taskId);
      if (success) {
        setState(() {
          _todoItems.removeAt(index);
        });
      } else {
        _showSnackBar('Error al eliminar tarea', Colors.red);
      }
    } catch (e) {
      print('Error en _deleteTaskFromApi: $e');
      _showSnackBar('Error al eliminar tarea', Colors.red);
    }
  }

  void _toggleTaskCompletion(int index) {
    if (index >= 0 && index < _todoItems.length) {
      final taskId = _todoItems[index]['id'];
      final isCurrentlyCompleted = _todoItems[index]['completada'] == 1 ||
          _todoItems[index]['completada'] == true;
      final newCompletionStatus = !isCurrentlyCompleted;
      _updateTaskCompletionInApi(taskId, newCompletionStatus, index);
    }
  }

  Future<void> _updateTaskCompletionInApi(
      int taskId, bool isCompleted, int index) async {
    try {
      final success = await apiService.updateTask(taskId, isCompleted);
      if (success) {
        final updatedTask = await apiService.getTaskById(taskId);
        if (updatedTask != null) {
          setState(() {
            _todoItems[index] = updatedTask;
          });
        } else {
          _showSnackBar('Error al obtener la tarea actualizada', Colors.red);
        }
      } else {
        _showSnackBar('Error al actualizar tarea', Colors.red);
      }
    } catch (e) {
      print('Error en _updateTaskCompletionInApi: $e');
      _showSnackBar('Error al actualizar tarea', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  Widget _buildTodoList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          if (_isFabVisible) {
            setState(() {
              _isFabVisible = false;
            });
          }
        } else if (scrollNotification is ScrollEndNotification) {
          if (!_isFabVisible) {
            setState(() {
              _isFabVisible = true;
            });
          }
        }
        return true;
      },
      child: ListView.builder(
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          return _buildTodoItem(_todoItems[index], index);
        },
      ),
    );
  }

  Widget _buildTodoItem(Map<String, dynamic> todoItem, int index) {
    final isCompleted =
        todoItem['completada'] == 1 || todoItem['completada'] == true;
    final fechaCompletada = todoItem['fecha_completada'];
    String? formattedDate;

    if (fechaCompletada != null) {
      final dateTime = DateTime.parse(fechaCompletada).toLocal();
      formattedDate =
          '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    }

    return ListTile(
      title: Text(
        todoItem['descripcion'],
        style: TextStyle(
          color: Colors.white,
          decoration:
              isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      subtitle: isCompleted && formattedDate != null
          ? Text(
              'Completada el: $formattedDate',
              style: const TextStyle(color: Colors.grey),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCompleted)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _removeTodoItem(index),
            ),
          IconButton(
            icon: Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: Colors.white,
            ),
            onPressed: () => _toggleTaskCompletion(index),
          ),
        ],
      ),
    );
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          String newTask = '';
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 26, 28, 36),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              title: const Text(
                'Agregar nueva tarea',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                autofocus: true,
                onChanged: (val) {
                  newTask = val;
                },
                decoration: const InputDecoration(
                  hintText: 'Ingresa la nueva tarea',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.all(16.0),
                ),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _addTodoItem(newTask);
                Navigator.pop(context);
              },
              backgroundColor: const Color.fromARGB(255, 26, 28, 36),
              child: const Icon(Icons.check, color: Colors.white),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // No eliminamos las credenciales para permitir el inicio de sesión biométrico posterior
    // await secureStorage.delete(key: 'username');
    // await secureStorage.delete(key: 'password');

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.userData['nivel']}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 26, 28, 36),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Lista de Tareas',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _buildTodoList(),
          ),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          onPressed: _isFabVisible ? _pushAddTodoScreen : null,
          tooltip: 'Agregar tarea',
          backgroundColor: const Color.fromARGB(255, 26, 28, 36),
          shape: const CircleBorder(
            side: BorderSide(
              width: 1.0,
            ),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
