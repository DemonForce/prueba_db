import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

void main() {
  runApp(DatabaseProvider(child: const MainApp()));
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

class DatabaseProvider extends StatefulWidget {
  final Widget child;

  const DatabaseProvider({super.key, required this.child});

  @override
  _DatabaseProviderState createState() => _DatabaseProviderState();

  static _DatabaseProviderState of(BuildContext context) {
    final providerState =
        context.findAncestorStateOfType<_DatabaseProviderState>();
    if (providerState == null) {
      throw Exception('No se encontró DatabaseProvider en el contexto');
    }
    return providerState;
  }
}

class _DatabaseProviderState extends State<DatabaseProvider> {
  late PostgreSQLConnection connection;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    connection = PostgreSQLConnection(
      'junction.proxy.rlwy.net',
      44486,
      'railway',
      username: 'postgres',
      password: 'gHGXaBNPGOqpooWANcIvrNomMwLryXXr',
    );
    _openConnection();
  }

  Future<void> _openConnection() async {
    try {
      await connection.open();
      setState(() {
        isConnected = true;
      });
      print('Conexión a la base de datos exitosa');
    } catch (e) {
      print('Error al conectar a la base de datos: $e');
    }
  }

  Future<void> ensureConnectionOpen() async {
    if (connection.isClosed) {
      await _openConnection();
    }
  }

  @override
  void dispose() {
    connection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para asegurar que el contexto esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserTasks();
    });
  }

  Future<void> _loadUserTasks() async {
    try {
      final dbProvider = DatabaseProvider.of(context);
      await dbProvider.ensureConnectionOpen();
      final results = await dbProvider.connection.query(
        'SELECT id, descripcion FROM tareas WHERE usuario_id = @usuario_id',
        substitutionValues: {'usuario_id': widget.userData['id']},
      );

      setState(() {
        _todoItems.clear();
        _todoItems.addAll(results.map((row) => {
              'id': row[0],
              'descripcion': row[1],
            }));
      });
    } catch (e) {
      _showErrorSnackBar('Error al cargar tareas: $e');
    }
  }

  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      _saveTaskToDatabase(task);
    }
  }

  Future<void> _saveTaskToDatabase(String task) async {
    try {
      final dbProvider = DatabaseProvider.of(context);
      await dbProvider.ensureConnectionOpen();
      final result = await dbProvider.connection.query(
        'INSERT INTO tareas (usuario_id, descripcion, completada) VALUES (@usuario_id, @descripcion, @completada) RETURNING id',
        substitutionValues: {
          'usuario_id': widget.userData['id'],
          'descripcion': task,
          'completada': false,
        },
      );
      final newTaskId = result.first[0];
      setState(() {
        _todoItems.add({'id': newTaskId, 'descripcion': task});
      });
      _showSuccessSnackBar('Tarea guardada exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al guardar tarea: $e');
    }
  }

  void _removeTodoItem(int index) {
    if (index >= 0 && index < _todoItems.length) {
      final taskId = _todoItems[index]['id'];
      _deleteTaskFromDatabase(taskId, index);
    }
  }

  Future<void> _deleteTaskFromDatabase(int taskId, int index) async {
    try {
      final dbProvider = DatabaseProvider.of(context);
      await dbProvider.ensureConnectionOpen();
      await dbProvider.connection.query(
        'DELETE FROM tareas WHERE id = @id',
        substitutionValues: {'id': taskId},
      );
      setState(() {
        _todoItems.removeAt(index);
      });
      _showSuccessSnackBar('Tarea eliminada exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al eliminar tarea: $e');
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
        return _buildTodoItem(_todoItems[index]['descripcion'], index);
      },
    );
  }

  Widget _buildTodoItem(String todoText, int index) {
    return ListTile(
      title: Text(todoText, style: const TextStyle(color: Colors.white)),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.white),
        onPressed: () => _removeTodoItem(index),
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
              backgroundColor: Colors.black,
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
              backgroundColor: Colors.black,
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
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Nivel: ${widget.userData['nivel']}',
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
        backgroundColor: Colors.black,
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.white,
            width: 3.0,
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

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final dbProvider = DatabaseProvider.of(context);
      await dbProvider.ensureConnectionOpen();
      final results = await dbProvider.connection.query(
        'SELECT * FROM usuarios WHERE username = @username AND password = @password',
        substitutionValues: {
          'username': username,
          'password': password,
        },
      );

      if (results.isNotEmpty) {
        final user = results.first.toColumnMap();
        if (user['nivel'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(userData: user),
            ),
          );
        } else {
          _showSuccessSnackBar('Inicio de sesión exitoso');
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
          color: Colors.black, // Fondo negro
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
                    'assets/images/user2.jpg',
                    height: 170,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Usuario',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon:
                          const Icon(Icons.person, color: Colors.white),
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
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF242424),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Acceder',
                      style: TextStyle(fontSize: 16),
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
