import 'package:flutter/material.dart';

import '../app/rutas.dart';
import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../widgets/curvas.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/tarjeta_materia.dart';

/// Pestaña de notas: guía de materias aprobadas y acumulados por corte.
class NotasScreen extends StatelessWidget {
  const NotasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);
    final materias = agenda.materias;
    final nombre = agenda.nombreEstudiante.trim().isEmpty
        ? 'estudiante'
        : agenda.nombreEstudiante.trim();
    final aprobadas = materias.where((m) => m.aprobada).length;
    final evaluadas = materias.where((m) => m.cortesEvaluados > 0).toList();
    final promedioGeneral = evaluadas.isEmpty
        ? 0.0
        : evaluadas.fold<double>(0, (suma, m) => suma + m.promedio) /
              evaluadas.length;

    return Scaffold(
      appBar: EncabezadoApp(
        titulo: 'Tus notas',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nueva materia',
            color: PlanificaUTheme.acento,
            onPressed: () =>
                Navigator.pushNamed(context, Rutas.registroMateria),
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
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hola, $nombre',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Así va tu acumulado en cada materia.',
                  style: TextStyle(color: PlanificaUTheme.tintaSuave),
                ),
                const SizedBox(height: 20),
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
                ClipPath(
                  clipper: const CurvaHeroClipper(),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: PlanificaUTheme.hero,
                    ),
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TU SEMESTRE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Cada corte cuenta,\nvélo todo aquí.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _dato('$aprobadas', 'aprobadas'),
                            const SizedBox(width: 22),
                            _dato('${materias.length - aprobadas}', 'en curso'),
                            const SizedBox(width: 22),
                            _dato(
                              promedioGeneral.toStringAsFixed(1),
                              'promedio general',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const SizedBox(
                  height: 20,
                  child: CustomPaint(painter: LineaCurvaPainter()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tus materias',
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
                        '${materias.length}',
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
                      if (!agenda.cargando && materias.isEmpty)
                        _Vacio(
                          onTap: () => Navigator.pushNamed(
                            context,
                            Rutas.registroMateria,
                          ),
                        )
                      else
                        ...materias.map(
                          (materia) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TarjetaMateria(
                              materia: materia,
                              onDetalle: () => Navigator.pushNamed(
                                context,
                                Rutas.detalleMateria,
                                arguments: materia.id,
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

  Widget _dato(String valor, String etiqueta) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        valor,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
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
              Icons.school_outlined,
              size: 38,
              color: PlanificaUTheme.acento,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay materias',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Registra una materia, sus cortes y cuánto vale cada uno.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PlanificaUTheme.tintaSuave),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear primera materia'),
          ),
        ],
      ),
    );
  }
}
