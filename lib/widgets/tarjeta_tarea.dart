import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../logic/formato_fecha.dart';
import '../logic/procesador_academico.dart';
import '../models/tarea.dart';

/// Componente personalizado 2: tarjeta de tarea con color de prioridad.
class TarjetaTarea extends StatelessWidget {
  const TarjetaTarea({
    super.key,
    required this.tarea,
    required this.onCompletada,
  });

  final Tarea tarea;
  final ValueChanged<bool> onCompletada;

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final plazo = ProcesadorAcademico.etiquetaPlazo(tarea, ahora);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: tarea.prioridad.color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
            ),
            Checkbox(
              value: tarea.completada,
              activeColor: PlanificaUTheme.azul,
              onChanged: (value) => onCompletada(value ?? false),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: tarea.completada
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tarea.materia} · ${FormatoFecha.corto(tarea.fechaEntrega)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plazo,
                      style: TextStyle(
                        color: ProcesadorAcademico.estaVencida(tarea, ahora)
                            ? PlanificaUTheme.prioridadAlta
                            : PlanificaUTheme.azul,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
