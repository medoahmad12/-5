import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/audio_service.dart';
import 'services/progress_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kids app: portrait keeps the world map and drag games predictable.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final settings = SettingsService();
  final progress = ProgressService();
  await settings.load();
  await progress.load();

  final audio = AudioService(settings);
  // Fire-and-forget: never block first frame on audio engines.
  unawaited(audio.init());

  runApp(LittleExplorersApp(
    settings: settings,
    progress: progress,
    audio: audio,
  ));
}
