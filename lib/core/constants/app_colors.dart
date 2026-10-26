import 'package:flutter/material.dart';

/// Global visual identity for "Little Explorers World".
/// A professional kids palette: soft, warm and balanced (no oversaturation).
class AppColors {
  AppColors._();

  // ---- Backgrounds / sky ----
  static const Color skyTop = Color(0xFF6FBBF0);
  static const Color skyBottom = Color(0xFFCDEBFF);
  static const Color cream = Color(0xFFFFF7E8);
  static const Color paper = Color(0xFFFFFDF6);

  // ---- Ink / text ----
  static const Color ink = Color(0xFF3A3335);
  static const Color inkSoft = Color(0xFF6E6265);
  static const Color inkOnDark = Color(0xFFFFFFFF);

  // ---- Brand accents ----
  static const Color sun = Color(0xFFFFC93C);
  static const Color star = Color(0xFFFFB703);
  static const Color orange = Color(0xFFFF9F5A);
  static const Color coral = Color(0xFFEF6461);
  static const Color red = Color(0xFFE4572E);
  static const Color pink = Color(0xFFFF8FB1);
  static const Color purple = Color(0xFFA78BFA);
  static const Color blue = Color(0xFF4EA8DE);
  static const Color skyBlue = Color(0xFF7EC8F7);
  static const Color mint = Color(0xFF7FD8BE);
  static const Color green = Color(0xFF58C27D);
  static const Color teal = Color(0xFF2EC4B6);
  static const Color brown = Color(0xFFA47148);
  static const Color gold = Color(0xFFE7B10A);

  // ---- Success / feedback ----
  static const Color success = Color(0xFF58C27D);
  static const Color gentleError = Color(0xFFF2A65A);
  static const Color lockedGray = Color(0xFFB9B4AE);

  // ---- Character tints ----
  static const Color lulu = Color(0xFFFFB03A); // lion gold
  static const Color toto = Color(0xFFF7A6C1); // bunny rose
  static const Color bobo = Color(0xFF6FC7EE); // robot sky
  static const Color foufo = Color(0xFF9BD77E); // butterfly mint-green

  /// Soft card gradient pairs [top, bottom].
  static Map<String, List<Color>> cardGradients = {
    'blue': [const Color(0xFF8FD3FF), const Color(0xFF4EA8DE)],
    'mint': [const Color(0xFFA8EED7), const Color(0xFF57C8A2)],
    'sun': [const Color(0xFFFFE29A), const Color(0xFFFFC93C)],
    'coral': [const Color(0xFFFFB199), const Color(0xFFFF8A70)],
    'pink': [const Color(0xFFFFC2D4), const Color(0xFFFF8FB1)],
    'purple': [const Color(0xFFCDB9FF), const Color(0xFFA78BFA)],
    'green': [const Color(0xFFB2EBB4), const Color(0xFF58C27D)],
    'gold': [const Color(0xFFFFE08A), const Color(0xFFE7B10A)],
  };

  static List<Color> grad(String key) => cardGradients[key] ?? cardGradients['blue']!;
}
