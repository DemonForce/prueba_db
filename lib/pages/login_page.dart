// pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';

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
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  bool _canCheckBiometrics = false;
  bool _useBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _checkLoginStatus();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = false;
    bool isDeviceSupported = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      isDeviceSupported = await auth.isDeviceSupported();
    } on PlatformException catch (e) {
      print('Error en _checkBiometrics: $e');
    }
    if (!mounted) return;
    setState(() {
      _canCheckBiometrics = canCheckBiometrics && isDeviceSupported;
    });
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool? useBiometrics = prefs.getBool('useBiometrics');

    setState(() {
      _useBiometrics = useBiometrics ?? false;
    });

    if (isLoggedIn && useBiometrics == true) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para ingresar',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Recuperar credenciales de forma segura
        String? username = await secureStorage.read(key: 'username');
        String? password = await secureStorage.read(key: 'password');

        if (username != null && password != null) {
          _loginWithCredentials(username, password);
        } else {
          _showSnackBar('No se encontraron credenciales guardadas', Colors.red);
        }
      } else {
        _showSnackBar(
            'Autenticación biométrica cancelada o fallida', Colors.red);
      }
    } on PlatformException catch (e) {
      print('Error en _authenticateWithBiometrics: $e');
      _showSnackBar('Error al autenticar: ${e.message}', Colors.red);
    } catch (e) {
      print('Error inesperado en _authenticateWithBiometrics: $e');
      _showSnackBar('Error al autenticar', Colors.red);
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    _loginWithCredentials(username, password);
  }

  Future<void> _loginWithCredentials(String username, String password) async {
    try {
      final userData = await apiService.login(username, password);

      if (userData != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Guardar credenciales de forma segura
        await secureStorage.write(key: 'username', value: username);
        await secureStorage.write(key: 'password', value: password);

        bool? useBiometrics = prefs.getBool('useBiometrics');

        // Actualizar 'useBiometrics' si es nulo, es decir, primera vez que inicia sesión
        if (_canCheckBiometrics && useBiometrics == null) {
          _promptBiometricEnrollment(userData);
        } else {
          // Si el usuario ya eligió usar biometría o no, continuamos
          _navigateToNextScreen(userData);
        }
      } else {
        _showSnackBar('Usuario o contraseña incorrectos', Colors.red);
      }
    } catch (e) {
      print('Error en _loginWithCredentials: $e');
      _showSnackBar('Error al iniciar sesión', Colors.red);
    }
  }

  void _promptBiometricEnrollment(Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usar autenticación biométrica'),
        content: const Text(
            '¿Deseas usar tu huella digital para iniciar sesión en el futuro?'),
        actions: [
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('useBiometrics', false);
              Navigator.of(context).pop();
              _navigateToNextScreen(userData);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('useBiometrics', true);
              Navigator.of(context).pop();
              _navigateToNextScreen(userData);
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  void _navigateToNextScreen(Map<String, dynamic> userData) {
    if (userData['nivel'] == 'admin') {
      Navigator.pushReplacementNamed(
        context,
        '/admin',
        arguments: userData,
      );
    } else {
      _showSnackBar('Inicio de sesión exitoso', Colors.green);
      // Navegar a otra página si es necesario
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
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
          color: Color.fromARGB(255, 26, 28, 36),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/user4.jpg',
                    height: 190,
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: _usernameController,
                    hintText: 'Usuario',
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Contraseña',
                    prefixIcon: Icons.lock,
                    obscureText: _obscureText,
                    onSuffixIconPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
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
                  if (_canCheckBiometrics && _useBiometrics)
                    TextButton.icon(
                      onPressed: _authenticateWithBiometrics,
                      icon:
                          const Icon(Icons.fingerprint, color: Colors.white),
                      label: const Text(
                        'Iniciar sesión con huella digital',
                        style: TextStyle(color: Colors.white),
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