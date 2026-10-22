import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../logic/formato_fecha.dart';
import '../logic/procesador_academico.dart';

/// Bloque de resultados: progreso, vencidas y proxima entrega.
class ResumenCarga extends StatelessWidget {
  const ResumenCarga({super.key, required this.resumen});

  final ResumenAcademico resumen;

  @override
  Widget build(BuildContext context) {
    final proxima = resumen.proxima;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen academico',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: resumen.progreso,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
              color: PlanificaUTheme.azul,
              backgroundColor: PlanificaUTheme.azulSuave,
            ),
            const SizedBox(height: 8),
            Text(
              '${resumen.completadas} de ${resumen.total} tareas completadas',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Pendientes ${resumen.pendientes}', PlanificaUTheme.azul),
                _chip(
                  'Vencidas ${resumen.vencidas}',
                  PlanificaUTheme.prioridadAlta,
                ),
                _chip('Alta ${resumen.altas}', PlanificaUTheme.prioridadAlta),
                _chip(
                  'Media ${resumen.medias}',
                  PlanificaUTheme.prioridadMedia,
                ),
                _chip('Baja ${resumen.bajas}', PlanificaUTheme.prioridadBaja),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              proxima == null
                  ? 'No hay entregas pendientes.'
                  : 'Proxima entrega: ${proxima.titulo} (${FormatoFecha.largo(proxima.fechaEntrega)})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String texto, Color color) {
    return Chip(
      label: Text(texto),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}
