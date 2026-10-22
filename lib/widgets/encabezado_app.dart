import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Encabezado reutilizable en las tres pantallas.
class EncabezadoApp extends StatelessWidget implements PreferredSizeWidget {
  const EncabezadoApp({
    super.key,
    required this.titulo,
    this.mostrarAtras = false,
  });

  final String titulo;
  final bool mostrarAtras;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: mostrarAtras,
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: PlanificaUTheme.azulClaro,
    );
  }
}
