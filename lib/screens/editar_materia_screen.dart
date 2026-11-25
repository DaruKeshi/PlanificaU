import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../models/materia.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/formulario_materia.dart';

/// Pantalla de edición de una materia existente en Firestore.
class EditarMateriaScreen extends StatelessWidget {
  const EditarMateriaScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);
    Materia? materia;
    for (final candidata in agenda.materias) {
      if (candidata.id == id) {
        materia = candidata;
        break;
      }
    }

    if (materia == null) {
      return Scaffold(
        appBar: const EncabezadoApp(
          titulo: 'Editar materia',
          mostrarAtras: true,
        ),
        body: const Center(child: Text('Esta materia ya no está en tu lista.')),
      );
    }

    return Scaffold(
      appBar: const EncabezadoApp(titulo: 'Editar materia', mostrarAtras: true),
      body: FormularioMateria(
        materia: materia,
        guardar: agenda.actualizarMateria,
        alGuardar: (materiaGuardada) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cambios guardados en Firestore: ${materiaGuardada.nombre}',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: PlanificaUTheme.primario,
            ),
          );
        },
      ),
    );
  }
}
