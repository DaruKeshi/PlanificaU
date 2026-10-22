import 'package:flutter/material.dart';

import '../data/agenda_memoria.dart';
import '../screens/consulta_resultados_screen.dart';
import '../screens/inicio_screen.dart';
import '../screens/registro_tarea_screen.dart';
import 'rutas.dart';
import 'theme.dart';

class PlanificaUApp extends StatelessWidget {
  const PlanificaUApp({super.key, required this.agenda});

  final AgendaMemoria agenda;

  @override
  Widget build(BuildContext context) {
    return AgendaScope(
      agenda: agenda,
      child: MaterialApp(
        title: 'PlanificaU',
        debugShowCheckedModeBanner: false,
        theme: PlanificaUTheme.material,
        initialRoute: Rutas.inicio,
        routes: {
          Rutas.inicio: (_) => const InicioScreen(),
          Rutas.registro: (_) => const RegistroTareaScreen(),
          Rutas.consulta: (_) => const ConsultaResultadosScreen(),
        },
      ),
    );
  }
}
