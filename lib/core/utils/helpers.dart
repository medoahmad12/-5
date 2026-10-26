import 'dart:math';

/// Small shared helpers used across the app.
class Helpers {
  Helpers._();

  static const String _arDigits = '٠١٢٣٤٥٦٧٨٩';

  /// Convert a number to locale-appropriate digits
  /// (Arabic-Indic ٠١٢٣ or Western 0123).
  static String digits(int n, {bool arabic = true}) {
    final s = n.toString();
    if (!arabic) return s;
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      final v = int.tryParse(ch);
      buf.write(v == null ? ch : _arDigits[v]);
    }
    return buf.toString();
  }

  static final Random _rng = Random();

  static int randInt(int min, int max) => min + _rng.nextInt(max - min + 1);

  static T pick<T>(List<T> list) => list[_rng.nextInt(list.length)];

  /// Shuffle without mutating the original list.
  static List<T> shuffled<T>(List<T> list) {
    final copy = List<T>.of(list);
    copy.shuffle(_rng);
    return copy;
  }

  /// Pick [n] distinct items (excluding [exclude]) from [pool].
  static List<T> pickDistinct<T>(List<T> pool, int n,
      {Set<T> exclude = const {}}) {
    final candidates = pool.where((e) => !exclude.contains(e)).toList();
    candidates.shuffle(_rng);
    return candidates.take(n).toList();
  }

  static double clamp01(double v) => v.clamp(0.0, 1.0);
}
