// main.dart
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_page.dart';
import 'pages/nfc_page.dart'; 

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tu Aplicación',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/admin': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          if (arguments != null && arguments is Map<String, dynamic>) {
            return AdminPage(userData: arguments);
          } else {
            // Si no hay argumentos, redirigir al login
            return const LoginPage();
          }
        },
        '/nfc': (context) => const NfcPage(), // Nueva ruta para la página NFC
        // Agrega más rutas si es necesario
      },
    );
  }
}
