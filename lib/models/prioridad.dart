import 'package:flutter/material.dart';

import '../app/theme.dart';

enum Prioridad {
  alta,
  media,
  baja;

  String get etiqueta => switch (this) {
    Prioridad.alta => 'Alta',
    Prioridad.media => 'Media',
    Prioridad.baja => 'Baja',
  };

  Color get color => switch (this) {
    Prioridad.alta => PlanificaUTheme.prioridadAlta,
    Prioridad.media => PlanificaUTheme.prioridadMedia,
    Prioridad.baja => PlanificaUTheme.prioridadBaja,
  };
}
