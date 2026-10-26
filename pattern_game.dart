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

/// Complete a simple AB pattern (A A B _).
/// Uses shapes/blobs/letters depending on the subject — real logic,
/// three options, no pressure.
class PatternGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final List<UnitDef> pool;
  final ValueChanged<GameResult> onDone;

  const PatternGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.pool,
    required this.onDone,
  });

  @override
  State<PatternGame> createState() => _PatternGameState();
}

class _PatternGameState extends State<PatternGame> {
  late final UnitDef _a;
  late final UnitDef _b;
  late final List<int> _pattern; // indices into [_a, _b]
  late final List<UnitDef> _options;
  late int _answerIndex;
  int _mistakes = 0;
  bool _done = false;
  int? _wrongPick;

  @override
  void initState() {
    super.initState();
    final others =
        Helpers.pickDistinct(widget.pool, 2, exclude: {widget.unit});
    _a = widget.unit;
    _b = others.first;
    _pattern = [0, 0, 1, -1]; // A A B ?
    _options = [_b, _a, others.length > 1 ? others[1] : _a];
    _options.shuffle();
    _answerIndex = _options.indexWhere((u) => u.id == _b.id);
    if (_answerIndex < 0) _answerIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.trOf('patternHint', context.isAr),
          enKey: 'tap_letter',
        );
      }
    });
  }

  void _pick(int index) {
    if (_done) return;
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();
    if (index == _answerIndex) {
      setState(() {
        _done = true;
        _pattern[3] = _options[index].id == _b.id ? 1 : 0;
      });
      Haptics.success(settings.hapticsOn);
      audio.success();
      Future.delayed(const Duration(milliseconds: 700), () {
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
    final items = [_a, _b];
    return Column(
      children: [
        InstructionBar(
          hintKey: 'patternHint',
          enKey: 'tap_letter',
          arText: S.trOf('patternHint', context.isAr),
          guideChar: widget.subject.guide,
        ),
        SizedBox(height: 18.sp),
        // Pattern row.
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.sp),
          padding: EdgeInsets.all(14.sp),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < _pattern.length; i++)
                _pattern[i] == -1
                    ? _gapCell()
                    : unitVisual(
                        context, items[_pattern[i]], 52.sp.clamp(42.0, 66.0)),
            ],
          ),
        ),
        SizedBox(height: 24.sp),
        // Options.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _options.length; i++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.sp),
                child: OptionCard(
                  width: 86.sp.clamp(70.0, 108.0),
                  height: 104.sp.clamp(84.0, 128.0),
                  state: _done && i == _answerIndex
                      ? OptionState.correct
                      : _wrongPick == i
                          ? OptionState.wrong
                          : OptionState.normal,
                  onTap: () => _pick(i),
                  child: Center(
                    child: unitVisual(
                        context, _options[i], 54.sp.clamp(44.0, 68.0)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _gapCell() {
    return Container(
      width: 56.sp.clamp(46.0, 70.0),
      height: 56.sp.clamp(46.0, 70.0),
      decoration: BoxDecoration(
        color: AppColors.sun.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.sun, width: 2.5),
      ),
      child: Icon(Icons.help_outline_rounded,
          color: AppColors.sun, size: 26.sp),
    );
  }
}
