import 'package:flutter/material.dart';

import '../app/rutas.dart';
import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../logic/procesador_academico.dart';
import '../models/tarea.dart';
import '../widgets/curvas.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/resumen_carga.dart';
import '../widgets/tarjeta_tarea.dart';

/// Agenda: panorama, listado de tareas y estados vacíos cuidados.
class ConsultaResultadosScreen extends StatefulWidget {
  const ConsultaResultadosScreen({super.key});

  @override
  State<ConsultaResultadosScreen> createState() =>
      _ConsultaResultadosScreenState();
}

class _ConsultaResultadosScreenState extends State<ConsultaResultadosScreen> {
  Future<void> _completar(Tarea tarea, bool valor) async {
    final agenda = AgendaScope.of(context);
    try {
      await agenda.marcarCompletada(tarea.id, valor);
    } catch (error) {
      if (!mounted) return;
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
    final resumen = ProcesadorAcademico.resumir(agenda.tareas, DateTime.now());
    final nombre = agenda.nombreEstudiante.trim().isEmpty
        ? 'estudiante'
        : agenda.nombreEstudiante.trim();

    return Scaffold(
      appBar: EncabezadoApp(
        titulo: 'Tu agenda',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nueva tarea',
            color: PlanificaUTheme.acento,
            onPressed: () => Navigator.pushNamed(context, Rutas.registro),
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
              height: 176,
              child: CustomPaint(
                painter: const BandaCurvaPainter(
                  color: PlanificaUTheme.acentoSuave,
                  curva: 38,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hola, $nombre',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Así se ve tu carga académica hoy.',
                  style: TextStyle(color: PlanificaUTheme.tintaSuave),
                ),
                const SizedBox(height: 16),
                if (agenda.error != null) ...[
                  _AvisoBackend(
                    mensaje: agenda.error!,
                    onReintentar: agenda.reintentar,
                  ),
                  const SizedBox(height: 10),
                ],
                if (agenda.cargando)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: PlanificaUTheme.primario,
                      backgroundColor: PlanificaUTheme.primarioSuave,
                    ),
                  ),
                ResumenCarga(resumen: resumen),
                const SizedBox(height: 6),
                const SizedBox(
                  height: 20,
                  child: CustomPaint(painter: LineaCurvaPainter()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tus tareas',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: PlanificaUTheme.primarioSuave,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${agenda.tareas.length}',
                        style: const TextStyle(
                          color: PlanificaUTheme.primario,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 96),
                    children: [
                      if (!agenda.cargando && agenda.tareas.isEmpty)
                        _Vacio(
                          onTap: () =>
                              Navigator.pushNamed(context, Rutas.registro),
                        )
                      else
                        ...agenda.tareas.map(
                          (tarea) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TarjetaTarea(
                              tarea: tarea,
                              onCompletada: (value) => _completar(tarea, value),
                              onDetalle: () => Navigator.pushNamed(
                                context,
                                Rutas.detalleTarea,
                                arguments: tarea.id,
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _AvisoBackend extends StatelessWidget {
  const _AvisoBackend({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PlanificaUTheme.papel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PlanificaUTheme.prioridadMedia),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: PlanificaUTheme.prioridadMedia,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
          ),
          TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: PlanificaUTheme.papel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PlanificaUTheme.borde),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: PlanificaUTheme.acentoSuave,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checklist_rounded,
              size: 38,
              color: PlanificaUTheme.acento,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tu lista está en blanco',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Registra tu primera entrega y empieza a ver tus plazos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PlanificaUTheme.tintaSuave),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear primera tarea'),
          ),
        ],
      ),
    );
  }
}
