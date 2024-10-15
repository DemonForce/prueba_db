import 'package:flutter/material.dart';
import 'package:login/providers/database_provider.dart';
import 'package:login/models/todo_item.dart';

class AdminPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdminPage({super.key, required this.userData});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<TodoItem> _todoItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserTasks();
    });
  }

  Future<void> _loadUserTasks() async {
    try {
      final dbProvider = DatabaseProvider.of(context);
      final tasks = await dbProvider.apiService.getUserTasks(widget.userData['id']);

      setState(() {
        _todoItems.clear();
        _todoItems.addAll(tasks.map((task) => TodoItem.fromJson(task)));
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
      final newTask = await dbProvider.apiService.createTask(widget.userData['id'], task);
      setState(() {
        _todoItems.add(TodoItem.fromJson(newTask));
      });
      _showSuccessSnackBar('Tarea guardada exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al guardar tarea: $e');
    }
  }

  void _removeTodoItem(int index) {
    if (index >= 0 && index < _todoItems.length) {
      final taskId = _todoItems[index].id;
      _deleteTaskFromDatabase(taskId, index);
    }
  }

  Future<void> _deleteTaskFromDatabase(int taskId, int index) async {
    try {
      final dbProvider = DatabaseProvider.of(context);
      await dbProvider.apiService.deleteTask(taskId);
      setState(() {
        _todoItems.removeAt(index);
      });
      _showSuccessSnackBar('Tarea eliminada exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al eliminar tarea: $e');
    }
  }

  void _toggleTaskCompletion(int index) {
    if (index >= 0 && index < _todoItems.length) {
      final taskId = _todoItems[index].id;
      final isCurrentlyCompleted = _todoItems[index].completada;
      final newCompletionStatus = !isCurrentlyCompleted;
      _updateTaskCompletionInDatabase(taskId, newCompletionStatus, index);
    }
  }

  Future<void> _updateTaskCompletionInDatabase(
      int taskId, bool isCompleted, int index) async {
    try {
      final dbProvider = DatabaseProvider.of(context);
      await dbProvider.apiService.updateTask(taskId, isCompleted);
      setState(() {
        _todoItems[index].completada = isCompleted;
        _todoItems[index].fechaCompletada = isCompleted ? DateTime.now() : null;
      });
      _showSuccessSnackBar('Tarea actualizada exitosamente');
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

  Widget _buildTodoItem(TodoItem todoItem, int index) {
    return ListTile(
      title: Text(
        todoItem.descripcion,
        style: TextStyle(
          color: Colors.white,
          decoration:
              todoItem.completada ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      subtitle: todoItem.completada && todoItem.fechaCompletada != null
          ? Text(
              'Completada el ${todoItem.fechaCompletada!.toLocal().toString().split('.')[0]}',
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
              todoItem.completada ? Icons.check_circle : Icons.circle_outlined,
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