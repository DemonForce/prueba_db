import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Construye el MaterialApp con el tema y la página de inicio
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple, // Define el color principal
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adapta la densidad visual a la plataforma
        scaffoldBackgroundColor: const Color(0xFF1F2937), // Establece el color de fondo del scaffold
      ),
      home: const LoginPage(), // Define la página de inicio
    );
  }
}

class AdminPage extends StatelessWidget {
  final Map<String, dynamic> userData; // Datos del usuario

  const AdminPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // Construye la página de administración
    return Scaffold(
      appBar: AppBar(
        title: Text('Nivel: ${userData['nivel']}'), // Muestra el nivel del usuario
      ),
      body: Center(
        child: Text(
          'Página de Administración\nUsuario: ${userData['username']}', // Muestra el nombre del usuario
          style: const TextStyle(fontSize: 20, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState(); // Crea el estado de la página de inicio de sesión
}

class _LoginPageState extends State<LoginPage> {
  late PostgreSQLConnection connection; // Conexión a la base de datos PostgreSQL
  final _usernameController = TextEditingController(); // Controlador para el campo de usuario
  final _passwordController = TextEditingController(); // Controlador para el campo de contraseña
  bool _obscureText = true; // Variable para ocultar o mostrar la contraseña

  @override
  void initState() {
    super.initState();
    // Configura la conexión a la base de datos PostgreSQL
    connection = PostgreSQLConnection(
      'junction.proxy.rlwy.net',
      44486,
      'railway',
      username: 'postgres',
      password: 'gHGXaBNPGOqpooWANcIvrNomMwLryXXr',
    );
    _openConnection(); // Abre la conexión a la base de datos
  }

  Future<void> _openConnection() async {
    try {
      await connection.open(); // Intenta abrir la conexión
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conexión a la base de datos exitosa')), // Notificación de éxito
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar a la base de datos: $e')), // Notificación de error
        );
      }
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text; // Obtiene el nombre de usuario
    final password = _passwordController.text; // Obtiene la contraseña

    try {
      // Consulta para verificar si el usuario existe en la base de datos
      final results = await connection.query(
        'SELECT * FROM usuarios WHERE username = @username AND password = @password',
        substitutionValues: {
          'username': username,
          'password': password,
        },
      );

      if (results.isNotEmpty) {
        final user = results.first.toColumnMap(); // Obtiene los datos del primer resultado
        if (user['nivel'] == 'admin') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminPage(userData: user), // Navega a la página de administración si el usuario es admin
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inicio de sesión exitoso')), // Notificación de inicio de sesión exitoso
            );
            // Navega a otra página para usuarios normales si es necesario
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario o contraseña incorrectos')), // Notificación de error en credenciales
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: $e')), // Notificación de error en el inicio de sesión
        );
      }
    }
  }

  @override
  void dispose() {
    // Limpia los controladores y cierra la conexión a la base de datos
    _usernameController.dispose();
    _passwordController.dispose();
    connection.close().then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conexión a la base de datos cerrada')), // Notificación de cierre de conexión
        );
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Construye la interfaz de la página de inicio de sesión
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2937), Color(0xFF111827)], // Fondo con gradiente
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reemplaza el icono por una imagen de los assets
                  Image.asset(
                    'assets/images/user.png',
                    height: 200,
                  ),
                  const Text(
                      'bitcoder',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  const SizedBox(height: 30),
                  // Campo de texto para el nombre de usuario
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Usuario',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo de texto para la contraseña
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Alterna la visibilidad de la contraseña
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Botón para iniciar sesión
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.purple, // Color del botón
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
