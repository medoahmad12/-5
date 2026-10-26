import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Lightweight confetti / sparkle particles painted on a CustomPainter.
/// Particle count stays low (<=42) and is disabled in "reduce motion" mode.
class ConfettiPainter extends CustomPainter {
  final double progress; // 0..1
  final int count;
  final List<_Particle> _particles;
  final List<Color> palette;

  ConfettiPainter({
    required this.progress,
    this.count = 36,
    this.palette = const [
      AppColors.sun, AppColors.coral, AppColors.mint,
      AppColors.blue, AppColors.pink, AppColors.purple,
    ],
  }) : _particles = List.generate(count, (i) {
         final rng = Random(i * 7919);
         return _Particle(
           angle: rng.nextDouble() * 2 * pi,
           speed: 0.35 + rng.nextDouble() * 0.65,
           radius: 3 + rng.nextDouble() * 5,
           color: palette[rng.nextInt(palette.length)],
           isStar: rng.nextBool(),
           spin: rng.nextDouble() * 2 * pi,
         );
       });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final maxR = size.longestSide * 0.75;
    for (final p in _particles) {
      final dist = p.speed * maxR * progress;
      final pos = center +
          Offset(cos(p.angle), sin(p.angle) - progress * 0.6) * dist;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin + progress * 6);
      if (p.isStar) {
        _drawStar(canvas, p.radius, paint);
      } else {
        canvas.drawCircle(Offset.zero, p.radius, paint);
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final outerA = i * 2 * pi / 5 - pi / 2;
      final innerA = (i + 0.5) * 2 * pi / 5 - pi / 2;
      path.lineTo(cos(outerA) * r, sin(outerA) * r);
      path.lineTo(cos(innerA) * r * 0.45, sin(innerA) * r * 0.45);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter old) =>
      old.progress != progress;
}

class _Particle {
  final double angle, speed, radius, spin;
  final Color color;
  final bool isStar;
  const _Particle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.color,
    required this.isStar,
    required this.spin,
  });
}

/// Ambient floating sparkles for world screens (very light: 10 particles).
class AmbientSparkles extends StatefulWidget {
  final int count;
  const AmbientSparkles({super.key, this.count = 10});

  @override
  State<AmbientSparkles> createState() => _AmbientSparklesState();
}

class _AmbientSparklesState extends State<AmbientSparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SparklesPainter(t: _ctrl.value, count: widget.count),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  final double t;
  final int count;
  _SparklesPainter({required this.t, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final bx = rng.nextDouble();
      final by = rng.nextDouble();
      final phase = (t + rng.nextDouble()) % 1.0;
      final x = bx * size.width;
      final y = size.height * (1.1 - phase * 1.25);
      final r = 2 + rng.nextDouble() * 3;
      paint.color = Colors.white.withOpacity(0.35 * (1 - phase));
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter old) => old.t != t;
}
