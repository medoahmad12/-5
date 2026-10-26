import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/size_config.dart';
import '../services/settings_service.dart';
import 'confetti_painter.dart';

/// Shared screen scaffold: painted sky gradient + world background image
/// with a soft depth vignette, optional floating sparkles.
/// All screens feel like parts of one living world.
class WorldScaffold extends StatelessWidget {
  final String bgAsset;
  final Widget child;
  final bool showSparkles;

  const WorldScaffold({
    super.key,
    required this.bgAsset,
    required this.child,
    this.showSparkles = true,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = context.watch<SettingsService>().reduceMotion;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyTop, AppColors.skyBottom],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // World background art, cover-fitted with bounded cache size.
            Image.asset(
              bgAsset,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.low,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            // Soft top scrim so HUD text stays readable on bright art.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: SizeConfig.fh(0.16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.55),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showSparkles && !reduceMotion)
              const AmbientSparkles(count: 8),
            child,
          ],
        ),
      ),
    );
  }
}
