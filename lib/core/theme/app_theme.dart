import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// App-wide typography & component theme, tuned for preschoolers:
/// big rounded playful type (Baloo Bhaijaan 2 covers Arabic + Latin).
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'BalooBhaijaan2';

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        secondary: AppColors.mint,
        surface: AppColors.cream,
        error: AppColors.coral,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: fontFamily,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        iconTheme: IconThemeData(color: AppColors.ink),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sun,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(140, 56),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
          shadowColor: Colors.brown,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          color: AppColors.inkSoft,
          height: 1.4,
        ),
      ),
    );
  }
}
