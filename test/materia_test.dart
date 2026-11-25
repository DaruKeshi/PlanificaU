import 'package:flutter_test/flutter_test.dart';
import 'package:planificau/models/corte.dart';
import 'package:planificau/models/materia.dart';

void main() {
  test('Una materia nueva tiene tres cortes sin nota y no está aprobada', () {
    final materia = Materia(
      id: 'm1',
      nombre: 'Matemáticas',
      escalaMaxima: 5,
      notaAprobacion: 3,
      cortes: Materia.crearCortes(3),
    );

    expect(materia.cortes.length, 3);
    expect(materia.cortesEvaluados, 0);
    expect(materia.promedio, 0);
    expect(materia.acumulado, 0);
    expect(materia.avance, 0);
    expect(materia.aprobada, isFalse);
    expect(materia.estado, 'En curso');
  });

  test('El promedio es ponderado y el acumulado suma puntos por peso', () {
    final materia = Materia(
      id: 'm2',
      nombre: 'Física',
      escalaMaxima: 5,
      notaAprobacion: 3,
      cortes: [
        Corte(id: 'c1', numero: 1, nombre: 'Corte 1', peso: 1, nota: 4),
        Corte(id: 'c2', numero: 2, nombre: 'Corte 2', peso: 3, nota: 5),
      ],
    );

    expect(materia.acumulado, 19);
    expect(materia.promedio, 4.75);
    expect(materia.avance, 1);
    expect(materia.aprobada, isTrue);
    expect(materia.estado, 'Aprobada');
  });

  test('Solo se aprueba cuando todos los cortes tienen nota', () {
    final materia = Materia(
      id: 'm3',
      nombre: 'Historia',
      escalaMaxima: 5,
      notaAprobacion: 3,
      cortes: [
        Corte(id: 'c1', numero: 1, nombre: 'Corte 1', peso: 1, nota: 5),
        Corte(id: 'c2', numero: 2, nombre: 'Corte 2', peso: 1),
      ],
    );

    expect(materia.cortesEvaluados, 1);
    expect(materia.promedio, 5);
    expect(materia.avance, 0.5);
    expect(materia.aprobada, isFalse);
  });

  test('La escala y la nota de aprobación son configurables', () {
    final materia = Materia(
      id: 'm4',
      nombre: 'Química',
      escalaMaxima: 100,
      notaAprobacion: 70,
      cortes: [
        Corte(id: 'c1', numero: 1, nombre: 'Corte 1', peso: 2, nota: 80),
        Corte(id: 'c2', numero: 2, nombre: 'Corte 2', peso: 1, nota: 60),
      ],
    );

    expect(materia.promedio, closeTo(73.33, 0.01));
    expect(materia.aprobada, isTrue);
  });

  test('El porcentaje de cada corte se calcula sobre la ponderación total', () {
    final materia = Materia(
      id: 'm5',
      nombre: 'Porcentajes',
      escalaMaxima: 5,
      notaAprobacion: 3,
      cortes: [
        Corte(id: 'c1', numero: 1, nombre: 'Corte 1', peso: 0.5),
        Corte(id: 'c2', numero: 2, nombre: 'Corte 2', peso: 0.5),
      ],
    );

    expect(materia.pesoTotal, 1);
    expect(materia.porcentajeDe(materia.cortes[0]), 50);
    expect(materia.porcentajeDe(materia.cortes[1]), 50);
  });

  test('La cantidad de cortes se mantiene entre 2 y 10', () {
    expect(Materia.crearCortes(1).length, Materia.minimoCortes);
    expect(Materia.crearCortes(50).length, Materia.maximoCortes);
    expect(Materia.cantidadValida(4), 4);
  });
}
