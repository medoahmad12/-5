import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
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

/// Visual memory: flip cards and find the matching pairs.
/// Uses object pictures (or glyphs as fallback) with a soft flip animation.
class MemoryGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final List<UnitDef> pool;
  final int pairs;
  final ValueChanged<GameResult> onDone;

  const MemoryGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.pool,
    required this.pairs,
    required this.onDone,
  });

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late final List<_MemCard> _cards;
  int _mistakes = 0;
  int? _firstOpen;
  bool _lock = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final withImages =
        widget.pool.where((u) => u.imageAsset != null).toList();
    final chosen = {
      widget.unit,
      ...Helpers.pickDistinct(
          withImages.isNotEmpty ? withImages : widget.pool,
          widget.pairs - 1,
          exclude: {widget.unit}),
    };
    _cards = [
      for (final u in chosen) ...[
        _MemCard(unit: u),
        _MemCard(unit: u),
      ]
    ];
    _cards.shuffle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.trOf('gameMemory', context.isAr),
          enKey: 'memory',
        );
      }
    });
  }

  void _tap(int index) {
    if (_lock || _done) return;
    final card = _cards[index];
    if (card.matched || card.open) return;

    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();
    Haptics.pop(settings.hapticsOn);
    audio.tap();

    setState(() => card.open = true);

    if (_firstOpen == null) {
      _firstOpen = index;
      return;
    }

    final first = _cards[_firstOpen!];
    if (first.unit.id == card.unit.id) {
      // Pair found!
      first.matched = true;
      card.matched = true;
      _firstOpen = null;
      audio.pop();
      if (_cards.every((c) => c.matched)) {
        _done = true;
        Haptics.success(settings.hapticsOn);
        audio.success();
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            widget.onDone(GameResult(
                mistakes: _mistakes,
                completed: true,
                skill: 'memory'));
          }
        });
      }
    } else {
      _mistakes += 1;
      _lock = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          first.open = false;
          card.open = false;
          _firstOpen = null;
          _lock = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cols = 3;
    final cardSize = (SizeConfig.w - 48.sp - (cols - 1) * 10.sp) / cols;

    return Column(
      children: [
        InstructionBar(
          hintKey: 'gameMemory',
          enKey: 'memory',
          arText: S.trOf('gameMemory', context.isAr),
          guideChar: widget.subject.guide,
        ),
        SizedBox(height: 10.sp),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 10.sp,
              runSpacing: 10.sp,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _cards.length; i++)
                  _CardWidget(
                    card: _cards[i],
                    size: cardSize.clamp(64.0, 110.0),
                    onTap: () => _tap(i),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.sp),
      ],
    );
  }
}

class _MemCard {
  final UnitDef unit;
  bool open;
  bool matched;
  _MemCard({required this.unit}) : open = false, matched = false;
}

class _CardWidget extends StatelessWidget {
  final _MemCard card;
  final double size;
  final VoidCallback onTap;

  const _CardWidget({
    required this.card,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final face = card.matched || card.open;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: card.matched ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) {
            final scale =
                Tween(begin: 0.6, end: 1.0).animate(anim);
            return ScaleTransition(scale: scale, child: child);
          },
          child: Container(
            key: ValueKey('${card.unit.id}_$face'),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: face ? Colors.white : AppColors.blue,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: card.matched ? AppColors.success : Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: face
                ? Center(
                    child: card.unit.imageAsset != null
                        ? Image.asset(
                            AppAssets.object(card.unit.imageAsset!),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_rounded),
                          )
                        : GradientGlyph(
                            glyph: card.unit.glyph,
                            size: size * 0.5,
                            colors: [
                              Color.lerp(
                                  card.unit.color, Colors.white, 0.5)!,
                              card.unit.color,
                            ],
                            extrude: false,
                          ),
                  )
                : const Icon(Icons.help_outline_rounded,
                    color: Colors.white, size: 34),
          ),
        ),
      ),
    );
  }
}
