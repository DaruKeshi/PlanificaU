import 'package:flutter/material.dart';

import '../app/rutas.dart';
import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../models/materia.dart';
import '../widgets/curvas.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/encabezado_app.dart';

/// Pantalla de detalle de una materia: cortes, notas y acumulado.
class DetalleMateriaScreen extends StatelessWidget {
  const DetalleMateriaScreen({super.key, required this.id});

  final String id;

  Future<void> _eliminar(BuildContext context) async {
    final confirmado = await confirmarEliminacion(
      context,
      titulo: '¿Eliminar la materia?',
      mensaje: 'Se borrarán la materia y todas sus notas de Firestore. No se puede deshacer.',
    );
    if (confirmado != true || !context.mounted) return;

    try {
      await AgendaScope.of(context).eliminarMateria(id);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Materia eliminada de Firestore.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AgendaFirestore.mensaje(error)),
          backgroundColor: PlanificaUTheme.prioridadAlta,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);
    Materia? materia;
    for (final candidata in agenda.materias) {
      if (candidata.id == id) {
        materia = candidata;
        break;
      }
    }

    if (materia == null) {
      return Scaffold(
        appBar: const EncabezadoApp(
          titulo: 'Detalle de materia',
          mostrarAtras: true,
        ),
        body: const Center(child: Text('Esta materia ya no está en tu lista.')),
      );
    }

    final color = materia.aprobada
        ? PlanificaUTheme.primario
        : PlanificaUTheme.acento;

    return Scaffold(
      appBar: EncabezadoApp(
        titulo: 'Detalle de materia',
        mostrarAtras: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            color: PlanificaUTheme.primario,
            onPressed: () => Navigator.pushNamed(
              context,
              Rutas.editarMateria,
              arguments: id,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 150,
              child: CustomPaint(
                painter: const BandaCurvaPainter(
                  color: PlanificaUTheme.acentoSuave,
                  curva: 34,
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
            children: [
              ClipPath(
                clipper: const CurvaHeroClipper(),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: PlanificaUTheme.hero,
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materia.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          materia.estado,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _dato(
                            materia.promedio.toStringAsFixed(1),
                            'promedio',
                          ),
                          const SizedBox(width: 24),
                          _dato(
                            materia.acumulado.toStringAsFixed(1),
                            'acumulado',
                          ),
                          const SizedBox(width: 24),
                          _dato(
                            '${materia.cortesEvaluados}/${materia.cortes.length}',
                            'cortes',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tus cortes',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Escala 0 – ${_numero(materia.escalaMaxima)} · Aprueba ${materia.notaAprobacion.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PlanificaUTheme.tintaSuave,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...materia.cortes.map(
                (corte) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PlanificaUTheme.papel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PlanificaUTheme.borde),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: PlanificaUTheme.primarioSuave,
                        child: Text(
                          '${corte.numero}',
                          style: const TextStyle(
                            color: PlanificaUTheme.primario,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              corte.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Peso ${_porcentajeTexto(materia!.porcentajeDe(corte))}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: PlanificaUTheme.tintaSuave,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        corte.nota == null
                            ? 'Sin nota'
                            : corte.nota!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: corte.nota == null
                              ? PlanificaUTheme.tintaSuave
                              : color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                height: 34,
                child: CustomPaint(painter: LineaCurvaPainter()),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  Rutas.editarMateria,
                  arguments: id,
                ),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Editar materia y notas'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _eliminar(context),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar materia'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: PlanificaUTheme.prioridadAlta,
                  side: const BorderSide(color: PlanificaUTheme.prioridadAlta),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato(String valor, String etiqueta) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        valor,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        etiqueta,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 11,
        ),
      ),
    ],
  );

  String _numero(double valor) =>
      valor % 1 == 0 ? valor.toInt().toString() : valor.toString();

  String _porcentajeTexto(double valor) =>
      valor % 1 == 0 ? valor.toInt().toString() : valor.toStringAsFixed(1);
}
