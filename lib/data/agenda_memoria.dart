import 'package:flutter/material.dart';

import '../models/tarea.dart';

/// Lista de tareas y nombre del estudiante.
class AgendaMemoria extends ChangeNotifier {
  final List<Tarea> _tareas = [];
  String nombreEstudiante = '';

  List<Tarea> get tareas => List.unmodifiable(_tareas);

  void actualizarNombre(String nombre) {
    nombreEstudiante = nombre.trim();
    notifyListeners();
  }

  void agregar(Tarea tarea) {
    _tareas.add(tarea);
    notifyListeners();
  }

  void marcarCompletada(String id, bool value) {
    final tarea = _tareas.where((item) => item.id == id);
    if (tarea.isEmpty) return;
    tarea.first.completada = value;
    notifyListeners();
  }
}

/// Expone [AgendaMemoria] a las pantallas sin paquetes extra.
class AgendaScope extends InheritedNotifier<AgendaMemoria> {
  const AgendaScope({
    super.key,
    required AgendaMemoria agenda,
    required super.child,
  }) : super(notifier: agenda);

  static AgendaMemoria of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AgendaScope>();
    assert(scope != null, 'AgendaScope no encontrado');
    return scope!.notifier!;
  }
}
