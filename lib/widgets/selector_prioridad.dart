import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/prioridad.dart';

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
      spacing: 10,
      children: Prioridad.values.map((prioridad) {
        final seleccionado = valor == prioridad;
        return Material(
          color: seleccionado
              ? prioridad.color.withValues(alpha: 0.12)
              : PlanificaUTheme.papel,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(prioridad),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: seleccionado ? prioridad.color : PlanificaUTheme.borde,
                  width: seleccionado ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: prioridad.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    prioridad.etiqueta,
                    style: TextStyle(
                      color: seleccionado ? prioridad.color : PlanificaUTheme.tintaSuave,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
