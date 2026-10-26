import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/progress_service.dart';
import 'services/settings_service.dart';

/// Root widget: providers + MaterialApp with full RTL support.
class LittleExplorersApp extends StatefulWidget {
  final SettingsService settings;
  final ProgressService progress;
  final AudioService audio;

  const LittleExplorersApp({
    super.key,
    required this.settings,
    required this.progress,
    required this.audio,
  });

  @override
  State<LittleExplorersApp> createState() => _LittleExplorersAppState();
}

class _LittleExplorersAppState extends State<LittleExplorersApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.audio.dispose();
    super.dispose();
  }

  /// Save on background/kill so the child never loses progress.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      widget.progress.save();
      widget.settings.save();
      widget.audio.stopAll();
    } else if (state == AppLifecycleState.resumed) {
      widget.audio.syncMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.settings),
        ChangeNotifierProvider.value(value: widget.progress),
        Provider<AudioService>.value(value: widget.audio),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'عالم المستكشفين الصغار',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: settings.flutterLocale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              // Keep text scaling sane on tablets & accessibility settings.
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: mq.textScaler.clamp(0.9, 1.25),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
