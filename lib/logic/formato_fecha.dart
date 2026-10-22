class FormatoFecha {
  static const _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  static DateTime soloDia(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  static String largo(DateTime fecha) {
    return '${fecha.day} de ${_meses[fecha.month - 1]} de ${fecha.year}';
  }

  static String corto(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }
}
