import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../data/models.dart';
import '../game_engine/instruction_bar.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/settings_service.dart';
import '../widgets/gradient_glyph.dart';
import '../widgets/option_card.dart';

/// English: match the BIG letter with the small letter.
class MatchCaseGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final List<UnitDef> pool;
  final ValueChanged<GameResult> onDone;

  const MatchCaseGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.pool,
    required this.onDone,
  });

  @override
  State<MatchCaseGame> createState() => _MatchCaseGameState();
}

class _MatchCaseGameState extends State<MatchCaseGame> {
  late final List<String> _lowers;
  int _mistakes = 0;
  bool _done = false;
  String? _wrongPick;

  @override
  void initState() {
    super.initState();
    final others =
        Helpers.pickDistinct(widget.pool, 2, exclude: {widget.unit});
    _lowers = [
      widget.unit.glyph.toLowerCase(),
      ...others.map((u) => u.glyph.toLowerCase()),
    ];
    _lowers.shuffle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.trOf('matchCaseHint', context.isAr),
          enKey: 'match_case',
        );
      }
    });
  }

  void _pick(String lower) {
    if (_done) return;
    final settings = context.read<SettingsService>();
    final audio = context.read<AudioService>();
    if (lower == widget.unit.glyph.toLowerCase()) {
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
        _wrongPick = lower;
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
          hintKey: 'matchCaseHint',
          enKey: 'match_case',
          arText: S.trOf('matchCaseHint', context.isAr),
          guideChar: widget.subject.guide,
        ),
        SizedBox(height: 14.sp),
        // The BIG letter.
        Container(
          width: 120.sp.clamp(96.0, 150.0),
          height: 120.sp.clamp(96.0, 150.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: widget.unit.color, width: 4),
            boxShadow: [
              BoxShadow(
                color: widget.unit.color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: GradientGlyph(
              glyph: widget.unit.glyph,
              size: 66.sp.clamp(52.0, 84.0),
              colors: [
                Color.lerp(widget.unit.color, Colors.white, 0.5)!,
                widget.unit.color,
              ],
              extrude: false,
            ),
          ),
        ),
        SizedBox(height: 20.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final l in _lowers)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.sp),
                child: OptionCard(
                  width: 88.sp.clamp(70.0, 110.0),
                  height: 100.sp.clamp(82.0, 124.0),
                  state: _done && l == widget.unit.glyph.toLowerCase()
                      ? OptionState.correct
                      : _wrongPick == l
                          ? OptionState.wrong
                          : OptionState.normal,
                  onTap: () => _pick(l),
                  child: Center(
                    child: GradientGlyph(
                      glyph: l,
                      size: 44.sp.clamp(36.0, 56.0),
                      colors: const [Color(0xFF8FD3FF), Color(0xFF4EA8DE)],
                      extrude: false,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
