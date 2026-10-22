import 'package:flutter/material.dart';

import '../models/prioridad.dart';

/// Componente personalizado 1: chips de prioridad Alta / Media / Baja.
class SelectorPrioridad extends StatelessWidget {
  const SelectorPrioridad({
    super.key,
    required this.valor,
    required this.onChanged,
  });

  final Prioridad? valor;
  final ValueChanged<Prioridad> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: Prioridad.values.map((prioridad) {
        final seleccionado = valor == prioridad;
        return ChoiceChip(
          label: Text(prioridad.etiqueta),
          selected: seleccionado,
          selectedColor: prioridad.color.withValues(alpha: 0.25),
          labelStyle: TextStyle(
            color: prioridad.color,
            fontWeight: FontWeight.w700,
          ),
          onSelected: (_) => onChanged(prioridad),
        );
      }).toList(),
    );
  }
}
