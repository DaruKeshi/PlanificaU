import '../models/prioridad.dart';
import '../models/tarea.dart';
import 'formato_fecha.dart';

class ResumenAcademico {
  const ResumenAcademico({
    required this.total,
    required this.completadas,
    required this.pendientes,
    required this.vencidas,
    required this.altas,
    required this.medias,
    required this.bajas,
    required this.proxima,
  });

  final int total;
  final int completadas;
  final int pendientes;
  final int vencidas;
  final int altas;
  final int medias;
  final int bajas;
  final Tarea? proxima;

  double get progreso => total == 0 ? 0 : completadas / total;
}

/// Calcula vencimientos, proxima entrega y carga por prioridad.
class ProcesadorAcademico {
  static int diasRestantes(Tarea tarea, DateTime referencia) {
    return FormatoFecha.soloDia(tarea.fechaEntrega)
        .difference(FormatoFecha.soloDia(referencia))
        .inDays;
  }

  static bool estaVencida(Tarea tarea, DateTime referencia) {
    return !tarea.completada && diasRestantes(tarea, referencia) < 0;
  }

  static String etiquetaPlazo(Tarea tarea, DateTime referencia) {
    final dias = diasRestantes(tarea, referencia);
    if (tarea.completada) return 'Completada';
    if (dias < 0) return 'Vencida hace ${-dias} dia(s)';
    if (dias == 0) return 'Vence hoy';
    if (dias == 1) return 'Vence manana';
    return 'Faltan $dias dias';
  }

  static ResumenAcademico resumir(List<Tarea> tareas, DateTime referencia) {
    final pendientes = tareas.where((t) => !t.completada).toList();
    pendientes.sort((a, b) => a.fechaEntrega.compareTo(b.fechaEntrega));

    return ResumenAcademico(
      total: tareas.length,
      completadas: tareas.where((t) => t.completada).length,
      pendientes: pendientes.length,
      vencidas: tareas.where((t) => estaVencida(t, referencia)).length,
      altas: pendientes.where((t) => t.prioridad == Prioridad.alta).length,
      medias: pendientes.where((t) => t.prioridad == Prioridad.media).length,
      bajas: pendientes.where((t) => t.prioridad == Prioridad.baja).length,
      proxima: pendientes.isEmpty ? null : pendientes.first,
    );
  }
}
