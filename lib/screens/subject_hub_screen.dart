import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../data/models.dart';
import '../data/worlds.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../widgets/character_view.dart';
import '../widgets/gradient_glyph.dart';
import '../widgets/hud_bar.dart';
import '../widgets/shape_glyph.dart';
import '../widgets/star_row.dart';
import '../widgets/world_scaffold.dart';
import 'lesson_flow_screen.dart';

/// A learning track rendered as a winding adventure path.
/// Each node is a letter/number/color; the next node pulses invitingly.
/// A review bubble appears when the child struggled with earlier concepts.
class SubjectHubScreen extends StatelessWidget {
  final String subjectId;
  const SubjectHubScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final subject = kSubjects[subjectId]!;
    final progress = context.watch<ProgressService>();
    final audio = context.read<AudioService>();

    final completed = progress.subjectCompletedCount(subject);
    final hasReview = progress.hasReviewFor(subject.id);

    return WorldScaffold(
      bgAsset: subject.bgAsset,
      child: Column(
        children: [
          HudBar(
            title: context.isAr ? subject.titleAr : subject.titleEn,
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: Row(
              children: [
                ProgressPill2(
                  done: completed,
                  total: subject.units.length,
                  color: subject.color,
                ),
                const Spacer(),
                if (hasReview)
                  _ReviewBubble(subject: subject),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final w = box.maxWidth;
                final h = box.maxHeight;
                final n = subject.units.length;
                return Stack(
                  children: [
                    CustomPaint(
                      size: Size(w, h),
                      painter: _PathPainter(
                          color: subject.color.withOpacity(0.65),
                          points: List.generate(
                              n, (i) => _nodePos(i, n, w, h))),
                    ),
                    for (var i = 0; i < n; i++)
                      _UnitNode(
                        subject: subject,
                        index: i,
                        position: _nodePos(i, n, w, h),
                      ),
                    // Guide character at the bottom corner.
                    Positioned(
                      bottom: 6,
                      left: Directionality.of(context) == TextDirection.rtl
                          ? 8
                          : null,
                      right: Directionality.of(context) == TextDirection.rtl
                          ? null
                          : 8,
                      child: CharacterView(
                        charId: subject.guide,
                        size: 86.sp.clamp(64.0, 110.0),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Offset _nodePos(int i, int n, double w, double h) {
    final t = n == 1 ? 0.5 : i / (n - 1);
    final y = h * 0.90 - t * h * 0.80;
    final x = w / 2 + sin(i * 1.25 + 0.6) * w * 0.26;
    return Offset(x.clamp(50.0, w - 50.0), y);
  }
}

/// Dashed connection path between nodes.
class _PathPainter extends CustomPainter {
  final Color color;
  final List<Offset> points;
  _PathPainter({required this.color, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final ctrl = Offset((a.dx + b.dx) / 2 + (b.dy - a.dy) * 0.18,
          (a.dy + b.dy) / 2);
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy);
      _drawDashed(canvas, path, paint);
    }
  }

  void _drawDashed(Canvas canvas, Path source, Paint paint) {
    for (final metric in source.computeMetrics()) {
      var dist = 0.0;
      const dashLen = 12.0;
      const gapLen = 10.0;
      while (dist < metric.length) {
        final next = min(dist + dashLen, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) => old.color != color;
}

/// One unit node on the path.
class _UnitNode extends StatelessWidget {
  final SubjectDef subject;
  final int index;
  final Offset position;

  const _UnitNode({
    required this.subject,
    required this.index,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final unit = subject.units[index];
    final progress = context.watch<ProgressService>();
    final settings = context.watch<SettingsService>();
    final audio = context.read<AudioService>();
    final unlocked = progress.isUnitUnlocked(subject, index);
    final stars = progress.unitStars(subject.id, unit.id);
    final nextIdx = progress.firstIncompleteIndex(subject);
    final isNext = unlocked && stars == 0 && index == nextIdx;
    final size = 58.sp.clamp(46.0, 74.0);

    Widget core;
    if (subject.isNumbers) {
      core = GradientGlyph(
        glyph: unit.glyph,
        size: size * 0.52,
        colors: [AppColors.cardGradients['sun']![0], unit.color],
        extrude: false,
      );
    } else if (unit.glyph.isEmpty) {
      // color blob
      core = Container(
        width: size * 0.62,
        height: size * 0.62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            Color.lerp(unit.color, Colors.white, 0.45)!,
            unit.color,
          ]),
          border: Border.all(color: Colors.white, width: 3),
        ),
      );
    } else if (unit.glyph == 'circle' ||
        unit.glyph == 'square' ||
        unit.glyph == 'triangle' ||
        unit.glyph == 'star' ||
        unit.glyph == 'heart' ||
        unit.glyph == 'rectangle' ||
        unit.glyph == 'diamond' ||
        unit.glyph == 'oval') {
      core = ShapeGlyph(kind: unit.glyph, color: unit.color, size: size * 0.66, withFace: false);
    } else {
      core = GradientGlyph(
        glyph: unit.glyph,
        size: size * 0.5,
        colors: [
          Color.lerp(unit.color, Colors.white, 0.5)!,
          unit.color,
        ],
        extrude: false,
      );
    }

    final node = GestureDetector(
      onTap: () {
        if (!unlocked) {
          audio.gentleWrong();
          Haptics.tap(settings.hapticsOn);
          return;
        }
        audio.whoosh();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LessonFlowScreen(
              subject: subject, unitIndex: index),
        ));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? Colors.white : AppColors.lockedGray.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: subject.color.withOpacity(isNext ? 0.75 : 0.28),
                  blurRadius: isNext ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isNext ? subject.color : Colors.white,
                width: isNext ? 3.5 : 2.5,
              ),
            ),
            child: Center(
              child: unlocked
                  ? core
                  : Icon(Icons.lock_rounded,
                      size: size * 0.38, color: AppColors.inkSoft),
            ),
          ),
          SizedBox(height: 3.sp),
          if (unlocked && stars > 0)
            StarRow(stars: stars, size: 13.sp.clamp(10.0, 16.0)),
        ],
      ),
    );

    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: node,
    );
  }
}

class ProgressPill2 extends StatelessWidget {
  final int done;
  final int total;
  final Color color;
  const ProgressPill2({
    super.key,
    required this.done,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 17.sp, color: color),
          SizedBox(width: 5.sp),
          Text(
            S.fill(context.tr('completedOf'), {
              'done': Helpers.digits(done, arabic: context.isAr),
              'total': Helpers.digits(total, arabic: context.isAr),
            }),
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

/// Foufou's review invitation.
class _ReviewBubble extends StatelessWidget {
  final SubjectDef subject;
  const _ReviewBubble({required this.subject});

  @override
  Widget build(BuildContext context) {
    final audio = context.read<AudioService>();
    return GestureDetector(
      onTap: () {
        audio.whoosh();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LessonFlowScreen.review(subject: subject),
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
        decoration: BoxDecoration(
          color: AppColors.purple.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.purple, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 16.sp, color: AppColors.purple),
            SizedBox(width: 5.sp),
            Text(
              context.tr('quickReview'),
              style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.purple),
            ),
          ],
        ),
      ),
    );
  }
}
