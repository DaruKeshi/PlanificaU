import 'package:flutter/material.dart';

/// Paleta y tipografia
class PlanificaUTheme {
  static const Color azul = Color(0xFF3B82F6);
  static const Color azulClaro = Color(0xFFBFDBFE);
  static const Color azulSuave = Color(0xFFE8F1FF);
  static const Color fondo = Color(0xFFF7F4EE);
  static const Color texto = Color(0xFF1F2937);
  static const Color prioridadAlta = Color(0xFFEF4444);
  static const Color prioridadMedia = Color(0xFFF59E0B);
  static const Color prioridadBaja = Color(0xFF22C55E);

  static ThemeData get material {
    final scheme = ColorScheme.fromSeed(
      seedColor: azul,
      primary: azul,
      surface: fondo,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: fondo,
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: azulClaro,
        foregroundColor: texto,
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: azul,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: azul,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: azul),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
