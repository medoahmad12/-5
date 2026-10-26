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
import '../widgets/gradient_glyph.dart';

/// Letter bubbles float up the screen — pop the ones with the target letter.
/// Wrong pops get a gentle sound and a small mistake count, never a failure.
class BubblesGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final List<UnitDef> pool;
  final ValueChanged<GameResult> onDone;

  const BubblesGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.pool,
    required this.onDone,
  });

  @override
  State<BubblesGame> createState() => _BubblesGameState();
}

class _Bubble {
  final int id;
  final String glyph;
  final Color color;
  final double x;
  final double speed;
  final double phase;
  bool popped;
  _Bubble({
    required this.id,
    required this.glyph,
    required this.color,
    required this.x,
    required this.speed,
    required this.phase,
  });
}

class _BubblesGameState extends State<BubblesGame>
    with SingleTickerProviderStateMixin {
  static const int _needCorrect = 3;

  late final List<_Bubble> _bubbles;
  late final AnimationController _float;
  int _correct = 0;
  int _mistakes = 0;
  bool _done = false;
  int _nextId = 100;

  @override
  void initState() {
    super.initState();
    _bubbles = _spawnInitial();
    _float = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))
      ..repeat();
    _float.addListener(_recycle);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.fill(S.trOf('popLetterHint', context.isAr),
              {'g': widget.unit.glyph}),
          enKey: 'tap_letter',
        );
        context.read<AudioService>().narrateArabic(widget.unit.ttsAr);
      }
    });
  }

  List<_Bubble> _spawnInitial() {
    final rng = Random();
    return List.generate(6, (i) {
      final isTarget = i < 2;
      final other = Helpers.pickDistinct(
          widget.pool.where((u) => u.glyph.isNotEmpty).toList(),
          1,
          exclude: {widget.unit}).first;
      final u = isTarget ? widget.unit : other;
      return _Bubble(
        id: i,
        glyph: u.glyph,
        color: u.color,
        x: 0.1 + rng.nextDouble() * 0.8,
        speed: 0.5 + rng.nextDouble() * 0.5,
        phase: rng.nextDouble(),
      );
    });
  }

  void _recycle() {
    if (!mounted || _done) return;
    var changed = false;
    for (var i = 0; i < _bubbles.length; i++) {
      final b = _bubbles[i];
      final cycle = (_float.value * b.speed + b.phase) % 1.0;
      if (cycle > 0.98 && !b.popped) {
        // floated away — respawn with a fresh glyph
        final rng = Random();
        final makeTarget = rng.nextBool();
        final others = widget.pool
            .where((u) => u.glyph.isNotEmpty && u.id != widget.unit.id)
            .toList();
        final u = makeTarget || others.isEmpty
            ? widget.unit
            : others[rng.nextInt(others.length)];
        _bubbles[i] = _Bubble(
          id: _nextId++,
          glyph: u.glyph,
          color: u.color,
          x: 0.1 + rng.nextDouble() * 0.8,
          speed: 0.5 + rng.nextDouble() * 0.5,
          phase: 0,
        );
        changed = true;
      }
    }
    if (changed) setState(() {});
  }

  @override
  void dispose() {
    _float.removeListener(_recycle);
    _float.dispose();
    super.dispose();
  }

  void _pop(_Bubble b) {
    if (b.popped || _done) return;
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();
    setState(() => b.popped = true);
    Haptics.pop(settings.hapticsOn);

    if (b.glyph == widget.unit.glyph) {
      _correct += 1;
      audio.pop();
      audio.narrateArabic(widget.unit.ttsAr);
      if (_correct >= _needCorrect) {
        _done = true;
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          audio.success();
          Haptics.success(settings.hapticsOn);
          widget.onDone(GameResult(
              mistakes: min(_mistakes, 3),
              completed: true,
              skill: 'recognition'));
        });
      }
    } else {
      _mistakes += 1;
      audio.gentleWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    return Column(
      children: [
        InstructionBar(
          hintKey: 'popLetterHint',
          params: {'g': widget.unit.glyph},
          enKey: 'tap_letter',
          arText: S.fill(S.trOf('popLetterHint', true),
              {'g': widget.unit.glyph}),
          guideChar: 'lulu',
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
                  clipBehavior: Clip.none,
                  children: [
                    for (final b in _bubbles)
                      if (!b.popped) _bubbleWidget(b, w, h),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bubble_chart_rounded,
                    color: AppColors.blue, size: 20.sp),
                SizedBox(width: 6.sp),
                Text(
                  '${Helpers.digits(_correct, arabic: isAr)} / ${Helpers.digits(_needCorrect, arabic: isAr)}',
                  style: TextStyle(
                      fontSize: 18.sp, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubbleWidget(_Bubble b, double w, double h) {
    final t = _float.value;
    final cycle = (t * b.speed + b.phase) % 1.0;
    final y = h * (1.12 - cycle * 1.24);
    final sway = sin(cycle * pi * 2 + b.phase * 8) * w * 0.03;
    final size = 64.sp.clamp(52.0, 80.0);

    return Positioned(
      left: b.x * w + sway - size / 2,
      top: y,
      child: GestureDetector(
        onTap: () => _pop(b),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: [
                Colors.white.withOpacity(0.9),
                b.color.withOpacity(0.75),
                b.color.withOpacity(0.45),
              ],
            ),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: b.color.withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: GradientGlyph(
              glyph: b.glyph,
              size: size * 0.42,
              colors: [b.color, Color.lerp(b.color, Colors.black, 0.25)!],
              extrude: false,
            ),
          ),
        ),
      ),
    );
  }
}
