// main.dart
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_page.dart';

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
          final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AdminPage(userData: userData);
        },
        // Agrega más rutas si es necesario
      },
    );
  }
}
