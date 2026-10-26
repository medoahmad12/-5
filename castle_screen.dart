import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../data/models.dart';
import '../data/worlds.dart';
import '../l10n/app_strings.dart';
import '../services/progress_service.dart';
import '../widgets/big_button.dart';
import '../widgets/hud_bar.dart';
import '../widgets/world_scaffold.dart';

/// Heroes Castle: the child's trophy room — stickers, chests and heroes.
class CastleScreen extends StatelessWidget {
  const CastleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final progress = context.watch<ProgressService>();
    final total = progress.totalStars;

    return WorldScaffold(
      bgAsset: AppAssets.bgCastle,
      child: Column(
        children: [
          HudBar(
            title: context.tr('worldCastle'),
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Column(
                children: [
                  // Big counters.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _counter(
                        icon: Icons.star_rounded,
                        value: total,
                        label: context.tr('totalStars'),
                        color: AppColors.star,
                      ),
                      SizedBox(width: 12.sp),
                      _counter(
                        icon: Icons.emoji_events_rounded,
                        value: progress.lessonsDone,
                        label: context.tr('lessonsDone'),
                        color: AppColors.gold,
                      ),
                      SizedBox(width: 12.sp),
                      _counter(
                        icon: Icons.card_giftcard_rounded,
                        value: progress.chestsOpened,
                        label: context.tr('chests'),
                        color: AppColors.coral,
                      ),
                    ],
                  ),
                  SizedBox(height: 18.sp),

                  // Heroes row (always shown — they are friends, not rewards).
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final id in ['lulu', 'toto', 'bobo', 'foufo'])
                        Image.asset(
                          AppAssets.char(id, 'idle'),
                          width: 62.sp.clamp(50.0, 80.0),
                          height: 62.sp.clamp(50.0, 80.0),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                    ],
                  ),
                  SizedBox(height: 18.sp),

                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.tr('yourStickers'),
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink),
                    ),
                  ),
                  SizedBox(height: 10.sp),

                  // Sticker album.
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10.sp,
                    crossAxisSpacing: 10.sp,
                    childAspectRatio: 0.95,
                    children: [
                      for (final st in kStickers)
                        _StickerCell(
                          sticker: st,
                          owned: progress.stickers.contains(st.id),
                          totalStars: total,
                        ),
                    ],
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    context.tr('keepExploring'),
                    style: TextStyle(
                        fontSize: 14.sp, color: AppColors.inkSoft),
                  ),
                  SizedBox(height: 16.sp),
                  BigButton(
                    label: context.tr('backToMap'),
                    icon: Icons.map_rounded,
                    color: AppColors.mint,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _counter({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26.sp),
          Text(
            Helpers.digits(value, arabic: context.isAr),
            style: TextStyle(
                fontSize: 20.sp, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: TextStyle(
                fontSize: 10.5.sp, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _StickerCell extends StatelessWidget {
  final StickerDef sticker;
  final bool owned;
  final int totalStars;

  const _StickerCell({
    required this.sticker,
    required this.owned,
    required this.totalStars,
  });

  @override
  Widget build(BuildContext context) {
    final need = sticker.unlockStars - totalStars;
    return Container(
      decoration: BoxDecoration(
        color: owned
            ? Colors.white
            : Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: owned ? sticker.color : AppColors.lockedGray,
          width: owned ? 3 : 2,
        ),
        boxShadow: owned
            ? [
                BoxShadow(
                  color: sticker.color.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(6.sp),
      child: owned
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/images/${sticker.imageAsset ?? ''}',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                        Icons.star_rounded,
                        color: sticker.color,
                        size: 34.sp),
                  ),
                ),
                Text(
                  context.isAr ? sticker.nameAr : sticker.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded,
                    color: AppColors.lockedGray, size: 26.sp),
                SizedBox(height: 4.sp),
                Text(
                  S.fill(context.tr('lockedSticker'),
                      {'n': Helpers.digits(need.clamp(0, 999), arabic: context.isAr)}),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10.sp, color: AppColors.inkSoft),
                ),
              ],
            ),
    );
  }
}
