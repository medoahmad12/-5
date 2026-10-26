import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../data/models.dart';
import '../game_engine/instruction_bar.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/settings_service.dart';

/// Pop exactly N balloons. Gentle rule: extra pops wobble but never fail
/// the game — they only count as small mistakes for the star rating.
class BalloonsGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final ValueChanged<GameResult> onDone;

  const BalloonsGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.onDone,
  });

  @override
  State<BalloonsGame> createState() => _BalloonsGameState();
}

class _Balloon {
  final int id;
  final Color color;
  final double x; // 0..1 horizontal position
  final double speed; // rise speed factor
  final double phase;
  bool popped;
  _Balloon({
    required this.id,
    required this.color,
    required this.x,
    required this.speed,
    required this.phase,
  });
}

class _BalloonsGameState extends State<BalloonsGame>
    with SingleTickerProviderStateMixin {
  late final int _target;
  late final List<_Balloon> _balloons;
  late final AnimationController _float;
  int _popped = 0;
  int _extras = 0;
  bool _done = false;

  static const List<Color> _palette = [
    AppColors.coral, AppColors.sun, AppColors.blue,
    AppColors.mint, AppColors.pink, AppColors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _target = int.tryParse(widget.unit.glyph) ?? 1;
    final rng = Random();
    _balloons = List.generate(_target + 3, (i) {
      return _Balloon(
        id: i,
        color: _palette[rng.nextInt(_palette.length)],
        x: 0.08 + rng.nextDouble() * 0.84,
        speed: 0.55 + rng.nextDouble() * 0.45,
        phase: rng.nextDouble(),
      );
    });
    _float = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.fill(S.trOf('popHint', context.isAr),
              {'n': Helpers.digits(_target, arabic: context.isAr)}),
          enKey: 'pop',
        );
      }
    });
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _pop(_Balloon b) {
    if (b.popped || _done) return;
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();
    Haptics.pop(settings.hapticsOn);
    audio.pop();
    setState(() => b.popped = true);

    if (_popped < _target) {
      _popped += 1;
      if (settings.isAr) {
        const names = [
          'واحِد', 'اثنان', 'ثَلاثة', 'أَربعة', 'خَمسة',
          'سِتّة', 'سَبعة', 'ثَمانية', 'تِسعة', 'عَشَرة'
        ];
        audio.narrateArabic(names[(_popped - 1).clamp(0, 9)]);
      } else {
        audio.narrateAsset('audio/en/num_$_popped.ogg');
      }
      if (_popped == _target) {
        _done = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          Haptics.success(settings.hapticsOn);
          audio.success();
          widget.onDone(GameResult(
              mistakes: min(_extras, 2),
              completed: true,
              skill: 'counting'));
        });
      }
    } else {
      _extras += 1;
      audio.gentleWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    return Column(
      children: [
        InstructionBar(
          hintKey: 'popHint',
          params: {'n': Helpers.digits(_target, arabic: isAr)},
          enKey: 'pop',
          arText: S.fill(S.trOf('popHint', true),
              {'n': Helpers.digits(_target, arabic: true)}),
          guideChar: 'toto',
        ),
        SizedBox(height: 6.sp),
        Expanded(
          child: AnimatedBuilder(
            animation: _float,
            builder: (context, _) {
              return LayoutBuilder(builder: (context, box) {
                final w = box.maxWidth;
                final h = box.maxHeight;
                return Stack(
                  children: [
                    for (final b in _balloons)
                      if (!b.popped)
                        _balloonWidget(b, w, h),
                  ],
                );
              });
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 6.sp),
          color: Colors.white.withOpacity(0.6),
          child: Center(
            child: Text(
              '${Helpers.digits(_popped, arabic: isAr)} / ${Helpers.digits(_target, arabic: isAr)}',
              style: TextStyle(
                  fontSize: 20.sp, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _balloonWidget(_Balloon b, double w, double h) {
    final t = _float.value;
    final cycle = (t * b.speed + b.phase) % 1.0;
    final y = h * (1.08 - cycle * 1.18);
    final sway = sin(cycle * pi * 3 + b.phase * 10) * w * 0.02;
    final size = 54.sp.clamp(44.0, 68.0);

    return Positioned(
      left: b.x * w + sway - size / 2,
      top: y - size,
      child: GestureDetector(
        onTap: () => _pop(b),
        child: BalloonWidget(color: b.color, size: size),
      ),
    );
  }
}

/// Pure-vector glossy balloon with a string.
class BalloonWidget extends StatelessWidget {
  final Color color;
  final double size;
  const BalloonWidget({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 0.8,
      height: size * 1.25,
      child: CustomPaint(painter: _BalloonPainter(color: color)),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  final Color color;
  _BalloonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Rect.fromLTWH(w * 0.05, h * 0.04, w * 0.9, h * 0.62);

    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(rect.shift(const Offset(2, 4)), shadow);

    final body = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        colors: [
          Color.lerp(color, Colors.white, 0.55)!,
          color,
          Color.lerp(color, Colors.black, 0.12)!,
        ],
      ).createShader(rect);
    canvas.drawOval(rect, body);

    // knot
    final knot = Paint()..color = Color.lerp(color, Colors.black, 0.15)!;
    final knotPath = Path()
      ..moveTo(w * 0.42, h * 0.66)
      ..lineTo(w * 0.5, h * 0.72)
      ..lineTo(w * 0.58, h * 0.66)
      ..close();
    canvas.drawPath(knotPath, knot);

    // string
    final string = Paint()
      ..color = Colors.brown.withOpacity(0.6)
      ..strokeWidth = 1.6;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.62, h * 0.85, w * 0.48, h * 0.97);
    canvas.drawPath(path, string);

    // shine
    final shine = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
        Rect.fromLTWH(w * 0.18, h * 0.10, w * 0.2, h * 0.16), shine);
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter old) =>
      old.color != color;
}
