import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../core/constants/app_assets.dart';
import 'settings_service.dart';
import 'tts_service.dart';

/// Central audio manager.
///
/// - SFX   : small pool of low-latency players (bundled wav)
/// - Music : calm seamless loop (bundled ogg), independent volume
/// - Narration:
///     * English  -> bundled studio-quality ogg narration (fully offline)
///     * Arabic   -> device TTS voice (Google TTS Arabic, offline on most
///                   devices). Everything degrades gracefully.
class AudioService {
  final SettingsService settings;
  final TtsService tts = TtsService();

  final List<AudioPlayer> _sfxPool =
      List.generate(4, (_) => AudioPlayer());
  int _sfxIdx = 0;

  AudioPlayer? _music;
  AudioPlayer? _narration;

  AudioService(this.settings);

  Future<void> init() async {
    await tts.init();
    for (final p in _sfxPool) {
      try {
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
      } catch (_) {}
    }
    _narration = AudioPlayer();
    try {
      await _narration!.setReleaseMode(ReleaseMode.stop);
    } catch (_) {}
    await startMusic();
  }

  // ---------------- SFX ----------------

  Future<void> sfx(String name) async {
    if (!settings.soundOn) return;
    try {
      final p = _sfxPool[_sfxIdx];
      _sfxIdx = (_sfxIdx + 1) % _sfxPool.length;
      await p.stop();
      await p.play(AssetSource(AppAssets.sfx(name)));
    } catch (e) {
      debugPrint('sfx $name failed: $e');
    }
  }

  Future<void> tap() => sfx('tap');
  Future<void> pop() => sfx('pop');
  Future<void> star() => sfx('star');
  Future<void> success() => sfx('success');
  Future<void> gentleWrong() => sfx('gentle');
  Future<void> whoosh() => sfx('whoosh');
  Future<void> treasure() => sfx('treasure');
  Future<void> unlock() => sfx('unlock');

  // ---------------- Narration ----------------

  /// Bundled English narration; falls back to the device English voice if
  /// the asset is missing (never blocks the lesson).
  Future<void> narrateAsset(String assetPath,
      {String? fallbackEnText}) async {
    if (!settings.soundOn) return;
    stopNarration();
    try {
      await rootBundle.load(assetPath); // throws if the asset is absent
      await _narration?.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('narrateAsset $assetPath missing -> device TTS fallback');
      if (fallbackEnText != null) {
        await tts.speak(fallbackEnText, lang: 'en-US');
      }
    }
  }

  /// Arabic narration through the device voice.
  Future<void> narrateArabic(String text) async {
    if (!settings.soundOn) return;
    stopNarration();
    await tts.speak(text, lang: 'ar-SA');
  }

  /// English narration through the device voice (rare fallback when a
  /// bundled file is missing).
  Future<void> narrateEnglish(String text) async {
    if (!settings.soundOn) return;
    stopNarration();
    await tts.speak(text, lang: 'en-US');
  }

  Future<void> stopNarration() async {
    try {
      await _narration?.stop();
    } catch (_) {}
    await tts.stop();
  }

  // ---------------- Music ----------------

  Future<void> startMusic() async {
    if (!settings.musicOn) return;
    try {
      _music ??= AudioPlayer();
      await _music!.setReleaseMode(ReleaseMode.loop);
      await _music!.setVolume(0.28);
      await _music!.play(AssetSource(AppAssets.musicLoop));
    } catch (e) {
      debugPrint('music failed: $e');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _music?.stop();
    } catch (_) {}
  }

  /// Re-syncs music playback after a settings change.
  Future<void> syncMusic() async {
    if (settings.musicOn) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  Future<void> stopAll() async {
    await stopNarration();
    for (final p in _sfxPool) {
      try {
        await p.stop();
      } catch (_) {}
    }
  }

  void dispose() {
    tts.dispose();
    for (final p in _sfxPool) {
      p.dispose();
    }
    _narration?.dispose();
    _music?.dispose();
  }
}
