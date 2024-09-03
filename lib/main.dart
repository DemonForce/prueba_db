import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PostgreSQLConnection connection;

  @override
  void initState() {
    super.initState();
    connection = PostgreSQLConnection(
      'junction.proxy.rlwy.net', // host
      44486, // port
      'railway', // database name
      username: 'postgres', // username
      password: 'gHGXaBNPGOqpooWANcIvrNomMwLryXXr', // password
    );
    _openConnection();
  }

  Future<void> _openConnection() async {
    try {
      await connection.open();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conexión a la base de datos abierta')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar: $e')),
        );
      }
    }
  }

  Future<void> insertUser() async {
    try {
      await connection.query(
        'INSERT INTO usuarios(username, password, nivel) VALUES (@username, @password, @nivel)',
        substitutionValues: {
          'username': 'Joaquin12',
          'password': 'john1235',
          'nivel': 'admin'
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario insertado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al insertar usuario: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    connection.close().then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conexión a la base de datos cerrada')),
        );
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi App hola'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hola mundo!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: insertUser,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Insertar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
