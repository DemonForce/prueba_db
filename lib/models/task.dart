// models/task.dart
class Task {
  final int id;
  final int usuarioId;
  final String descripcion;
  final bool completada;
  final String? fechaCompletada;

  Task({
    required this.id,
    required this.usuarioId,
    required this.descripcion,
    required this.completada,
    this.fechaCompletada,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      usuarioId: json['usuario_id'],
      descripcion: json['descripcion'],
      completada: json['completada'] == 1 || json['completada'] == true,
      fechaCompletada: json['fecha_completada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'descripcion': descripcion,
      'completada': completada,
      'fecha_completada': fechaCompletada,
    };
  }
}
