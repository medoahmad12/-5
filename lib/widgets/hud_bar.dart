import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../l10n/app_strings.dart';
import '../services/progress_service.dart';
import 'big_button.dart';
import 'star_row.dart';

/// Top bar for world screens: back / title / star count / parent button.
class HudBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onParent;

  const HudBar({
    super.key,
    required this.title,
    this.onBack,
    this.onParent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
        child: Row(
          children: [
            RoundIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
            SizedBox(width: 10.sp),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20.sp.clamp(17.0, 26.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            SizedBox(width: 10.sp),
            StarChip(count: progress.totalStars),
            SizedBox(width: 8.sp),
            // Small, unobtrusive parent entry. A gate protects it.
            GestureDetector(
              onTap: onParent,
              child: Container(
                width: 38.sp.clamp(34.0, 44.0),
                height: 38.sp.clamp(34.0, 44.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.settings_rounded,
                    size: 20.sp.clamp(18.0, 24.0), color: AppColors.inkSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress pill "3 من 28" used in subject hubs.
class ProgressPill extends StatelessWidget {
  final int done;
  final int total;
  final Color color;
  const ProgressPill({
    super.key,
    required this.done,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 18.sp, color: color),
          SizedBox(width: 5.sp),
          Text(
            S.fill(context.tr('completedOf'),
                {'done': Helpers.digits(done, arabic: context.isAr), 'total': Helpers.digits(total, arabic: context.isAr)}),
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
