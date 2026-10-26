import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
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
import '../widgets/big_button.dart';
import '../widgets/hud_bar.dart';
import '../widgets/world_scaffold.dart';
import 'castle_screen.dart';
import 'parent_gate_screen.dart';
import 'subject_hub_screen.dart';

/// The heart of the app: a living world of five islands the child can tap.
/// Islands bob gently, the sky drifts, locked islands show what they need.
class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _bobs;
  late final AnimationController _drift;

  /// island positions as fractional (x, y) of the scene area.
  static const List<Offset> _spots = [
    Offset(0.24, 0.26), // arabic
    Offset(0.74, 0.40), // numbers
    Offset(0.27, 0.55), // english
    Offset(0.72, 0.68), // colors
    Offset(0.50, 0.85), // castle
  ];

  @override
  void initState() {
    super.initState();
    _bobs = List.generate(kWorlds.length, (i) {
      final c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1700 + i * 260),
      );
      c.repeat(reverse: true);
      return c;
    });
    _drift = AnimationController(
        vsync: this, duration: const Duration(seconds: 14))
      ..repeat();
  }

  @override
  void dispose() {
    for (final c in _bobs) {
      c.dispose();
    }
    _drift.dispose();
    super.dispose();
  }

  void _openWorld(WorldDef world) {
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();
    final progress = context.read<ProgressService>();
    final unlocked = progress.worldUnlocked(world, unlockAll: settings.unlockAll);

    if (!unlocked) {
      audio.gentleWrong();
      Haptics.tap(settings.hapticsOn);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          S.fill(
            context.tr('needStars'),
            {'n': Helpers.digits(world.starThreshold, arabic: context.isAr)},
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 15.sp),
        ),
      ));
      return;
    }

    audio.whoosh();
    Haptics.tap(settings.hapticsOn);
    if (world.subjectId == null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const CastleScreen()));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              SubjectHubScreen(subjectId: world.subjectId!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final progress = context.watch<ProgressService>();
    final settings = context.watch<SettingsService>();
    final reduceMotion = settings.reduceMotion;

    return WorldScaffold(
      bgAsset: AppAssets.bgMap,
      child: Column(
        children: [
          HudBar(
            title: context.tr('worldMap'),
            onParent: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ParentGateScreen())),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    // Gentle sky drift for depth (disabled in reduce motion).
                    if (!reduceMotion)
                      AnimatedBuilder(
                        animation: _drift,
                        builder: (context, _) => Transform.translate(
                          offset: Offset(
                              sin(_drift.value * 2 * pi) * 6, 0),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    for (var i = 0; i < kWorlds.length; i++)
                      _islandNode(i, w, h, reduceMotion, progress, settings),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _islandNode(int i, double w, double h, bool reduceMotion,
      ProgressService progress, SettingsService settings) {
    final world = kWorlds[i];
    final unlocked = progress.worldUnlocked(world, unlockAll: settings.unlockAll);
    final spot = _spots[i];

    final node = _IslandBubble(
      world: world,
      unlocked: unlocked,
      size: 96.sp.clamp(78.0, 120.0),
    );

    return AnimatedBuilder(
      animation: _bobs[i],
      builder: (context, child) {
        final dy =
            reduceMotion ? 0.0 : sin(_bobs[i].value * pi) * 7;
        return Positioned(
          left: spot.dx * w - 60.sp,
          top: spot.dy * h - 60.sp + dy,
          child: child!,
        );
      },
      child: GestureDetector(
        onTap: () => _openWorld(world),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            node,
            SizedBox(height: 6.sp),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                context.isAr ? world.titleAr : world.titleEn,
                style: TextStyle(
                  fontSize: 13.sp.clamp(11.0, 17.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round island bubble: character thumb on a glowing colored ring,
/// with lock overlay + star requirement when locked.
class _IslandBubble extends StatelessWidget {
  final WorldDef world;
  final bool unlocked;
  final double size;

  const _IslandBubble({
    required this.world,
    required this.unlocked,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final thumbAsset = world.thumbChar == 'luluCheer'
        ? AppAssets.char('lulu', 'cheer')
        : AppAssets.char(world.thumbChar, 'idle');

    final ring = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(world.color, Colors.white, 0.4)!,
            world.color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: world.color.withOpacity(unlocked ? 0.55 : 0.2),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(5.sp),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(4.sp),
        child: ClipOval(
          child: unlocked
              ? Image.asset(thumbAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.explore_rounded))
              : Image.asset(thumbAsset,
                  fit: BoxFit.contain,
                  color: Colors.grey,
                  colorBlendMode: BlendMode.saturation,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.lock_rounded)),
        ),
      ),
    );

    if (unlocked) {
      // little glyph badge on top of the ring
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          ring,
          Positioned(
            top: -4,
            left: size * 0.08,
            child: Container(
              padding: EdgeInsets.all(3.sp),
              decoration: BoxDecoration(
                color: AppColors.paper,
                shape: BoxShape.circle,
                border: Border.all(color: world.color, width: 2),
              ),
              child: world.iconGlyph.isNotEmpty
                  ? Text(
                      world.iconGlyph,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: world.color,
                        height: 1.0,
                      ),
                    )
                  : Icon(Icons.flag_rounded,
                      size: 14.sp, color: world.color),
            ),
          ),
        ],
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        ring,
        Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded,
                  color: Colors.white, size: size * 0.22),
              SizedBox(height: 2.sp),
              Icon(Icons.star_rounded,
                  color: AppColors.star, size: size * 0.16),
            ],
          ),
        ),
      ],
    );
  }
}
