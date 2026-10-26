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

/// Put the numbers in the right order so the train departs.
/// Tap numbers from smallest to biggest — each correct tap loads a wagon.
class TrainOrderGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final List<UnitDef> pool;
  final ValueChanged<GameResult> onDone;

  const TrainOrderGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.pool,
    required this.onDone,
  });

  @override
  State<TrainOrderGame> createState() => _TrainOrderGameState();
}

class _TrainOrderGameState extends State<TrainOrderGame> {
  late final List<int> _sequence;
  late final List<int> _cards;
  int _filled = 0;
  int _mistakes = 0;
  bool _done = false;
  bool _departure = false;
  String? _wrongCard;

  @override
  void initState() {
    super.initState();
    final target = int.tryParse(widget.unit.glyph) ?? 1;
    const len = 3;
    final start = (target - 1).clamp(0, 10 - len);
    _sequence = List.generate(len, (i) => start + i);
    _cards = Helpers.shuffled(_sequence);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.trOf('orderHint', context.isAr),
          enKey: 'order',
        );
      }
    });
  }

  void _tap(int n) {
    if (_done) return;
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();

    if (n == _sequence[_filled]) {
      setState(() {
        _filled += 1;
        _cards.remove(n);
      });
      Haptics.pop(settings.hapticsOn);
      audio.pop();
      if (_filled == _sequence.length) {
        _done = true;
        setState(() => _departure = true);
        audio.narrateArabic('قطار رائع!');
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          Haptics.success(settings.hapticsOn);
          audio.success();
          widget.onDone(GameResult(
              mistakes: _mistakes,
              completed: true,
              skill: 'counting'));
        });
      }
    } else {
      setState(() {
        _wrongCard = '$n';
        _mistakes += 1;
      });
      audio.gentleWrong();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _wrongCard = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    return Column(
      children: [
        InstructionBar(
          hintKey: 'orderHint',
          enKey: 'order',
          arText: S.trOf('orderHint', isAr),
          guideChar: 'toto',
        ),
        SizedBox(height: 10.sp),
        // Train: engine + wagons.
        AnimatedSlide(
          offset: _departure ? const Offset(1.6, 0) : Offset.zero,
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeInCubic,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _wagon('', isEngine: true),
              for (var i = 0; i < _sequence.length; i++)
                _wagon(
                  i < _filled ? Helpers.digits(_sequence[i], arabic: isAr) : '',
                ),
            ],
          ),
        ),
        SizedBox(height: 18.sp),
        // Number cards to tap in order.
        Expanded(
          child: Wrap(
            spacing: 12.sp,
            runSpacing: 12.sp,
            alignment: WrapAlignment.center,
            children: [
              for (final c in _cards)
                GestureDetector(
                  onTap: () => _tap(c),
                  child: AnimatedScale(
                    scale: _wrongCard == '$c' ? 0.88 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      width: 62.sp.clamp(50.0, 78.0),
                      height: 62.sp.clamp(50.0, 78.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _wrongCard == '$c'
                              ? AppColors.gentleError
                              : AppColors.mint,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: GradientGlyph(
                          glyph: Helpers.digits(c, arabic: false),
                          size: 30.sp.clamp(24.0, 38.0),
                          colors: const [
                            Color(0xFFA8EED7),
                            AppColors.mint
                          ],
                          extrude: false,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10.sp),
      ],
    );
  }

  Widget _wagon(String label, {bool isEngine = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.sp),
      width: isEngine ? 74.sp : 60.sp,
      height: 64.sp,
      decoration: BoxDecoration(
        color: isEngine ? AppColors.coral : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isEngine ? AppColors.red : AppColors.coral, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: isEngine
            ? Icon(Icons.directions_railway_rounded,
                color: Colors.white, size: 30.sp)
            : Text(
                label,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
      ),
    );
  }
}
