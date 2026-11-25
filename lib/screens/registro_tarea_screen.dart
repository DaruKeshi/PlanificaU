import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/formulario_tarea.dart';

/// Pantalla de registro: crea una tarea nueva en Firestore.
class RegistroTareaScreen extends StatelessWidget {
  const RegistroTareaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);

    return Scaffold(
      appBar: const EncabezadoApp(titulo: 'Nueva tarea', mostrarAtras: true),
      body: FormularioTarea(
        guardar: agenda.agregar,
        alGuardar: () {
          showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                backgroundColor: PlanificaUTheme.papel,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: PlanificaUTheme.primario,
                  size: 40,
                ),
                title: const Text('Tarea registrada'),
                content: const Text(
                  'Ya aparece en tu agenda con su plazo y prioridad.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    child: const Text('Listo'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
