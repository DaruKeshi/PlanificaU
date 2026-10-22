import 'package:flutter/material.dart';

import 'app/planificau_app.dart';
import 'data/agenda_memoria.dart';

/// Punto de entrada.
/// El resto del codigo vive en carpetas separadas (app, models, data, logic, screens, widgets).
void main() {
  runApp(PlanificaUApp(agenda: AgendaMemoria()));
}
