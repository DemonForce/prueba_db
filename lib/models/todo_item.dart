class TodoItem {
  final int id;
  final String descripcion;
  bool completada;
  DateTime? fechaCompletada;

  TodoItem({
    required this.id,
    required this.descripcion,
    required this.completada,
    this.fechaCompletada,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      descripcion: json['descripcion'],
      completada: json['completada'],
      fechaCompletada: json['fecha_completada'] != null
          ? DateTime.parse(json['fecha_completada'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'completada': completada,
      'fecha_completada': fechaCompletada?.toIso8601String(),
    };
  }
}