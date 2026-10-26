import 'package:flutter/material.dart';

/// Responsive sizing helper.
/// All screens scale from a 390x840 reference so the app adapts to phones
/// and tablets without overflow.
class SizeConfig {
  SizeConfig._();

  static double _scale = 1.0;
  static double w = 390;
  static double h = 840;

  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    w = mq.size.width;
    h = mq.size.height;
    _scale = (w / 390.0).clamp(0.72, 1.7);
    // On very short/wide screens keep text readable but compact.
    final hScale = (h / 840.0).clamp(0.72, 1.7);
    if (hScale < _scale) _scale = hScale;
  }

  /// Scaled pixel size.
  static double sp(double v) => v * _scale;

  /// Scaled radius.
  static double rad(double v) => v * _scale;

  /// Fractional helper (0..1 of width).
  static double fw(double f) => w * f;

  /// Fractional helper (0..1 of height).
  static double fh(double f) => h * f;
}

extension SizerNum on num {
  double get sp => SizeConfig.sp(toDouble());
}
