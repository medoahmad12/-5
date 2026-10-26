import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/size_config.dart';
import '../l10n/app_strings.dart';
import '../services/settings_service.dart';
import 'confetti_painter.dart';

/// Full-screen celebration: confetti burst + cheering guide + stars.
/// Used after every completed lesson and for treasure chests.
class CelebrationOverlay extends StatefulWidget {
  final String charId;
  final String title;
  final int stars;
  final List<String> unlockedStickers; // sticker image assets
  final int newChests;
  final VoidCallback onContinue;

  const CelebrationOverlay({
    super.key,
    required this.charId,
    required this.title,
    this.stars = 3,
    this.unlockedStickers = const [],
    this.newChests = 0,
    required this.onContinue,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = context.watch<SettingsService>().reduceMotion;
    final stickers = widget.unlockedStickers;

    return Container(
      color: AppColors.ink.withOpacity(0.55),
      child: Center(
        child: Stack(
          children: [
            if (!reduceMotion)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => CustomPaint(
                    painter: ConfettiPainter(progress: _ctrl.value),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.stars.clamp(0, 3), (i) {
                    final delay = _ctrl.value > (0.15 + i * 0.18);
                    return AnimatedScale(
                      scale: delay ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.elasticOut,
                      child: Icon(Icons.star_rounded,
                          color: AppColors.star,
                          size: (52 - i * 6).sp.clamp(34.0, 60.0)),
                    );
                  }),
                ),
                SizedBox(height: 8.sp),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.sp.clamp(24.0, 40.0),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black38, blurRadius: 8),
                    ],
                  ),
                ),
                SizedBox(height: 10.sp),
                if (stickers.isNotEmpty || widget.newChests > 0)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.sp),
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        if (widget.newChests > 0)
                          Padding(
                            padding: EdgeInsets.only(bottom: 6.sp),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.card_giftcard_rounded,
                                    color: AppColors.gold,
                                    size: 22.sp.clamp(18.0, 28.0)),
                                SizedBox(width: 6.sp),
                                Flexible(
                                  child: Text(
                                    context.tr('treasureOpen'),
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (stickers.isNotEmpty)
                          Wrap(
                            spacing: 8.sp,
                            children: stickers
                                .map((a) => ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/$a',
                                        width: 52.sp.clamp(40.0, 64.0),
                                        height: 52.sp.clamp(40.0, 64.0),
                                        fit: BoxFit.cover,
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: 14.sp),
                Image.asset(
                  AppAssets.char(widget.charId, 'cheer'),
                  width: 130.sp.clamp(100.0, 170.0),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                SizedBox(height: 10.sp),
                GestureDetector(
                  onTap: widget.onContinue,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.sp, vertical: 12.sp),
                    decoration: BoxDecoration(
                      gradient: AppColors.grad('sun'),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.sun.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      context.tr('continueWord'),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
