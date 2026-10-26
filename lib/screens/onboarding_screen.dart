import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../widgets/big_button.dart';
import '../widgets/character_view.dart';
import 'world_map_screen.dart';

/// First-run onboarding: welcome -> language -> name & favorite friend.
/// Three big steps, no reading required, parent can help.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  final TextEditingController _name = TextEditingController();
  String _avatar = 'lulu';
  int _page = 0;

  void _next() {
    context.read<AudioService>().tap();
    Haptics.tap(context.read<SettingsService>().hapticsOn);
    _pages.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    final progress = context.read<ProgressService>();
    progress.setProfile(
      name: _name.text.trim().isEmpty ? '' : _name.text.trim(),
      avatarId: _avatar,
    );
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WorldMapScreen()));
  }

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyTop, AppColors.skyBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pages,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _buildWelcome(),
                    _buildLanguage(),
                    _buildProfile(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_page > 0)
                      RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => _pages.previousPage(
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeOutCubic,
                        ),
                      )
                    else
                      const SizedBox(width: 46),
                    Text(
                      '${Helpers.digits(_page + 1, arabic: context.isAr)} / ${Helpers.digits(3, arabic: context.isAr)}',
                      style: TextStyle(
                          color: AppColors.inkSoft, fontSize: 14.sp),
                    ),
                    _page == 2
                        ? BigButton(
                            label: context.tr('letsGo'),
                            icon: Icons.explore_rounded,
                            onTap: _finish,
                          )
                        : BigButton(
                            label: context.tr('continueWord'),
                            icon: Icons.arrow_forward_rounded,
                            onTap: _next,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- page 1: welcome ----------------
  Widget _buildWelcome() {
    return Padding(
      padding: EdgeInsets.all(24.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CharacterView(charId: 'lulu', size: 170.sp.clamp(130.0, 220.0)),
          SizedBox(height: 16.sp),
          Text(
            context.tr('appName'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27.sp.clamp(22.0, 34.0),
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 8.sp),
          Text(
            context.tr('tagline'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: AppColors.inkSoft),
          ),
          SizedBox(height: 14.sp),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 14.sp, vertical: 8.sp),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded,
                    size: 16.sp, color: AppColors.green),
                SizedBox(width: 6.sp),
                Flexible(
                  child: Text(
                    context.tr('privateNote'),
                    style: TextStyle(
                        fontSize: 11.5.sp, color: AppColors.inkSoft),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- page 2: language ----------------
  Widget _buildLanguage() {
    final settings = context.watch<SettingsService>();
    return Padding(
      padding: EdgeInsets.all(24.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.translate_rounded,
              size: 44.sp, color: AppColors.blue),
          SizedBox(height: 10.sp),
          Text(
            context.tr('chooseLanguage'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 22.sp),
          _LangCard(
            title: 'العربية',
            subtitle: 'Arabic',
            selected: settings.locale == 'ar',
            color: AppColors.green,
            onTap: () => settings.setLocale('ar'),
          ),
          SizedBox(height: 14.sp),
          _LangCard(
            title: 'English',
            subtitle: 'الإنجليزية',
            selected: settings.locale == 'en',
            color: AppColors.blue,
            onTap: () => settings.setLocale('en'),
          ),
        ],
      ),
    );
  }

  // ---------------- page 3: name + friend ----------------
  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.sp),
      child: Column(
        children: [
          Text(
            context.tr('whatsName'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 12.sp),
          TextField(
            controller: _name,
            textAlign: TextAlign.center,
            maxLength: 12,
            decoration: InputDecoration(
              hintText: context.tr('nameHint'),
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.sp, vertical: 14.sp),
            ),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 18.sp),
          Text(
            context.tr('chooseFriend'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 12.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FriendCard(
                  id: 'lulu', selected: _avatar == 'lulu',
                  color: AppColors.lulu,
                  onTap: () => setState(() => _avatar = 'lulu')),
              _FriendCard(
                  id: 'toto', selected: _avatar == 'toto',
                  color: AppColors.toto,
                  onTap: () => setState(() => _avatar = 'toto')),
            ],
          ),
          SizedBox(height: 10.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FriendCard(
                  id: 'bobo', selected: _avatar == 'bobo',
                  color: AppColors.bobo,
                  onTap: () => setState(() => _avatar = 'bobo')),
              _FriendCard(
                  id: 'foufo', selected: _avatar == 'foufo',
                  color: AppColors.foufo,
                  onTap: () => setState(() => _avatar = 'foufo')),
            ],
          ),
        ],
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _LangCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 230.sp.clamp(190.0, 280.0),
        padding: EdgeInsets.symmetric(vertical: 18.sp, horizontal: 18.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: selected ? color : Colors.transparent, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(selected ? 0.45 : 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 13.sp, color: AppColors.inkSoft)),
          ],
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final String id;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FriendCard({
    required this.id,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AudioService>().tap();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 120.sp.clamp(96.0, 150.0),
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : Colors.transparent, width: 3),
        ),
        child: Column(
          children: [
            Image.asset(
              AppAssets.char(id, 'idle'),
              width: 84.sp.clamp(64.0, 110.0),
              height: 84.sp.clamp(64.0, 110.0),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.pets, color: color, size: 48),
            ),
            AnimatedScale(
              scale: selected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.check_circle_rounded,
                  color: color, size: 28.sp),
            ),
          ],
        ),
      ),
    );
  }
}
