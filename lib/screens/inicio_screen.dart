import 'package:flutter/material.dart';

import '../app/rutas.dart';
import '../app/theme.dart';
import '../data/agenda_memoria.dart';
import '../widgets/encabezado_app.dart';

/// Pantalla 1: presentacion de PlanificaU y acceso a las funciones.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late final TextEditingController _nombre;
  var _nombreCargado = false;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_nombreCargado) {
      _nombre.text = AgendaScope.of(context).nombreEstudiante;
      _nombreCargado = true;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _irA(String ruta) {
    AgendaScope.of(context).actualizarNombre(_nombre.text);
    Navigator.pushNamed(context, ruta);
  }

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);

    return Scaffold(
      appBar: const EncabezadoApp(titulo: 'PlanificaU'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 42,
            backgroundColor: PlanificaUTheme.azulClaro,
            child: const Icon(
              Icons.school_rounded,
              size: 42,
              color: PlanificaUTheme.azul,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Organiza tus entregas academicas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Centraliza tareas, proyectos y examenes para reducir olvidos y problemas.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nombre,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Ingresa tu nombre',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _irA(Rutas.registro),
            icon: const Icon(Icons.add_task),
            label: const Text('Registrar tarea'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _irA(Rutas.consulta),
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Ver agenda y resultados'),
          ),
          const SizedBox(height: 16),
          Text(
            'Tareas en memoria: ${agenda.tareas.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
