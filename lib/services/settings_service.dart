import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App settings, persisted locally. Nothing here ever leaves the device.
class SettingsService extends ChangeNotifier {
  String locale = 'ar'; // 'ar' | 'en'
  bool soundOn = true;
  bool musicOn = true;
  bool hapticsOn = true;
  bool reduceMotion = false;
  bool unlockAll = false; // parent override for world locks

  bool get isAr => locale == 'ar';

  Locale get flutterLocale => Locale(locale);

  static const String _key = 'little_explorers_settings_v1';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      locale = (map['locale'] as String?) ?? 'ar';
      soundOn = (map['sound'] as bool?) ?? true;
      musicOn = (map['music'] as bool?) ?? true;
      hapticsOn = (map['haptics'] as bool?) ?? true;
      reduceMotion = (map['reduceMotion'] as bool?) ?? false;
      unlockAll = (map['unlockAll'] as bool?) ?? false;
    } catch (_) {
      // Corrupted settings fall back to defaults — never block startup.
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode({
        'locale': locale,
        'sound': soundOn,
        'music': musicOn,
        'haptics': hapticsOn,
        'reduceMotion': reduceMotion,
        'unlockAll': unlockAll,
      }));
    } catch (_) {}
  }

  void _changed() {
    save();
    notifyListeners();
  }

  void setLocale(String v) {
    if (v != 'ar' && v != 'en') return;
    locale = v;
    _changed();
  }

  void toggleLocale() => setLocale(isAr ? 'en' : 'ar');

  void setSound(bool v) { soundOn = v; _changed(); }
  void setMusic(bool v) { musicOn = v; _changed(); }
  void setHaptics(bool v) { hapticsOn = v; _changed(); }
  void setReduceMotion(bool v) { reduceMotion = v; _changed(); }
  void setUnlockAll(bool v) { unlockAll = v; _changed(); }
}
