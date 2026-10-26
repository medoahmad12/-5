import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../data/worlds.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../widgets/star_row.dart';

/// Parent dashboard: progress overview, skills, review list and settings.
/// Fully offline; data stays on the device.
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final progress = context.watch<ProgressService>();
    final settings = context.watch<SettingsService>();
    final audio = context.read<AudioService>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(14.sp),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 44.sp,
                      height: 44.sp,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: AppColors.ink, size: 22.sp),
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Text(
                      context.tr('dashboard'),
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 14.sp),
                children: [
                  // ---------- profile ----------
                  _Card(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26.sp,
                          backgroundColor: AppColors.lulu.withOpacity(0.3),
                          child: ClipOval(
                            child: Image.asset(
                              AppAssets.char(progress.avatar, 'idle'),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.child_care_rounded,
                                      color: AppColors.lulu),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                progress.childName.isEmpty
                                    ? context.tr('hello')
                                    : '${context.tr('hello')} ${progress.childName}',
                                style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${context.tr('totalStars')}: ${Helpers.digits(progress.totalStars, arabic: context.isAr)}',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.inkSoft),
                              ),
                            ],
                          ),
                        ),
                        StarRow(
                            stars: (progress.totalStars / 15)
                                .clamp(0, 3)
                                .round(),
                            size: 18.sp),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.sp),

                  // ---------- worlds progress ----------
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('progressOverview'),
                            style: _titleStyle()),
                        SizedBox(height: 10.sp),
                        for (final w in kWorlds)
                          if (w.subjectId != null)
                            _WorldBar(world: w),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.sp),

                  // ---------- skills ----------
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('skills'),
                            style: _titleStyle()),
                        SizedBox(height: 10.sp),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _skill(context, 'listening',
                                context.tr('skillListening')),
                            _skill(context, 'recognition',
                                context.tr('skillRecognition')),
                          ],
                        ),
                        SizedBox(height: 8.sp),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _skill(context, 'counting',
                                context.tr('skillCounting')),
                            _skill(context, 'memory',
                                context.tr('skillMemory')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.sp),

                  // ---------- needs review ----------
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('needsReview'),
                            style: _titleStyle()),
                        SizedBox(height: 8.sp),
                        if (progress.reviewQueue.isEmpty)
                          Text(context.tr('noReview'),
                              style: _bodyStyle())
                        else
                          Wrap(
                            spacing: 6.sp,
                            runSpacing: 6.sp,
                            children: [
                              for (final key in progress.reviewQueue)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.sp,
                                      vertical: 5.sp),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.sun.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _conceptLabel(key),
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.sp),

                  // ---------- settings ----------
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('settings'),
                            style: _titleStyle()),
                        SizedBox(height: 6.sp),

                        _switchRow(
                          context,
                          icon: Icons.music_note_rounded,
                          label: context.tr('sound'),
                          value: settings.soundOn,
                          onChanged: (v) => settings.setSound(v),
                        ),
                        _switchRow(
                          context,
                          icon: Icons.queue_music_rounded,
                          label: context.tr('music'),
                          value: settings.musicOn,
                          onChanged: (v) {
                            settings.setMusic(v);
                            audio.syncMusic();
                          },
                        ),
                        _switchRow(
                          context,
                          icon: Icons.vibration_rounded,
                          label: context.tr('haptics'),
                          value: settings.hapticsOn,
                          onChanged: (v) => settings.setHaptics(v),
                        ),
                        _switchRow(
                          context,
                          icon: Icons.accessibility_new_rounded,
                          label: context.tr('reduceMotion'),
                          value: settings.reduceMotion,
                          onChanged: (v) => settings.setReduceMotion(v),
                        ),
                        _switchRow(
                          context,
                          icon: Icons.lock_open_rounded,
                          label: context.tr('unlockAllWorlds'),
                          value: settings.unlockAll,
                          onChanged: (v) => settings.setUnlockAll(v),
                        ),

                        // language segmented
                        SizedBox(height: 8.sp),
                        Row(
                          children: [
                            Icon(Icons.translate_rounded,
                                size: 20.sp, color: AppColors.inkSoft),
                            SizedBox(width: 8.sp),
                            Expanded(
                              child: Text(context.tr('language'),
                                  style: _bodyStyle()),
                            ),
                            _langChip(context, 'العربية', 'ar',
                                settings.locale == 'ar'),
                            SizedBox(width: 6.sp),
                            _langChip(context, 'English', 'en',
                                settings.locale == 'en'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.sp),

                  // ---------- reset ----------
                  _Card(
                    color: AppColors.coral.withOpacity(0.08),
                    child: Column(
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.delete_forever_rounded,
                              color: AppColors.coral, size: 22.sp),
                          label: Text(
                            context.tr('resetProgress'),
                            style: TextStyle(
                                color: AppColors.coral,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => _confirmReset(context),
                        ),
                      ],
                    ),
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

  TextStyle _titleStyle() => TextStyle(
      fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.ink);
  TextStyle _bodyStyle() => TextStyle(
      fontSize: 13.5.sp, color: AppColors.inkSoft, height: 1.3);

  String _conceptLabel(String key) {
    // key: '<subject>.<unit>' — show the glyph/name.
    final parts = key.split('.');
    if (parts.length != 2) return key;
    final subject = kSubjects[parts[0]];
    if (subject == null) return key;
    for (final u in subject.units) {
      if (u.id == parts[1]) {
        return u.glyph.isEmpty ? u.nameAr : u.glyph;
      }
    }
    return key;
  }

  Widget _skill(BuildContext context, String skill, String label) {
    final progress = context.watch<ProgressService>();
    final level = progress.skillLevel(skill);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _bodyStyle()),
          SizedBox(height: 4.sp),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Container(
                  width: 18.sp,
                  height: 7.sp,
                  margin: EdgeInsets.only(right: 3.sp),
                  decoration: BoxDecoration(
                    color: i < level
                        ? AppColors.mint
                        : AppColors.lockedGray.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _switchRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.mint,
      contentPadding: EdgeInsets.zero,
      dense: true,
      secondary: Icon(icon, size: 20.sp, color: AppColors.inkSoft),
      title: Text(label, style: _bodyStyle()),
    );
  }

  Widget _langChip(BuildContext context, String label, String code,
      bool selected) {
    final settings = context.read<SettingsService>();
    return GestureDetector(
      onTap: () => settings.setLocale(code),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.blue : AppColors.lockedGray),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.ink),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    final progress = context.read<ProgressService>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('resetConfirmTitle')),
        content: Text(dialogContext.tr('resetConfirmBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              progress.resetAll();
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(dialogContext.tr('resetProgress')),
              ));
            },
            child: Text(
              dialogContext.tr('confirm'),
              style: const TextStyle(color: AppColors.coral),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color? color;
  const _Card({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _WorldBar extends StatelessWidget {
  final WorldDef world;
  const _WorldBar({required this.world});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final subject = kSubjects[world.subjectId]!;
    final done = progress.subjectCompletedCount(subject);
    final frac = subject.units.isEmpty
        ? 0.0
        : done / subject.units.length;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.isAr ? world.titleAr : world.titleEn,
                style: TextStyle(
                    fontSize: 13.sp, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                S.fill(context.tr('completedOf'), {
                  'done': Helpers.digits(done, arabic: context.isAr),
                  'total': Helpers.digits(subject.units.length,
                      arabic: context.isAr),
                }),
                style: TextStyle(
                    fontSize: 12.sp, color: AppColors.inkSoft),
              ),
            ],
          ),
          SizedBox(height: 4.sp),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 10.sp,
              backgroundColor: AppColors.lockedGray.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(world.color),
            ),
          ),
        ],
      ),
    );
  }
}
