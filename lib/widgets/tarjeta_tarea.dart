import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../logic/formato_fecha.dart';
import '../logic/procesador_academico.dart';
import '../models/tarea.dart';


class TarjetaTarea extends StatelessWidget {
  const TarjetaTarea({
    super.key,
    required this.tarea,
    required this.onCompletada,
    this.onDetalle,
  });

  final Tarea tarea;
  final ValueChanged<bool> onCompletada;
  final VoidCallback? onDetalle;

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final plazo = ProcesadorAcademico.etiquetaPlazo(tarea, ahora);
    final vencida = ProcesadorAcademico.estaVencida(tarea, ahora);
    final colorPlazo = vencida
        ? PlanificaUTheme.prioridadAlta
        : PlanificaUTheme.primario;

    return Container(
      decoration: BoxDecoration(
        color: PlanificaUTheme.papel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PlanificaUTheme.borde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 58,
              decoration: BoxDecoration(
                color: tarea.prioridad.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 26,
              height: 26,
              child: Checkbox(
                value: tarea.completada,
                activeColor: PlanificaUTheme.primario,
                side: const BorderSide(color: PlanificaUTheme.borde),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                onChanged: (value) => onCompletada(value ?? false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarea.titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: tarea.completada
                          ? PlanificaUTheme.tintaSuave
                          : PlanificaUTheme.tinta,
                      decoration: tarea.completada
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 14,
                        color: PlanificaUTheme.tintaSuave,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tarea.materia,
                        style: const TextStyle(
                          fontSize: 12,
                          color: PlanificaUTheme.tintaSuave,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: PlanificaUTheme.fondo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          FormatoFecha.corto(tarea.fechaEntrega),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!tarea.completada) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          vencida ? Icons.warning_amber_rounded : Icons.schedule,
                          size: 14,
                          color: colorPlazo,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          plazo,
                          style: TextStyle(
                            color: colorPlazo,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onDetalle != null)
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Ver detalle',
                color: PlanificaUTheme.tintaSuave,
                onPressed: onDetalle,
              ),
          ],
        ),
      ),
    );
  }
}
