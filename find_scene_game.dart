import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../data/models.dart';
import '../game_engine/game_utils.dart';
import '../game_engine/instruction_bar.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/settings_service.dart';
import '../widgets/gradient_glyph.dart';
import '../widgets/option_card.dart';

/// Find the hidden letters inside a busy scene.
/// Two copies of the target letter hide among decoys (including a
/// visually similar one) — a real search game, no timers.
class FindSceneGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final List<UnitDef> pool;
  final ValueChanged<GameResult> onDone;

  const FindSceneGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.pool,
    required this.onDone,
  });

  @override
  State<FindSceneGame> createState() => _FindSceneGameState();
}

class _Tile {
  final String glyph;
  final Color color;
  final Offset pos; // fractional 0..1
  final double rot;
  bool found = false;
  _Tile({
    required this.glyph,
    required this.color,
    required this.pos,
    required this.rot,
  });
}

class _FindSceneGameState extends State<FindSceneGame> {
  late final List<_Tile> _tiles;
  int _found = 0;
  int _mistakes = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    // decoys: include a visually similar glyph for gentle challenge
    final decoys = <UnitDef>[
      ...Helpers.pickDistinct(
          widget.pool.where((u) => u.glyph.isNotEmpty).toList(),
          7,
          exclude: {widget.unit}),
    ];
    _tiles = [
      // two hidden targets
      for (var i = 0; i < 2; i++)
        _Tile(
          glyph: widget.unit.glyph,
          color: widget.unit.color,
          pos: _scatter(rng, i),
          rot: (rng.nextDouble() - 0.5) * 0.5,
        ),
      // seven decoys
      for (final d in decoys)
        _Tile(
          glyph: d.glyph,
          color: d.color,
          pos: _scatter(rng, 10 + decoys.indexOf(d)),
          rot: (rng.nextDouble() - 0.5) * 0.5,
        ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.fill(S.trOf('findHint', context.isAr),
              {'g': widget.unit.glyph}),
          enKey: 'find_hidden',
        );
        context.read<AudioService>().narrateArabic(widget.unit.ttsAr);
      }
    });
  }

  Offset _scatter(Random rng, int seed) {
    // deterministic-ish spread with jitter, inside safe margins
    final col = seed % 3;
    final row = (seed ~/ 3) % 3;
    return Offset(
      0.14 + col * 0.32 + (rng.nextDouble() - 0.5) * 0.10,
      0.12 + row * 0.36 + (rng.nextDouble() - 0.5) * 0.10,
    );
  }

  void _tapTile(_Tile t) {
    if (_done || t.found) return;
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();
    if (t.glyph == widget.unit.glyph) {
      setState(() => t.found = true);
      _found += 1;
      Haptics.pop(settings.hapticsOn);
      audio.pop();
      audio.narrateArabic(widget.unit.ttsAr);
      if (_found == 2) {
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
      setState(() => _mistakes += 1);
      audio.gentleWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InstructionBar(
          hintKey: 'findHint',
          params: {'g': widget.unit.glyph},
          enKey: 'find_hidden',
          arText: S.fill(S.trOf('findHint', true),
              {'g': widget.unit.glyph}),
          guideChar: widget.subject.guide,
        ),
        SizedBox(height: 10.sp),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.sp),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withOpacity(0.9), width: 4),
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  final w = box.maxWidth;
                  final h = box.maxHeight;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final t in _tiles)
                        Positioned(
                          left: t.pos.dx * w - 26.sp,
                          top: t.pos.dy * h - 26.sp,
                          child: GestureDetector(
                            onTap: () => _tapTile(t),
                            child: AnimatedScale(
                              scale: t.found ? 1.25 : 1.0,
                              duration:
                                  const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: Transform.rotate(
                                angle: t.rot,
                                child: Opacity(
                                  opacity: t.found ? 0.45 : 1.0,
                                  child: GradientGlyph(
                                    glyph: t.glyph,
                                    size: 52.sp.clamp(42.0, 66.0),
                                    colors: [
                                      Color.lerp(
                                          t.color, Colors.white, 0.5)!,
                                      t.color,
                                    ],
                                    extrude: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 10.sp),
      ],
    );
  }
}
