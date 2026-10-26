import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/size_config.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import 'game_utils.dart';

/// Instruction bar shown on top of every mini game:
/// short text + replay button + friendly guide pose.
class InstructionBar extends StatelessWidget {
  final String hintKey; // string key for the text
  final Map<String, String> params;
  final String enKey; // english bundled instruction asset key
  final String arText; // arabic text for device TTS
  final String guideChar;

  const InstructionBar({
    super.key,
    required this.hintKey,
    this.params = const {},
    required this.enKey,
    required this.arText,
    this.guideChar = 'lulu',
  });

  @override
  Widget build(BuildContext context) {
    final text = S.fill(context.tr(hintKey),
        params.map((k, v) => MapEntry(k, v)));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 4.sp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => narrateHint(context, arText: arText, enKey: enKey),
              child: Container(
                width: 38.sp.clamp(32.0, 46.0),
                height: 38.sp.clamp(32.0, 46.0),
                decoration: const BoxDecoration(
                  color: AppColors.sun,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.volume_up_rounded,
                    color: Colors.white, size: 20.sp.clamp(17.0, 24.0)),
              ),
            ),
            SizedBox(width: 10.sp),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
