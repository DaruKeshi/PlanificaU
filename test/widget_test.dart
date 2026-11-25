import 'package:flutter_test/flutter_test.dart';
import 'package:planificau/logic/procesador_academico.dart';
import 'package:planificau/models/prioridad.dart';
import 'package:planificau/models/tarea.dart';

void main() {
  test('El resumen separa pendientes, completadas y vencidas', () {
    final ahora = DateTime(2026, 11, 24);
    final tareas = [
      Tarea(
        id: '1',
        titulo: 'Ensayo',
        materia: 'Lengua',
        descripcion: '',
        fechaEntrega: ahora.add(const Duration(days: 1)),
        prioridad: Prioridad.alta,
      ),
      Tarea(
        id: '2',
        titulo: 'Cuestionario',
        materia: 'Historia',
        descripcion: '',
        fechaEntrega: ahora.subtract(const Duration(days: 1)),
        prioridad: Prioridad.media,
        completada: true,
      ),
      Tarea(
        id: '3',
        titulo: 'Práctica',
        materia: 'Matemáticas',
        descripcion: '',
        fechaEntrega: ahora.subtract(const Duration(days: 2)),
        prioridad: Prioridad.baja,
      ),
    ];

    final resumen = ProcesadorAcademico.resumir(tareas, ahora);

    expect(resumen.total, 3);
    expect(resumen.completadas, 1);
    expect(resumen.pendientes, 2);
    expect(resumen.vencidas, 1);
    expect(resumen.altas, 1);
    expect(resumen.proxima?.id, '3');
  });
}
