import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/materia.dart';

class TarjetaMateria extends StatelessWidget {
  const TarjetaMateria({
    super.key,
    required this.materia,
    required this.onDetalle,
  });

  final Materia materia;
  final VoidCallback onDetalle;

  @override
  Widget build(BuildContext context) {
    final color = materia.aprobada
        ? PlanificaUTheme.primario
        : PlanificaUTheme.acento;

    return Material(
      color: PlanificaUTheme.papel,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onDetalle,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PlanificaUTheme.borde),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  materia.aprobada
                      ? Icons.verified_rounded
                      : Icons.school_outlined,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            materia.nombre,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            materia.estado,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Promedio ${materia.promedio.toStringAsFixed(1)} / ${_numero(materia.escalaMaxima)}  ·  Acumulado ${materia.acumulado.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: PlanificaUTheme.tintaSuave,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: materia.avance,
                        minHeight: 6,
                        color: color,
                        backgroundColor: PlanificaUTheme.fondo,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${materia.cortesEvaluados} de ${materia.cortes.length} cortes evaluados',
                      style: const TextStyle(
                        fontSize: 11,
                        color: PlanificaUTheme.tintaSuave,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: PlanificaUTheme.tintaSuave),
            ],
          ),
        ),
      ),
    );
  }

  String _numero(double valor) =>
      valor % 1 == 0 ? valor.toInt().toString() : valor.toString();
}
