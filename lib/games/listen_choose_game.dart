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

/// Hear the letter/number/color, then tap the right card.
/// After two tries the correct card glows gently — never a dead end.
class ListenChooseGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final List<UnitDef> pool;
  final int difficulty;
  final ValueChanged<GameResult> onDone;

  const ListenChooseGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.pool,
    required this.difficulty,
    required this.onDone,
  });

  @override
  State<ListenChooseGame> createState() => _ListenChooseGameState();
}

class _ListenChooseGameState extends State<ListenChooseGame> {
  late final List<UnitDef> _options;
  int _mistakes = 0;
  bool _hint = false;
  bool _done = false;
  String? _wrongId;

  @override
  void initState() {
    super.initState();
    _options = [
      widget.unit,
      ...Helpers.pickDistinct(
          widget.pool, 2, exclude: {widget.unit}),
    ];
    _options.shuffle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      narrateUnitName(context, widget.subject, widget.unit);
    });
  }

  void _replay() =>
      narrateUnitName(context, widget.subject, widget.unit);

  void _choose(UnitDef u) {
    if (_done) return;
    final settings = context.read<SettingsService>();
    final audio = context.read<AudioService>();

    if (u.id == widget.unit.id) {
      setState(() => _done = true);
      Haptics.success(settings.hapticsOn);
      audio.success();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          widget.onDone(GameResult(
              mistakes: _mistakes,
              completed: true,
              skill: 'listening'));
        }
      });
    } else {
      setState(() {
        _wrongId = u.id;
        _mistakes += 1;
        if (_mistakes >= 2) _hint = true;
      });
      audio.gentleWrong();
      Haptics.tap(settings.hapticsOn);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _wrongId = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InstructionBar(
          hintKey: 'listenHint',
          enKey: 'listen_choose',
          arText: S.trOf('gameListen', context.isAr),
          guideChar: widget.subject.guide,
        ),
        SizedBox(height: 8.sp),
        // Big replay button.
        GestureDetector(
          onTap: _replay,
          child: Container(
            width: 92.sp.clamp(76.0, 110.0),
            height: 92.sp.clamp(76.0, 110.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.grad('sun'),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sun.withOpacity(0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(Icons.music_note_rounded,
                color: Colors.white, size: 40.sp.clamp(32.0, 50.0)),
          ),
        ),
        SizedBox(height: 18.sp),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final o in _options)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: OptionCard(
                    width: 96.sp.clamp(78.0, 120.0),
                    height: 118.sp.clamp(96.0, 145.0),
                    state: o.id == widget.unit.id && (_hint || _done)
                        ? OptionState.hint
                        : o.id == _wrongId
                            ? OptionState.wrong
                            : _done && o.id == widget.unit.id
                                ? OptionState.correct
                                : OptionState.normal,
                    onTap: () => _choose(o),
                    child: Center(
                      child: unitVisual(
                          context, o, 64.sp.clamp(52.0, 80.0)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 14.sp),
      ],
    );
  }
}
