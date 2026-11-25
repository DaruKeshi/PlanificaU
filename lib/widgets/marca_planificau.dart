import 'package:flutter/material.dart';

import '../app/theme.dart';

class MarcaPlanificau extends StatelessWidget {
  const MarcaPlanificau({super.key, this.tamano = 84});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo de PlanificaU',
      child: CustomPaint(
        size: Size.square(tamano),
        painter: _MarcaPainter(),
      ),
    );
  }
}

class _MarcaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    final fondo = Paint()
      ..shader = PlanificaUTheme.hero.createShader(
        Rect.fromLTWH(0, 0, s, s),
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & Size(s, s),
        Radius.circular(s * 0.3),
      ),
      fondo,
    );

    // Hojas del cuaderno
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.24, s * 0.19, s * 0.5, s * 0.62),
        Radius.circular(s * 0.07),
      ),
      Paint()..color = PlanificaUTheme.papel,
    );

    final linea = Paint()
      ..color = PlanificaUTheme.primario.withValues(alpha: 0.3)
      ..strokeWidth = s * 0.032
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = s * (0.37 + i * 0.12);
      final fin = i == 2 ? s * 0.57 : s * 0.66;
      canvas.drawLine(Offset(s * 0.35, y), Offset(fin, y), linea);
    }

    // Check de acento
    final check = Paint()
      ..color = PlanificaUTheme.acento
      ..strokeWidth = s * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final trazo = Path()
      ..moveTo(s * 0.54, s * 0.66)
      ..cubicTo(s * 0.58, s * 0.70, s * 0.62, s * 0.75, s * 0.65, s * 0.78)
      ..cubicTo(s * 0.71, s * 0.69, s * 0.79, s * 0.58, s * 0.87, s * 0.49);
    canvas.drawPath(trazo, check);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
