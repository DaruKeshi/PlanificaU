import 'prioridad.dart';


class Tarea {
  Tarea({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.descripcion,
    required this.fechaEntrega,
    required this.prioridad,
    this.completada = false,
  });

  final String id;
  final String titulo;
  final String materia;
  final String descripcion;
  final DateTime fechaEntrega;
  final Prioridad prioridad;
  bool completada;
}
