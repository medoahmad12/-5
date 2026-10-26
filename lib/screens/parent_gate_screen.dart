import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/settings_service.dart';
import 'parent_dashboard_screen.dart';

/// Parent gate: a simple multiplication problem keeps curious little
/// fingers out of the dashboard. No ads, no links — just math.
class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key});

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  late int _a;
  late int _b;
  String _entry = '';
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _roll();
  }

  void _roll() {
    setState(() {
      _a = Helpers.randInt(3, 9);
      _b = Helpers.randInt(3, 9);
      _entry = '';
      _wrong = false;
    });
  }

  void _digit(String d) {
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsService>();
    Haptics.tap(settings.hapticsOn);
    audio.tap();
    if (_entry.length >= 3) return;
    setState(() => _entry += d);

    final expected = (_a * _b).toString();
    if (_entry == expected) {
      audio.success();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ParentDashboardScreen()));
    } else if (_entry.length >= expected.length) {
      setState(() => _wrong = true);
      audio.gentleWrong();
      Future.delayed(const Duration(milliseconds: 700), _roll);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: AppColors.ink.withOpacity(0.82),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_rounded,
                    color: Colors.white70, size: 44.sp),
                SizedBox(height: 8.sp),
                Text(
                  context.tr('parentZone'),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.sp),
                  child: Text(
                    context.tr('parentGateHint'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13.sp,
                        height: 1.35),
                  ),
                ),
                SizedBox(height: 20.sp),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.sp, vertical: 14.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${context.tr('solve')}: ${Helpers.digits(_a, arabic: context.isAr)} × ${Helpers.digits(_b, arabic: context.isAr)} = ${_wrong ? '؟' : _entry.isEmpty ? '؟' : Helpers.digits(int.tryParse(_entry) ?? 0, arabic: context.isAr)}',
                    style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: _wrong
                            ? AppColors.coral
                            : AppColors.ink),
                  ),
                ),
                SizedBox(height: 18.sp),
                _keypad(),
                SizedBox(height: 14.sp),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    context.tr('cancel'),
                    style: TextStyle(
                        color: Colors.white70, fontSize: 15.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypad() {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '<'],
    ];
    return Column(
      children: [
        for (final row in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final key in row)
                key.isEmpty
                    ? SizedBox(width: 64.sp, height: 60.sp)
                    : _Key(
                        label: key,
                        onTap: () {
                          if (key == '<') {
                            setState(() {
                              if (_entry.isNotEmpty) {
                                _entry =
                                    _entry.substring(0, _entry.length - 1);
                              }
                              _wrong = false;
                            });
                          } else {
                            _digit(key);
                          }
                        },
                      ),
            ],
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Key({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.sp),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64.sp.clamp(54.0, 76.0),
          height: 60.sp.clamp(50.0, 70.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
