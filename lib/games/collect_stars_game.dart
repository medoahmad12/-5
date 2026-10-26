
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

/// Collect all six stars in the meadow. A pure-fun reward game for the
/// youngest explorers — no failure state at all.
class CollectStarsGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final ValueChanged<GameResult> onDone;

  const CollectStarsGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.onDone,
  });

  @override
  State<CollectStarsGame> createState() => _CollectStarsGameState();
}

class _StarItem {
  final int id;
  final double x, y, rot;
  bool collected;
  _StarItem({
    required this.id,
    required this.x,
    required this.y,
    required this.rot,
  });
}

class _CollectStarsGameState extends State<CollectStarsGame> {
  late final List<_StarItem> _stars;
  late final List<Offset> _flowers;
  int _found = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final rng = Random(7);
    _stars = List.generate(6, (i) => _StarItem(
          id: i,
          x: 0.1 + rng.nextDouble() * 0.8,
          y: 0.08 + rng.nextDouble() * 0.78,
          rot: rng.nextDouble() * 0.6 - 0.3,
        ));
    _flowers = List.generate(
        5,
        (_) => Offset(
            0.06 + rng.nextDouble() * 0.88, 0.05 + rng.nextDouble() * 0.85));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.trOf('gameCollect', context.isAr),
          enKey: 'count',
        );
      }
    });
  }

  void _collect(_StarItem s) {
    if (s.collected || _done) return;
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();
    setState(() => s.collected = true);
    Haptics.pop(settings.hapticsOn);
    audio.star();
    _found += 1;
    if (_found == _stars.length) {
      _done = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        audio.success();
        Haptics.success(settings.hapticsOn);
        widget.onDone(const GameResult(
            mistakes: 0, completed: true, skill: 'recognition'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InstructionBar(
          hintKey: 'gameCollect',
          enKey: 'count',
          arText: S.trOf('gameCollect', context.isAr),
          guideChar: widget.subject.guide,
        ),
        SizedBox(height: 8.sp),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final h = box.maxHeight;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // decorative flowers (not clickable goals)
                  for (final f in _flowers)
                    Positioned(
                      left: f.dx * w - 20,
                      top: f.dy * h - 20,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: 0.85,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                Colors.white,
                                AppColors.pink.withOpacity(0.8),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  for (final s in _stars)
                    Positioned(
                      left: s.x * w - 30,
                      top: s.y * h - 30,
                      child: GestureDetector(
                        onTap: () => _collect(s),
                        child: AnimatedScale(
                          scale: s.collected ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutBack,
                          child: Transform.rotate(
                            angle: s.rot,
                            child: Icon(
                              Icons.star_rounded,
                              size: 60.sp.clamp(48.0, 76.0),
                              color: AppColors.star,
                              shadows: const [
                                Shadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3)),
                              ],
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
        Container(
          padding: EdgeInsets.symmetric(vertical: 6.sp),
          color: Colors.white.withOpacity(0.6),
          child: Center(
            child: Text(
              '${Helpers.digits(_found, arabic: context.isAr)} / ${Helpers.digits(_stars.length, arabic: context.isAr)}',
              style: TextStyle(
                  fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
