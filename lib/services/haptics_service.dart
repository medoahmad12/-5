import 'package:flutter/services.dart';

/// Gentle haptic feedback, gated by the parent settings toggle.
class Haptics {
  Haptics._();

  static void tap(bool enabled) {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  static void success(bool enabled) {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  static void pop(bool enabled) {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }
}
