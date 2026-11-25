import 'package:flutter/material.dart';

import '../app/theme.dart';

class EncabezadoApp extends StatelessWidget implements PreferredSizeWidget {
  const EncabezadoApp({
    super.key,
    required this.titulo,
    this.mostrarAtras = false,
    this.actions,
  });

  final String titulo;
  final bool mostrarAtras;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: mostrarAtras,
      title: Text(titulo),
      backgroundColor: PlanificaUTheme.papel,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: PlanificaUTheme.borde, height: 1),
      ),
    );
  }
}
