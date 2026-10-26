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
import '../widgets/option_card.dart';

/// Find the odd one out:
///  - colors: three blobs share one color, one is different
///  - shapes: three share a shape, one is different
///  - letters: three share a glyph, one is different
class OddOneGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final List<UnitDef> pool;
  final ValueChanged<GameResult> onDone;

  const OddOneGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.pool,
    required this.onDone,
  });

  @override
  State<OddOneGame> createState() => _OddOneGameState();
}

class _OddOneGameState extends State<OddOneGame> {
  late final List<UnitDef> _items;
  late int _oddIndex;
  int _mistakes = 0;
  bool _done = false;
  int? _wrongPick;

  @override
  void initState() {
    super.initState();
    final others =
        Helpers.pickDistinct(widget.pool, 3, exclude: {widget.unit});
    // three "same" items clone the unit, the odd one is a different unit.
    _items = [widget.unit, widget.unit, widget.unit, others.first];
    _items.shuffle();
    _oddIndex = _items.indexWhere((u) => u.id != widget.unit.id);
    if (_oddIndex < 0) {
      _oddIndex = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.trOf('oddHint', context.isAr),
          enKey: 'odd_one',
        );
      }
    });
  }

  void _pick(int index) {
    if (_done) return;
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();
    if (index == _oddIndex) {
      setState(() => _done = true);
      Haptics.success(settings.hapticsOn);
      audio.success();
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) {
          widget.onDone(GameResult(
              mistakes: _mistakes,
              completed: true,
              skill: 'recognition'));
        }
      });
    } else {
      setState(() {
        _wrongPick = index;
        _mistakes += 1;
      });
      audio.gentleWrong();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _wrongPick = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InstructionBar(
          hintKey: 'oddHint',
          enKey: 'odd_one',
          arText: S.trOf('oddHint', context.isAr),
          guideChar: widget.subject.guide,
        ),
        SizedBox(height: 16.sp),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 12.sp,
              runSpacing: 12.sp,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _items.length; i++)
                  OptionCard(
                    width: 92.sp.clamp(76.0, 116.0),
                    height: 112.sp.clamp(92.0, 140.0),
                    state: _done && i == _oddIndex
                        ? OptionState.correct
                        : _wrongPick == i
                            ? OptionState.wrong
                            : OptionState.normal,
                    onTap: () => _pick(i),
                    child: Center(
                      child: unitVisual(
                          context, _items[i], 62.sp.clamp(50.0, 78.0)),
                    ),
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
