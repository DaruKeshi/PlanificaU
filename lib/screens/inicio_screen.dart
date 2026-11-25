import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/rutas.dart';
import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../logic/procesador_academico.dart';
import '../widgets/curvas.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/marca_planificau.dart';

/// Pantalla de inicio: bienvenida, nombre del estudiante y accesos rápidos.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key, this.onIrAAgenda, this.onIrANotas});

  final VoidCallback? onIrAAgenda;
  final VoidCallback? onIrANotas;

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
    final agenda = AgendaScope.of(context);
    // El nombre llega desde Firestore después del primer snapshot.
    if (!_nombreCargado && !agenda.cargando) {
      _nombre.text = agenda.nombreEstudiante;
      _nombreCargado = true;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _irANuevaTarea() {
    AgendaScope.of(context).actualizarNombre(_nombre.text);
    Navigator.pushNamed(context, Rutas.registro);
  }

  void _irAAgenda() {
    AgendaScope.of(context).actualizarNombre(_nombre.text);
    if (widget.onIrAAgenda != null) {
      widget.onIrAAgenda!();
    } else {
      Navigator.pushNamed(context, Rutas.consulta);
    }
  }

  void _irANotas() {
    AgendaScope.of(context).actualizarNombre(_nombre.text);
    if (widget.onIrANotas != null) {
      widget.onIrANotas!();
    } else {
      Navigator.pushNamed(context, Rutas.registroMateria);
    }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);
    final resumen = ProcesadorAcademico.resumir(agenda.tareas, DateTime.now());

    return Scaffold(
      appBar: EncabezadoApp(
        titulo: 'PlanificaU',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            color: PlanificaUTheme.tintaSuave,
            onPressed: _cerrarSesion,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: MarcaPlanificau(tamano: 34),
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
              height: 186,
              child: CustomPaint(
                painter: const BandaCurvaPainter(
                  color: PlanificaUTheme.primarioSuave,
                  curva: 42,
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final ancho = constraints.maxWidth;
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: ancho,
                  height: 560,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Hola${agenda.nombreEstudiante.trim().isEmpty ? '' : ', ${agenda.nombreEstudiante.trim()}'}',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Un lugar tranquilo para ordenar tus entregas.',
                        ),
                        const SizedBox(height: 22),

                        // Tarjeta destacada
                        ClipPath(
                          clipper: const CurvaHeroClipper(),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: PlanificaUTheme.hero,
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -30,
                                  top: -40,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: PlanificaUTheme.acento.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    20,
                                    20,
                                    26,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          'ESTE SEMESTRE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Todo bajo control,\nuna tarea a la vez.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          height: 1.15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _datoHero(
                                            '${resumen.pendientes}',
                                            'pendientes',
                                          ),
                                          const SizedBox(width: 22),
                                          _datoHero(
                                            '${resumen.completadas}',
                                            'listas',
                                          ),
                                          const SizedBox(width: 22),
                                          _datoHero(
                                            '${resumen.vencidas}',
                                            'vencidas',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Nombre
                        Container(
                          decoration: BoxDecoration(
                            color: PlanificaUTheme.papel,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: PlanificaUTheme.borde),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TU NOMBRE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: PlanificaUTheme.tintaSuave,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nombre,
                                textCapitalization: TextCapitalization.words,
                                onChanged: (value) =>
                                    agenda.actualizarNombre(value),
                                decoration: const InputDecoration(
                                  labelText: 'Ingresa tu nombre',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Accesos rápidos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _Acceso(
                                icono: Icons.add_task_rounded,
                                titulo: 'Nueva tarea',
                                color: PlanificaUTheme.acento,
                                onTap: _irANuevaTarea,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _Acceso(
                                icono: Icons.calendar_month_rounded,
                                titulo: 'Ver agenda',
                                color: PlanificaUTheme.primario,
                                onTap: _irAAgenda,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _Acceso(
                                icono: Icons.school_outlined,
                                titulo: 'Ver notas',
                                color: PlanificaUTheme.prioridadMedia,
                                onTap: _irANotas,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _datoHero(String valor, String etiqueta) {
    return Column(
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
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Acceso extends StatelessWidget {
  const _Acceso({
    required this.icono,
    required this.titulo,
    required this.color,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PlanificaUTheme.papel,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PlanificaUTheme.borde),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
