import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Draws the basic shapes with a soft 3D gradient + optional cute face.
/// Used by the Colors & Shapes world (no external assets needed).
class ShapeGlyph extends StatelessWidget {
  /// circle / square / triangle / star / heart / rectangle / diamond / oval
  final String kind;
  final Color color;
  final double size;
  final bool withFace;

  const ShapeGlyph({
    super.key,
    required this.kind,
    required this.color,
    this.size = 110,
    this.withFace = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapePainter(kind: kind, color: color, withFace: withFace),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final String kind;
  final Color color;
  final bool withFace;
  _ShapePainter(
      {required this.kind, required this.color, required this.withFace});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Rect.fromLTWH(w * 0.12, h * 0.12, w * 0.76, h * 0.76);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.35)!,
          color,
          Color.lerp(color, Colors.black, 0.18)!,
        ],
      ).createShader(rect);

    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = _pathFor(kind, rect);
    canvas.save();
    canvas.translate(w * 0.02, h * 0.05);
    canvas.drawPath(path, shadow);
    canvas.restore();
    canvas.drawPath(path, paint);

    // top gloss
    final gloss = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.55),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(rect);
    canvas.drawPath(path, gloss);

    if (withFace) _drawFace(canvas, rect);
  }

  Path _pathFor(String kind, Rect r) {
    switch (kind) {
      case 'square':
        return Path()..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(10)));
      case 'rectangle':
        return Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: r.center,
                  width: r.width * 1.22,
                  height: r.height * 0.74),
              const Radius.circular(10)));
      case 'triangle':
        return Path()
          ..moveTo(r.center.dx, r.top)
          ..lineTo(r.right, r.bottom)
          ..lineTo(r.left, r.bottom)
          ..close();
      case 'star':
        final path = Path();
        final c = r.center;
        final outer = r.width / 2;
        final inner = outer * 0.45;
        for (var i = 0; i < 10; i++) {
          final angle = -math.pi / 2 + i * math.pi / 5;
          final rad = i.isEven ? outer : inner;
          path.lineTo(
              c.dx + math.cos(angle) * rad, c.dy + math.sin(angle) * rad);
        }
        return path..close();
      case 'heart':
        final path = Path();
        final c = r.center;
        final s = r.width / 2;
        path.moveTo(c.dx, r.bottom);
        path.cubicTo(c.dx - s * 1.6, r.top + s * 0.5, c.dx - s * 0.8, r.top - s * 0.4,
            c.dx, r.top + s * 0.35);
        path.cubicTo(c.dx + s * 0.8, r.top - s * 0.4, c.dx + s * 1.6, r.top + s * 0.5,
            c.dx, r.bottom);
        return path;
      case 'diamond':
        return Path()
          ..moveTo(r.center.dx, r.top)
          ..lineTo(r.right, r.center.dy)
          ..lineTo(r.center.dx, r.bottom)
          ..lineTo(r.left, r.center.dy)
          ..close();
      case 'oval':
        return Path()
          ..addOval(Rect.fromCenter(
              center: r.center,
              width: r.width * 0.72,
              height: r.height * 1.05));
      case 'circle':
      default:
        return Path()..addOval(r);
    }
  }

  void _drawFace(Canvas canvas, Rect r) {
    final eyePaint = Paint()..color = const Color(0xFF3A3335);
    final c = r.center;
    final eyeDx = r.width * 0.16;
    final eyeDy = c.dy - r.height * 0.08;
    canvas.drawCircle(Offset(c.dx - eyeDx, eyeDy), r.width * 0.055, eyePaint);
    canvas.drawCircle(Offset(c.dx + eyeDx, eyeDy), r.width * 0.055, eyePaint);
    // shine in eyes
    final shine = Paint()..color = Colors.white;
    canvas.drawCircle(
        Offset(c.dx - eyeDx + 1.5, eyeDy - 1.5), r.width * 0.018, shine);
    canvas.drawCircle(
        Offset(c.dx + eyeDx + 1.5, eyeDy - 1.5), r.width * 0.018, shine);

    final smile = Paint()
      ..color = const Color(0xFF3A3335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r.width * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(c.dx, c.dy + r.height * 0.10),
            width: r.width * 0.34,
            height: r.height * 0.30),
        0.15 * math.pi,
        0.7 * math.pi,
        false,
        smile);
    // cheeks
    final cheek = Paint()..color = Colors.pink.withOpacity(0.35);
    canvas.drawCircle(
        Offset(c.dx - r.width * 0.28, c.dy + r.height * 0.06),
        r.width * 0.055, cheek);
    canvas.drawCircle(
        Offset(c.dx + r.width * 0.28, c.dy + r.height * 0.06),
        r.width * 0.055, cheek);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) =>
      old.kind != kind || old.color != color;
}
