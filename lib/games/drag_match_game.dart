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
import '../widgets/picture_card.dart';

/// Drag the letter onto the matching picture.
/// Real Draggable/DragTarget mechanics with snap + gentle bounce-back.
class DragMatchGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final List<UnitDef> pool;
  final ValueChanged<GameResult> onDone;

  const DragMatchGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.pool,
    required this.onDone,
  });

  @override
  State<DragMatchGame> createState() => _DragMatchGameState();
}

class _DragMatchGameState extends State<DragMatchGame> {
  late final List<UnitDef> _pictures;
  int _mistakes = 0;
  bool _done = false;
  String? _wrongTarget;

  @override
  void initState() {
    super.initState();
    final withImages =
        widget.pool.where((u) => u.imageAsset != null).toList();
    _pictures = [
      widget.unit,
      ...Helpers.pickDistinct(withImages, 2, exclude: {widget.unit}),
    ];
    _pictures.shuffle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.trOf('dragHint', context.isAr),
          enKey: 'drag_pic',
        );
      }
    });
  }

  void _droppedOn(UnitDef target) {
    if (_done) return;
    final settings = context.read<SettingsService>();
    final audio = context.read<AudioService>();
    if (target.id == widget.unit.id) {
      setState(() => _done = true);
      Haptics.success(settings.hapticsOn);
      audio.success();
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) {
          widget.onDone(GameResult(
              mistakes: _mistakes,
              completed: true,
              skill: 'matching'));
        }
      });
    } else {
      setState(() {
        _wrongTarget = target.id;
        _mistakes += 1;
      });
      audio.gentleWrong();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _wrongTarget = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    final glyph = widget.unit.glyph;
    final label = isAr
        ? (widget.unit.wordAr ?? '')
        : (widget.unit.wordEn ?? '');

    return Column(
      children: [
        InstructionBar(
          hintKey: 'dragHint',
          enKey: 'drag_pic',
          arText: S.trOf('dragHint', isAr),
          guideChar: widget.subject.guide,
        ),
        SizedBox(height: 12.sp),
        Text(
          label,
          style: TextStyle(
              fontSize: 22.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6.sp),
        // Draggable glyph chip.
        Draggable<String>(
          data: widget.unit.id,
          feedback: Material(
            color: Colors.transparent,
            child: GradientGlyph(
              glyph: glyph,
              size: 64.sp,
              colors: [
                Color.lerp(widget.unit.color, Colors.white, 0.5)!,
                widget.unit.color,
              ],
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.35,
            child: GradientGlyph(
              glyph: glyph,
              size: 58.sp,
              colors: [
                Color.lerp(widget.unit.color, Colors.white, 0.5)!,
                widget.unit.color,
              ],
            ),
          ),
          child: GradientGlyph(
            glyph: glyph,
            size: 58.sp,
            colors: [
              Color.lerp(widget.unit.color, Colors.white, 0.5)!,
              widget.unit.color,
            ],
          ),
        ),
        SizedBox(height: 14.sp),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final p in _pictures)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: DragTarget<String>(
                    builder: (context, candidate, rejected) {
                      final isTarget = candidate.isNotEmpty;
                      return AnimatedScale(
                        scale: isTarget ? 1.06 : 1.0,
                        duration: const Duration(milliseconds: 160),
                        child: PictureCard(
                          objectName: p.imageAsset ?? 'apple',
                          size: 108.sp.clamp(88.0, 132.0),
                          borderColor: _wrongTarget == p.id
                              ? AppColors.gentleError
                              : (_done && p.id == widget.unit.id
                                  ? AppColors.success
                                  : null),
                          label: isAr
                              ? (p.wordAr ?? '')
                              : (p.wordEn ?? ''),
                        ),
                      );
                    },
                    onWillAccept: (data) => !_done,
                    onAccept: (data) => _droppedOn(p),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.sp),
      ],
    );
  }
}
