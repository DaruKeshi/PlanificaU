import 'package:flutter/material.dart';

import '../app/rutas.dart';
import '../app/theme.dart';
import '../data/agenda_memoria.dart';
import '../logic/procesador_academico.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/resumen_carga.dart';
import '../widgets/tarjeta_tarea.dart';

/// Pantalla 3: consulta de tareas y resultados del procesamiento.
class ConsultaResultadosScreen extends StatelessWidget {
  const ConsultaResultadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);
    final resumen = ProcesadorAcademico.resumir(agenda.tareas, DateTime.now());
    final nombre = agenda.nombreEstudiante.isEmpty
        ? 'estudiante'
        : agenda.nombreEstudiante;

    return Scaffold(
      appBar: const EncabezadoApp(titulo: 'Agenda', mostrarAtras: true),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PlanificaUTheme.azul,
        onPressed: () => Navigator.pushNamed(context, Rutas.registro),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hola, $nombre',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ResumenCarga(resumen: resumen),
          const SizedBox(height: 16),
          const Text(
            'Tareas registradas',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (agenda.tareas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Aun no hay tareas. Registra la primera para ver plazos y carga academica.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ...agenda.tareas.map(
              (tarea) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TarjetaTarea(
                  tarea: tarea,
                  onCompletada: (value) =>
                      agenda.marcarCompletada(tarea.id, value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
