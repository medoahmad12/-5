import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/size_config.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import 'onboarding_screen.dart';
import 'world_map_screen.dart';

/// Splash: quick brand moment, then straight to the child's world
/// (or onboarding on first run).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _ctrl.forward();
    // Ensure music engine is up (init is fire-and-forget in main).
    Timer(const Duration(milliseconds: 400), () {
      context.read<AudioService>().syncMusic();
    });
    Timer(const Duration(milliseconds: 1500), _go);
  }

  void _go() {
    if (!mounted) return;
    final progress = context.read<ProgressService>();
    final hasProfile = progress.childName.trim().isNotEmpty;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) =>
          hasProfile ? const WorldMapScreen() : const OnboardingScreen(),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final reduceMotion = context.read<SettingsService>().reduceMotion;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyTop, AppColors.skyBottom],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: reduceMotion
                    ? const AlwaysStoppedAnimation(1)
                    : CurvedAnimation(
                        parent: _ctrl, curve: Curves.elasticOut),
                child: Image.asset(
                  AppAssets.icon,
                  width: 120.sp.clamp(96.0, 150.0),
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.explore_rounded,
                    size: 100,
                    color: AppColors.sun,
                  ),
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                context.tr('appName'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp.clamp(22.0, 36.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 6.sp),
              Text(
                context.tr('tagline'),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
