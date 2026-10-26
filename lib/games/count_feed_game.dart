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
import '../widgets/character_view.dart';

/// Feed Toto N carrots, one by one. Each accepted carrot counts out loud,
/// so the number is always tied to a real quantity.
class CountFeedGame extends StatefulWidget {
  final SubjectDef subject;
  final UnitDef unit;
  final ValueChanged<GameResult> onDone;

  const CountFeedGame({
    super.key,
    required this.subject,
    required this.unit,
    required this.onDone,
  });

  @override
  State<CountFeedGame> createState() => _CountFeedGameState();
}

class _CountFeedGameState extends State<CountFeedGame> {
  late final int _target;
  int _fed = 0;
  bool _done = false;
  bool _munching = false;

  @override
  void initState() {
    super.initState();
    _target = int.tryParse(widget.unit.glyph) ?? 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        narrateHint(
          context,
          arText: S.fill(S.trOf('feedHint', context.isAr),
              {'n': Helpers.digits(_target, arabic: context.isAr)}),
          enKey: 'feed',
        );
      }
    });
  }

  void _feedCarrot() {
    if (_done) return;
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();

    if (_fed >= _target) return; // plate is full — carrot bounces back

    setState(() {
      _fed += 1;
      _munching = true;
    });
    Haptics.pop(settings.hapticsOn);
    audio.pop();

    // count out loud
    if (settings.isAr) {
      const names = [
        'واحِد', 'اثنان', 'ثَلاثة', 'أَربعة', 'خَمسة',
        'سِتّة', 'سَبعة', 'ثَمانية', 'تِسعة', 'عَشَرة'
      ];
      audio.narrateArabic(names[(_fed - 1).clamp(0, 9)]);
    } else {
      audio.narrateAsset('audio/en/num_$_fed.ogg');
    }

    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) setState(() => _munching = false);
    });

    if (_fed == _target) {
      _done = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        Haptics.success(settings.hapticsOn);
        audio.success();
        widget.onDone(GameResult(
            mistakes: 0, completed: true, skill: 'counting'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    final remaining = _target - _fed;

    return Column(
      children: [
        InstructionBar(
          hintKey: 'feedHint',
          params: {'n': Helpers.digits(_target, arabic: isAr)},
          enKey: 'feed',
          arText: S.fill(S.trOf('feedHint', true),
              {'n': Helpers.digits(_target, arabic: true)}),
          guideChar: 'toto',
        ),
        SizedBox(height: 10.sp),
        // Toto + plate (the drop target).
        DragTarget<int>(
          builder: (context, candidate, _) {
            return AnimatedScale(
              scale: candidate.isNotEmpty ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: AnimatedScale(
                scale: _munching ? 0.94 : 1.0,
                duration: const Duration(milliseconds: 130),
                child: Column(
                  children: [
                    CharacterView(
                        charId: 'toto',
                        size: 110.sp.clamp(88.0, 140.0)),
                    // plate
                    Container(
                      width: 130.sp.clamp(104.0, 160.0),
                      height: 26.sp.clamp(20.0, 34.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.mint, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${Helpers.digits(_fed, arabic: isAr)} / ${Helpers.digits(_target, arabic: isAr)}',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          onWillAccept: (data) => data == 0 && !_done && remaining > 0,
          onAccept: (data) => _feedCarrot(),
        ),
        SizedBox(height: 14.sp),
        // Carrot tray.
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 12.sp,
              runSpacing: 12.sp,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _target + 2; i++)
                  Draggable<int>(
                    data: 0, // all carrots are the same
                    feedback: Material(
                      color: Colors.transparent,
                      child: CarrotWidget(size: 46.sp),
                    ),
                    childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: CarrotWidget(size: 44.sp)),
                    child: remaining > 0
                        ? CarrotWidget(size: 44.sp)
                        : Opacity(
                            opacity: 0.25,
                            child: CarrotWidget(size: 40.sp)),
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

/// A cute drawn carrot (no image asset needed — pure vectors).
class CarrotWidget extends StatelessWidget {
  final double size;
  const CarrotWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 0.6,
      height: size,
      child: CustomPaint(painter: _CarrotPainter()),
    );
  }
}

class _CarrotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final body = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB25E), Color(0xFFF2811D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.2, w, h * 0.8));

    // leaves
    final leaf = Paint()..color = const Color(0xFF58C27D);
    canvas.drawCircle(Offset(w * 0.3, h * 0.12), w * 0.16, leaf);
    canvas.drawCircle(Offset(w * 0.62, h * 0.10), w * 0.18, leaf);

    // carrot body: rounded triangle
    final path = Path()
      ..moveTo(w * 0.14, h * 0.22)
      ..quadraticBezierTo(w * 0.5, h * 0.10, w * 0.86, h * 0.22)
      ..quadraticBezierTo(w * 0.62, h * 0.72, w * 0.5, h * 0.97)
      ..quadraticBezierTo(w * 0.38, h * 0.72, w * 0.14, h * 0.22)
      ..close();
    canvas.drawShadow(path, Colors.black45, 2.0, false);
    canvas.drawPath(path, body);

    // little stripes
    final stripe = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.3, h * 0.4),
        Offset(w * 0.58, h * 0.36), stripe);
    canvas.drawLine(Offset(w * 0.36, h * 0.58),
        Offset(w * 0.56, h * 0.55), stripe);
  }

  @override
  bool shouldRepaint(covariant _CarrotPainter old) => false;
}
