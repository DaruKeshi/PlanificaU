import 'package:flutter/material.dart';

import '../app/theme.dart';


class BlobCurvoPainter extends CustomPainter {
  const BlobCurvoPainter({
    required this.color,
    required this.invertido,
    this.gradiente,
  });

  final Color color;
  final bool invertido;
  final LinearGradient? gradiente;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    if (invertido) {
      path.moveTo(0, h * 0.18);
      path.cubicTo(w * 0.05, -h * 0.12, w * 0.72, -h * 0.08, w * 0.96, h * 0.3);
      path.cubicTo(w * 1.18, h * 0.58, w * 0.72, h * 1.06, w * 0.32, h * 0.9);
      path.cubicTo(-w * 0.08, h * 0.78, -w * 0.06, h * 0.42, 0, h * 0.18);
    } else {
      path.moveTo(w * 0.08, h * 0.12);
      path.cubicTo(w * 0.34, -h * 0.14, w * 0.9, -h * 0.06, w, h * 0.32);
      path.cubicTo(w * 1.1, h * 0.7, w * 0.6, h * 1.08, w * 0.22, h * 0.84);
      path.cubicTo(-w * 0.12, h * 0.64, -w * 0.14, h * 0.36, w * 0.08, h * 0.12);
    }
    path.close();

    final paint = Paint();
    if (gradiente != null) {
      paint.shader = gradiente!.createShader(Offset.zero & size);
    } else {
      paint.color = color;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BlobCurvoPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.invertido != invertido ||
      oldDelegate.gradiente != gradiente;
}


class BandaCurvaPainter extends CustomPainter {
  const BandaCurvaPainter({
    required this.color,
    this.curva = 34,
    this.invertida = false,
    this.gradiente,
  });

  final Color color;
  final double curva;
  final bool invertida;
  final LinearGradient? gradiente;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    if (invertida) {
      path.moveTo(0, h);
      path.lineTo(w, h);
      path.lineTo(w, curva);
      path.cubicTo(
        w * 0.72,
        -curva * 0.35,
        w * 0.28,
        curva * 1.35,
        0,
        curva * 0.25,
      );
    } else {
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      path.lineTo(w, h - curva);
      path.cubicTo(
        w * 0.72,
        h + curva * 0.35,
        w * 0.28,
        h - curva * 1.35,
        0,
        h - curva * 0.25,
      );
    }
    path.close();

    final paint = Paint();
    if (gradiente != null) {
      paint.shader = gradiente!.createShader(Offset.zero & size);
    } else {
      paint.color = color;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BandaCurvaPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.curva != curva ||
      oldDelegate.invertida != invertida ||
      oldDelegate.gradiente != gradiente;
}

/// Recorta un contenedor con una curva suave en la parte inferior.
class CurvaHeroClipper extends CustomClipper<Path> {
  const CurvaHeroClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - 26)
      ..cubicTo(w * 0.74, h + 14, w * 0.26, h - 46, 0, h - 14)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Muesca superior con Bézier para la barra inferior (compatible con el FAB).
class BezierNotch extends NotchedShape {
  const BezierNotch({this.margen = 10});

  final double margen;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    final centro = guest?.center.dx ?? host.center.dx;
    final ancho = guest == null ? 44.0 : guest.width / 2 + margen;
    final profundo = guest == null ? 20.0 : guest.height / 2 + margen * 0.6;

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(centro - ancho, host.top)
      ..cubicTo(
        centro - ancho * 0.62,
        host.top,
        centro - ancho * 0.42,
        host.top + profundo,
        centro,
        host.top + profundo,
      )
      ..cubicTo(
        centro + ancho * 0.42,
        host.top + profundo,
        centro + ancho * 0.62,
        host.top,
        centro + ancho,
        host.top,
      )
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

/// Línea curva decorativa para separar secciones.
class LineaCurvaPainter extends CustomPainter {
  const LineaCurvaPainter({this.color = PlanificaUTheme.borde});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.05,
        size.width * 0.7,
        size.height * 0.95,
        size.width,
        size.height * 0.4,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant LineaCurvaPainter oldDelegate) =>
      oldDelegate.color != color;
}
