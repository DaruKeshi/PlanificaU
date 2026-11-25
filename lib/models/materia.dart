import 'package:cloud_firestore/cloud_firestore.dart';

import 'corte.dart';

/// Materia con sus cortes, escala de calificación y resultado acumulado.
///
/// El promedio es ponderado por los cortes que ya tienen nota. El acumulado
/// son los puntos ponderados obtenidos hasta ahora; `aprobada` solo se vuelve
/// verdadero cuando todos los cortes están evaluados y el promedio alcanza la
/// nota mínima configurada.
class Materia {
  Materia({
    required this.id,
    required this.nombre,
    required this.escalaMaxima,
    required this.notaAprobacion,
    required this.cortes,
  });

  static const int minimoCortes = 2;
  static const int maximoCortes = 10;
  static const double escalaPorDefecto = 5;
  static const double aprobacionPorDefecto = 3;
  static const int cortesPorDefecto = 3;

  final String id;
  final String nombre;
  final double escalaMaxima;
  final double notaAprobacion;
  final List<Corte> cortes;

  static int cantidadValida(int cantidad) =>
      cantidad.clamp(minimoCortes, maximoCortes);

  /// Crea la cantidad de cortes inicial, con peso relativo 1 y sin nota.
  static List<Corte> crearCortes(int cantidad) => List.generate(
    cantidadValida(cantidad),
    (i) => Corte(
      id: 'corte-${i + 1}',
      numero: i + 1,
      nombre: 'Corte ${i + 1}',
      peso: 1,
    ),
  );

  factory Materia.desdeFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final datos = doc.data() ?? <String, dynamic>{};
    final rawCortes = datos['cortes'];
    var cortes = <Corte>[];

    if (rawCortes is List) {
      for (var i = 0; i < rawCortes.length; i++) {
        final item = rawCortes[i];
        if (item is Map) {
          cortes.add(Corte.desdeFirestore(Map<String, dynamic>.from(item), i));
        }
      }
    }
    if (cortes.isEmpty) cortes = crearCortes(cortesPorDefecto);

    return Materia(
      id: doc.id,
      nombre: (datos['nombre'] as String?) ?? '',
      escalaMaxima:
          (datos['escalaMaxima'] as num?)?.toDouble() ?? escalaPorDefecto,
      notaAprobacion:
          (datos['notaAprobacion'] as num?)?.toDouble() ?? aprobacionPorDefecto,
      cortes: cortes,
    );
  }

  /// Datos guardados en `usuarios/{uid}/materias/{id}`.
  ///
  /// Los resultados calculados también se guardan para que la consola muestre
  /// el acumulado sin tener que repetir el cálculo fuera de la app.
  Map<String, dynamic> paraFirestore() => {
    'nombre': nombre,
    'escalaMaxima': escalaMaxima,
    'notaAprobacion': notaAprobacion,
    'cortes': cortes.map((c) => c.paraFirestore()).toList(),
    'promedio': promedio,
    'acumulado': acumulado,
    'cortesEvaluados': cortesEvaluados,
    'aprobada': aprobada,
    'actualizadoEn': FieldValue.serverTimestamp(),
  };

  int get cortesEvaluados => cortes.where((c) => c.evaluado).length;

  /// Suma de las ponderaciones relativas de todos los cortes.
  double get pesoTotal =>
      cortes.fold<double>(0, (total, corte) => total + corte.peso);

  /// Parte porcentual que representa un corte dentro de la materia.
  double porcentajeDe(Corte corte) =>
      pesoTotal == 0 ? 0 : corte.peso / pesoTotal * 100;

  double get pesoEvaluado => cortes.fold<double>(
    0,
    (total, corte) => total + (corte.nota == null ? 0 : corte.peso),
  );

  /// Puntos ponderados acumulados hasta el momento.
  double get acumulado => cortes.fold<double>(
    0,
    (total, corte) => total + (corte.nota ?? 0) * corte.peso,
  );

  /// Promedio ponderado de los cortes que ya tienen nota.
  double get promedio => pesoEvaluado == 0 ? 0 : acumulado / pesoEvaluado;

  /// Avance de la materia: cuántos cortes llevan nota (0 a 1).
  double get avance => cortes.isEmpty ? 0 : cortesEvaluados / cortes.length;

  bool get aprobada =>
      cortes.isNotEmpty &&
      cortesEvaluados == cortes.length &&
      promedio >= notaAprobacion;

  String get estado => aprobada ? 'Aprobada' : 'En curso';
}
