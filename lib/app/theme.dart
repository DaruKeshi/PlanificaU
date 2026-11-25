import 'package:flutter/material.dart';

/// Sistema visual "Editorial cálido": papel crema, tinta azulada y acento coral.
class PlanificaUTheme {
  static const Color tinta = Color(0xFF1B2430);
  static const Color tintaSuave = Color(0xFF5C6673);
  static const Color fondo = Color(0xFFF6F3EC);
  static const Color papel = Color(0xFFFFFCF7);
  static const Color primario = Color(0xFF2F6D5F);
  static const Color primarioSuave = Color(0xFFDCEAE4);
  static const Color acento = Color(0xFFE07A5F);
  static const Color acentoSuave = Color(0xFFF8E5DE);
  static const Color acentoTexto = Color(0xFF8E3B27);
  static const Color borde = Color(0xFFE7E1D6);
  static const Color prioridadAlta = Color(0xFFD9604E);
  static const Color prioridadAltaSuave = Color(0xFFFBE4E0);
  static const Color prioridadAltaTexto = Color(0xFF9B2F21);
  static const Color prioridadMedia = Color(0xFFD79A32);
  static const Color prioridadBaja = Color(0xFF3D8A76);

  static const LinearGradient hero = LinearGradient(
    colors: [Color(0xFF2F6D5F), Color(0xFF1B2430)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get material {
    final scheme = ColorScheme.fromSeed(
      seedColor: primario,
      primary: primario,
      surface: papel,
      onSurface: tinta,
      error: prioridadAlta,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: fondo,
      useMaterial3: true,
      fontFamily: 'Roboto',
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          height: 1.1,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          color: tinta,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: tinta,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: tinta,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: tintaSuave),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: papel,
        foregroundColor: tinta,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: tinta,
          letterSpacing: -0.3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tinta,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tinta,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: borde),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: papel,
        hintStyle: const TextStyle(color: Color(0xFF9AA2AC)),
        labelStyle: const TextStyle(color: tintaSuave),
        floatingLabelStyle: const TextStyle(
          color: primario,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primario, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: papel,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borde),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primarioSuave,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(
          color: primario,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: papel,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primarioSuave,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primario
                : tintaSuave,
          ),
        ),
      ),
    );
  }
}
