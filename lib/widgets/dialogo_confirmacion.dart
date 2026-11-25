import 'package:flutter/material.dart';

import '../app/theme.dart';

Future<bool?> confirmarEliminacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: PlanificaUTheme.papel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: PlanificaUTheme.prioridadAlta,
          size: 38,
        ),
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: PlanificaUTheme.prioridadAlta,
              minimumSize: const Size(100, 44),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );
}
