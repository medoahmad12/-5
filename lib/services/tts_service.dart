import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Device text-to-speech wrapper.
///
/// Arabic narration uses the device's built-in Arabic voice (Google TTS),
/// which works offline on most Android devices. Every call is wrapped so a
/// missing engine or missing language degrades gracefully (visual-only
/// feedback) instead of crashing.
class TtsService {
  FlutterTts? _tts;
  bool _available = false;
  String _currentLang = '';

  bool get available => _available;

  Future<void> init() async {
    try {
      final tts = FlutterTts();
      await tts.setStartHandler(() {});
      await tts.setCompletionHandler(() {});
      await tts.setErrorHandler((msg) {});
      // Kid-friendly voice: slow-ish rate, slightly higher pitch.
      await tts.setSpeechRate(0.42);
      await tts.setPitch(1.15);
      await tts.setVolume(1.0);
      _tts = tts;
      _available = true;
    } catch (e) {
      debugPrint('TTS init failed: $e');
      _available = false;
    }
  }

  Future<bool> _ensureLang(String code) async {
    final tts = _tts;
    if (tts == null || !_available) return false;
    if (_currentLang == code) return true;
    try {
      var ok = await tts.isLanguageAvailable(code);
      if (ok != true && code.contains('-')) {
        ok = await tts.isLanguageAvailable(code.split('-').first);
        code = code.split('-').first;
      }
      if (ok == true) {
        await tts.setLanguage(code);
        _currentLang = code;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> speak(String text, {String lang = 'ar-SA'}) async {
    final tts = _tts;
    if (tts == null || !_available || text.trim().isEmpty) return;
    final ok = await _ensureLang(lang);
    if (!ok) return;
    try {
      await tts.stop();
      await tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    final tts = _tts;
    if (tts == null) return;
    try {
      await tts.stop();
    } catch (_) {}
  }

  void dispose() {
    stop();
  }
}
