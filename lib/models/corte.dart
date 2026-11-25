/// Un corte (periodo de evaluación) dentro de una materia.
///
/// Guarda la nota opcional y la ponderación que tiene ese corte dentro de la
/// materia. Los cortes sin nota no cuentan para el promedio, pero sí para el
/// avance (cuántos lleva evaluados el estudiante).
class Corte {
  const Corte({
    required this.id,
    required this.numero,
    required this.nombre,
    required this.peso,
    this.nota,
  });

  final String id;
  final int numero;
  final String nombre;
  final double peso;
  final double? nota;

  bool get evaluado => nota != null;

  factory Corte.desdeFirestore(Map<String, dynamic> datos, int indice) {
    final numero = (datos['numero'] as num?)?.toInt() ?? indice + 1;
    final nota = datos['nota'];

    return Corte(
      id: (datos['id'] as String?) ?? 'corte-$numero',
      numero: numero,
      nombre: (datos['nombre'] as String?) ?? 'Corte $numero',
      peso: (datos['peso'] as num?)?.toDouble() ?? 1,
      nota: nota is num ? nota.toDouble() : null,
    );
  }

  /// Estructura guardada dentro del arreglo `cortes` de una materia.
  Map<String, dynamic> paraFirestore() => {
        'id': id,
        'numero': numero,
        'nombre': nombre,
        'peso': peso,
        'nota': nota,
      };

  Corte conNota(double? valor) => Corte(
        id: id,
        numero: numero,
        nombre: nombre,
        peso: peso,
        nota: valor,
      );

  Corte conPeso(double valor) => Corte(
        id: id,
        numero: numero,
        nombre: nombre,
        peso: valor,
        nota: nota,
      );
}
