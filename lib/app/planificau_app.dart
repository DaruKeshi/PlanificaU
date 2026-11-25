import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/agenda_firestore.dart';
import '../screens/consulta_resultados_screen.dart';
import '../screens/detalle_materia_screen.dart';
import '../screens/detalle_tarea_screen.dart';
import '../screens/editar_materia_screen.dart';
import '../screens/editar_tarea_screen.dart';
import '../screens/login_screen.dart';
import '../screens/registro_materia_screen.dart';
import '../screens/registro_tarea_screen.dart';
import '../screens/registro_usuario_screen.dart';
import 'app_shell.dart';
import 'rutas.dart';
import 'theme.dart';

class PlanificaUApp extends StatelessWidget {
  const PlanificaUApp({super.key, required this.agenda});

  final AgendaFirestore agenda;

  @override
  Widget build(BuildContext context) {
    return AgendaScope(
      agenda: agenda,
      child: MaterialApp(
        title: 'PlanificaU',
        debugShowCheckedModeBanner: false,
        theme: PlanificaUTheme.material,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final usuario = snapshot.data;
            if (usuario == null) {
              return const LoginScreen();
            }
            // El campo "Ingresa tu nombre" se deja vacío para que el usuario
            // lo llene en la pantalla de inicio.
            return const AppShell();
          },
        ),
        onGenerateRoute: (settings) {
          late final Widget pantalla;
          switch (settings.name) {
            case Rutas.registro:
              pantalla = const RegistroTareaScreen();
              break;
            case Rutas.consulta:
              pantalla = const ConsultaResultadosScreen();
              break;
            case Rutas.login:
              pantalla = const LoginScreen();
              break;
            case Rutas.registroUsuario:
              pantalla = const RegistroUsuarioScreen();
              break;
            case Rutas.detalleTarea:
              pantalla = DetalleTareaScreen(id: settings.arguments as String? ?? '');
              break;
            case Rutas.editarTarea:
              pantalla = EditarTareaScreen(id: settings.arguments as String? ?? '');
              break;
            case Rutas.registroMateria:
              pantalla = const RegistroMateriaScreen();
              break;
            case Rutas.detalleMateria:
              pantalla = DetalleMateriaScreen(id: settings.arguments as String? ?? '');
              break;
            case Rutas.editarMateria:
              pantalla = EditarMateriaScreen(id: settings.arguments as String? ?? '');
              break;
            default:
              pantalla = const LoginScreen();
          }
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => pantalla,
          );
        },
      ),
    );
  }
}
