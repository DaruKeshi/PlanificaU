import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/formulario_materia.dart';

/// Pantalla de registro de una materia y sus cortes.
class RegistroMateriaScreen extends StatelessWidget {
  const RegistroMateriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);

    return Scaffold(
      appBar: const EncabezadoApp(titulo: 'Nueva materia', mostrarAtras: true),
      body: FormularioMateria(
        guardar: agenda.agregarMateria,
        alGuardar: (materia) {
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
                title: const Text('Materia registrada'),
                content: const Text(
                  'Ya puedes ir anotando las notas de cada corte.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.of(context).pop(materia);
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
