import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../logic/formato_fecha.dart';
import '../logic/procesador_academico.dart';

/// Panorama académico: progreso, cargas y próxima entrega.
class ResumenCarga extends StatelessWidget {
  const ResumenCarga({super.key, required this.resumen});

  final ResumenAcademico resumen;

  @override
  Widget build(BuildContext context) {
    final proxima = resumen.proxima;
    final porcentaje = (resumen.progreso * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: PlanificaUTheme.papel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PlanificaUTheme.borde),
        boxShadow: [
          BoxShadow(
            color: PlanificaUTheme.tinta.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PANORAMA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: PlanificaUTheme.tintaSuave,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PlanificaUTheme.primarioSuave,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$porcentaje% listo',
                    style: const TextStyle(
                      color: PlanificaUTheme.primario,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 74,
                  height: 74,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: resumen.progreso,
                          strokeWidth: 8,
                          backgroundColor: PlanificaUTheme.primarioSuave,
                          color: PlanificaUTheme.acento,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${resumen.completadas} de ${resumen.total} tareas',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${resumen.pendientes} pendientes · '
                        '${resumen.vencidas} vencidas',
                        style: const TextStyle(
                          color: PlanificaUTheme.tintaSuave,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: PlanificaUTheme.borde, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _dato(
                    '${resumen.altas}',
                    'alta prioridad',
                    PlanificaUTheme.prioridadAlta,
                  ),
                ),
                Expanded(
                  child: _dato(
                    '${resumen.medias}',
                    'media',
                    PlanificaUTheme.prioridadMedia,
                  ),
                ),
                Expanded(
                  child: _dato(
                    '${resumen.bajas}',
                    'baja',
                    PlanificaUTheme.prioridadBaja,
                  ),
                ),
              ],
            ),
            if (proxima != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlanificaUTheme.acentoSuave,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_available_rounded,
                      color: PlanificaUTheme.acento,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRÓXIMA ENTREGA',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: PlanificaUTheme.acento,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${proxima.titulo} · ${FormatoFecha.corto(proxima.fechaEntrega)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dato(String valor, String etiqueta, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 11,
            color: PlanificaUTheme.tintaSuave,
          ),
        ),
      ],
    );
  }
}
