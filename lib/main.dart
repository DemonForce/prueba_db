import 'package:flutter/material.dart';
import 'package:login/providers/database_provider.dart';
import 'package:login/screens/login_page.dart';

void main() {
  runApp(const DatabaseProvider(child: MainApp()));
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