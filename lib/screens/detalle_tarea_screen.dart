import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../logic/formato_fecha.dart';
import '../logic/procesador_academico.dart';
import '../models/tarea.dart';
import '../widgets/curvas.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/encabezado_app.dart';
import '../app/rutas.dart';

/// Pantalla de detalle: muestra toda la información de una tarea guardada.
class DetalleTareaScreen extends StatelessWidget {
  const DetalleTareaScreen({super.key, required this.id});

  final String id;

  Future<void> _eliminar(BuildContext context) async {
    final confirmado = await confirmarEliminacion(
      context,
      titulo: '¿Eliminar la tarea?',
      mensaje: 'La tarea se borrará de tu agenda y de Firestore. No se puede deshacer.',
    );
    if (confirmado != true || !context.mounted) return;

    try {
      await AgendaScope.of(context).eliminarTarea(id);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea eliminada de Firestore.'),
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
    Tarea? tarea;
    for (final candidata in agenda.tareas) {
      if (candidata.id == id) {
        tarea = candidata;
        break;
      }
    }

    if (tarea == null) {
      return Scaffold(
        appBar: const EncabezadoApp(
          titulo: 'Detalle de tarea',
          mostrarAtras: true,
        ),
        body: const Center(child: Text('Esta tarea ya no está en tu agenda.')),
      );
    }

    final vencida = ProcesadorAcademico.estaVencida(tarea, DateTime.now());

    return Scaffold(
      appBar: EncabezadoApp(
        titulo: 'Detalle de tarea',
        mostrarAtras: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            color: PlanificaUTheme.primario,
            onPressed: () =>
                Navigator.pushNamed(context, Rutas.editarTarea, arguments: id),
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
                  color: PlanificaUTheme.primarioSuave,
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
                        tarea.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        children: [
                          _Etiqueta(
                            texto: tarea.completada
                                ? 'Completada'
                                : 'Pendiente',
                            fondo: tarea.completada
                                ? PlanificaUTheme.primarioSuave
                                : PlanificaUTheme.acentoSuave,
                            color: tarea.completada
                                ? PlanificaUTheme.primario
                                : PlanificaUTheme.acentoTexto,
                          ),
                          if (vencida && !tarea.completada)
                            _Etiqueta(
                              texto: 'Vencida',
                              fondo: PlanificaUTheme.prioridadAltaSuave,
                              color: PlanificaUTheme.prioridadAltaTexto,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _Dato(
                icono: Icons.menu_book_outlined,
                etiqueta: 'Materia',
                valor: tarea.materia,
              ),
              _Dato(
                icono: Icons.event_rounded,
                etiqueta: 'Fecha de entrega',
                valor: FormatoFecha.largo(tarea.fechaEntrega),
              ),
              _Dato(
                icono: Icons.flag_outlined,
                etiqueta: 'Prioridad',
                valor: tarea.prioridad.etiqueta,
                color: tarea.prioridad.color,
              ),
              _Dato(
                icono: Icons.notes_rounded,
                etiqueta: 'Descripción',
                valor: tarea.descripcion.isEmpty
                    ? 'Sin descripción'
                    : tarea.descripcion,
              ),
              const SizedBox(height: 12),
              const SizedBox(
                height: 34,
                child: CustomPaint(painter: LineaCurvaPainter()),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  Rutas.editarTarea,
                  arguments: id,
                ),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Editar tarea'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _eliminar(context),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar tarea'),
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
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.texto,
    required this.fondo,
    required this.color,
  });

  final String texto;
  final Color fondo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.color,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PlanificaUTheme.papel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PlanificaUTheme.borde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color ?? PlanificaUTheme.primario, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: PlanificaUTheme.tintaSuave,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
