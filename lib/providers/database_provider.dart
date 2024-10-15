import 'package:flutter/material.dart';
import 'package:login/services/api_service.dart';

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
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}