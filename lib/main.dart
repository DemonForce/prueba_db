import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      home: const LoginPage(),
    );
  }
}

class AdminPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdminPage({super.key, required this.userData});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<Map<String, dynamic>> _todoItems = [];
  final ApiService apiService = ApiService();

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
        _showErrorSnackBar('Error al cargar tareas');
      }
    } catch (e) {
      _showErrorSnackBar('Error al cargar tareas: $e');
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
        _showSuccessSnackBar('Tarea guardada exitosamente');
      } else {
        _showErrorSnackBar('Error al guardar tarea');
      }
    } catch (e) {
      _showErrorSnackBar('Error al guardar tarea: $e');
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
        _showSuccessSnackBar('Tarea eliminada exitosamente');
      } else {
        _showErrorSnackBar('Error al eliminar tarea');
      }
    } catch (e) {
      _showErrorSnackBar('Error al eliminar tarea: $e');
    }
  }

  void _toggleTaskCompletion(int index) {
    if (index >= 0 && index < _todoItems.length) {
      final taskId = _todoItems[index]['id'];
      final isCurrentlyCompleted = _todoItems[index]['completada'] == 1;
      final newCompletionStatus = !isCurrentlyCompleted;
      _updateTaskCompletionInApi(taskId, newCompletionStatus, index);
    }
  }

  Future<void> _updateTaskCompletionInApi(
      int taskId, bool isCompleted, int index) async {
    try {
      final success = await apiService.updateTask(taskId, isCompleted);
      if (success) {
        // Volvemos a cargar la tarea actualizada desde la API
        final updatedTask = await apiService.getTaskById(taskId);
        if (updatedTask != null) {
          setState(() {
            _todoItems[index] = updatedTask;
          });
        }
        _showSuccessSnackBar('Tarea actualizada exitosamente');
      } else {
        _showErrorSnackBar('Error al actualizar tarea');
      }
    } catch (e) {
      _showErrorSnackBar('Error al actualizar tarea: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoItems.length,
      itemBuilder: (context, index) {
        return _buildTodoItem(_todoItems[index], index);
      },
    );
  }

  Widget _buildTodoItem(Map<String, dynamic> todoItem, int index) {
    final isCompleted = todoItem['completada'] == 1;
    final fechaCompletada = todoItem['fecha_completada'];
    String? formattedDate;

    if (fechaCompletada != null) {
      // Formatear la fecha para mostrarla adecuadamente
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
              'Completada el $formattedDate',
              style: const TextStyle(color: Colors.grey),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              backgroundColor: Color.fromARGB(255, 26, 28, 36), 
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
              backgroundColor: Color.fromARGB(255, 26, 28, 36), 
              child: const Icon(Icons.check, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 26, 28, 36), 
        centerTitle: true,
        title: Text(
          'Usuario: ${widget.userData['username']}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: 'Agregar tarea',
        backgroundColor: Color.fromARGB(255, 26, 28, 36), 
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
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  final ApiService apiService = ApiService();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final userData = await apiService.login(username, password);

      print('userData: $userData'); // Para depuración

      if (userData != null) {
        if (userData['nivel'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(userData: userData),
            ),
          );
        } else {
          _showSuccessSnackBar('Inicio de sesión exitoso');
          // Navegar a otra página si es necesario
        }
      } else {
        _showErrorSnackBar('Usuario o contraseña incorrectos');
      }
    } catch (e) {
      _showErrorSnackBar('Error al iniciar sesión: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 26, 28, 36), // Fondo negro
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Asegúrate de que la imagen exista o reemplázala por una disponible
                  Image.asset(
                    'assets/images/user4.jpg',
                    height: 190,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Usuario',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: const Color.fromARGB(255, 71, 72, 77),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Acceder',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
