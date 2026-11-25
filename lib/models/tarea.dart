import 'package:cloud_firestore/cloud_firestore.dart';

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
  final bool completada;

  /// Convierte un documento de Firestore al modelo que usa la interfaz.
  factory Tarea.desdeFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final datos = doc.data() ?? <String, dynamic>{};
    final fecha = datos['fechaEntrega'];

    return Tarea(
      id: doc.id,
      titulo: (datos['titulo'] as String?) ?? '',
      materia: (datos['materia'] as String?) ?? '',
      descripcion: (datos['descripcion'] as String?) ?? '',
      fechaEntrega: fecha is Timestamp
          ? fecha.toDate()
          : fecha is DateTime
              ? fecha
              : DateTime.now(),
      prioridad: Prioridad.values.firstWhere(
        (value) => value.name == datos['prioridad'],
        orElse: () => Prioridad.media,
      ),
      completada: datos['completada'] as bool? ?? false,
    );
  }

  /// Datos guardados en `usuarios/{uid}/tareas/{id}`.
  Map<String, dynamic> paraFirestore() => {
        ...paraActualizacion(),
        'creadoEn': FieldValue.serverTimestamp(),
      };

  /// Campos editables al actualizar; conserva `creadoEn` original.
  Map<String, dynamic> paraActualizacion() => {
        'titulo': titulo,
        'materia': materia,
        'descripcion': descripcion,
        'fechaEntrega': Timestamp.fromDate(fechaEntrega),
        'prioridad': prioridad.name,
        'completada': completada,
      };

  Tarea conCompletada(bool valor) => Tarea(
        id: id,
        titulo: titulo,
        materia: materia,
        descripcion: descripcion,
        fechaEntrega: fechaEntrega,
        prioridad: prioridad,
        completada: valor,
      );
}
