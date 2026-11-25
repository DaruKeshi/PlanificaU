import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../models/tarea.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/formulario_tarea.dart';

/// Pantalla de edición: modifica una tarea existente en Firestore.
class EditarTareaScreen extends StatelessWidget {
  const EditarTareaScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);
    Tarea? tarea;
    for (final candidata in agenda.tareas) {
      if (candidata.id == id) {
        tarea = candidata;
        break;
      }
    }

    if (tarea == null) {
      return Scaffold(
        appBar: const EncabezadoApp(titulo: 'Editar tarea', mostrarAtras: true),
        body: const Center(child: Text('Esta tarea ya no está en tu agenda.')),
      );
    }

    return Scaffold(
      appBar: const EncabezadoApp(titulo: 'Editar tarea', mostrarAtras: true),
      body: FormularioTarea(
        tarea: tarea,
        guardar: agenda.actualizarTarea,
        alGuardar: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cambios guardados en Firestore: ${tarea!.titulo}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: PlanificaUTheme.primario,
            ),
          );
        },
      ),
    );
  }
}
