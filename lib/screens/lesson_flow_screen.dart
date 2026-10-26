import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../core/utils/size_config.dart';
import '../data/models.dart';
import '../data/worlds.dart';
import '../game_engine/game_host.dart';
import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../widgets/big_button.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/character_view.dart';
import '../widgets/gradient_glyph.dart';
import '../widgets/picture_card.dart';
import '../widgets/shape_glyph.dart';
import '../widgets/star_row.dart';
import '../widgets/world_scaffold.dart';

/// Lesson flow:
///   intro (meet the glyph) -> practice (word / counting) -> mini game
///   -> celebration with stars, stickers and maybe a treasure chest.
///
/// In review mode (struggled concepts) it jumps straight to a short game.
class LessonFlowScreen extends StatefulWidget {
  final SubjectDef subject;
  final int unitIndex;
  final List<UnitDef>? reviewUnits;

  const LessonFlowScreen({
    super.key,
    required this.subject,
    required this.unitIndex,
  }) : reviewUnits = null;

  const LessonFlowScreen.review({super.key, required this.subject})
      : unitIndex = -1,
        reviewUnits = null;

  @override
  State<LessonFlowScreen> createState() => _LessonFlowScreenState();
}

enum _Stage { intro, practice, game, done }

class _LessonFlowScreenState extends State<LessonFlowScreen> {
  late _Stage _stage;
  late UnitDef _unit;
  GameType _gameType = GameType.listenChoose;
  int _counted = 0; // counting practice state

  @override
  void initState() {
    super.initState();
    final progress = context.read<ProgressService>();
    if (widget.unitIndex >= 0) {
      _unit = widget.subject.units[widget.unitIndex];
      final plays = progress.progressOf(widget.subject.id, _unit.id).plays;
      final rotation = widget.subject.gameRotation;
      _gameType = rotation[plays % rotation.length];
      _stage = _Stage.intro;
    } else {
      // Review session: pick up to 4 struggled units.
      _stage = _Stage.game;
      _gameType = GameType.listenChoose;
      _unit = widget.subject.units.first;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakIntro());
  }

  AudioService get _audio => context.read<AudioService>();

  // ---------------- narration helpers ----------------

  void _speakIntro() {
    final unit = _unit;
    switch (widget.subject.id) {
      case 'ar':
        _audio.narrateArabic(
            '${unit.ttsAr}، ${unit.wordTtsAr ?? ''}');
        break;
      case 'en':
        if (unit.audioEn != null) {
          _audio.narrateAsset('audio/en/${unit.audioEn}.ogg',
              fallbackEnText: unit.nameEn);
        } else {
          _audio.narrateEnglish(unit.nameEn);
        }
        break;
      case 'num':
        if (context.read<SettingsService>().isAr) {
          _audio.narrateArabic(unit.ttsAr);
        } else if (unit.audioEn != null) {
          _audio.narrateAsset('audio/en/${unit.audioEn}.ogg',
              fallbackEnText: unit.nameEn);
        }
        break;
      default:
        if (context.read<SettingsService>().isAr) {
          _audio.narrateArabic(unit.ttsAr);
        } else {
          _audio.narrateEnglish(unit.nameEn);
        }
    }
  }

  void _speakWord() {
    final u = _unit;
    if (widget.subject.id == 'ar') {
      _audio.narrateArabic(u.wordTtsAr ?? u.wordAr ?? '');
    } else if (widget.subject.id == 'en' && u.imageAsset != null) {
      _audio.narrateAsset('audio/en/word_${u.imageAsset}.ogg',
          fallbackEnText: u.wordEn);
    } else {
      _audio.narrateEnglish(u.wordEn ?? u.nameEn);
    }
  }

  void _advance() {
    setState(() {
      switch (_stage) {
        case _Stage.intro:
          _stage = widget.subject.isLetters || widget.subject.isNumbers
              ? _Stage.practice
              : _Stage.game;
          break;
        case _Stage.practice:
          _stage = _Stage.game;
          break;
        default:
          break;
      }
    });
    if (_stage == _Stage.practice) {
      _counted = 0;
      if (widget.subject.isLetters) _speakWord();
    } else if (_stage == _Stage.game) {
      _audio.sfx('whoosh');
    }
  }

  void _onGameDone(GameResult result) {
    final progress = context.read<ProgressService>();
    final settings = context.read<SettingsService>();
    Haptics.success(settings.hapticsOn);
    _audio.success();

    if (widget.unitIndex >= 0) {
      // Skill bookkeeping for the parent dashboard.
      progress.recordSkill(result.skill, result.mistakes <= 2);
      if (result.mistakes >= 2) {
        progress.addReview('${widget.subject.id}.${_unit.id}');
      }
      final reward =
          progress.completeUnit(widget.subject.id, _unit.id, result.stars, result.mistakes);
      if (reward.newChests > 0) _audio.treasure();
      if (result.stars > 0) _audio.star();
      setState(() {
        _stage = _Stage.done;
        _reward = reward;
        _stars = result.stars;
      });
    } else {
      // Review session finished — clear reviewed concepts.
      for (final u in _reviewPool) {
        progress.clearReview('${widget.subject.id}.${u.id}');
      }
      Navigator.of(context).maybePop();
    }
  }

  RewardInfo _reward = const RewardInfo();
  int _stars = 0;

  List<UnitDef> get _reviewPool =>
      (widget.reviewUnits ??
          context.read<ProgressService>().reviewUnitsFor(widget.subject))
          .take(4)
          .toList();

  // ---------------- build ----------------

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final s = widget.subject;

    if (_stage == _Stage.done) {
      return WorldScaffold(
        bgAsset: s.bgAsset,
        showSparkles: false,
        child: CelebrationOverlay(
          charId: s.guide,
          title: context.tr('lessonDone'),
          stars: _stars,
          unlockedStickers:
              _reward.newStickers.map((e) => e.imageAsset ?? '').toList(),
          newChests: _reward.newChests,
          onContinue: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    return WorldScaffold(
      bgAsset: s.bgAsset,
      child: SafeArea(
        child: Column(
          children: [
            _flowHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutBack,
                child: _stageBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flowHeader() {
    final names = [
      context.tr('thisIs'),
      widget.subject.isNumbers
          ? context.tr('tapNumHint')
          : context.tr('listenWord'),
      context.tr(_gameKeyFor(_gameType)),
    ];
    final idx = switch (_stage) {
      _Stage.intro => 0,
      _Stage.practice => 1,
      _ => 2,
    };
    return Padding(
      padding: EdgeInsets.fromLTRB(16.sp, 8.sp, 16.sp, 0),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                names[idx],
                key: ValueKey(idx),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          // stage dots
          Row(
            children: List.generate(3, (i) {
              final active = switch (_stage) {
                _Stage.intro => i == 0,
                _Stage.practice => i == 1,
                _ => i == 2,
              };
              return Container(
                width: 9.sp,
                height: 9.sp,
                margin: EdgeInsets.symmetric(horizontal: 2.sp),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? widget.subject.color
                      : AppColors.lockedGray.withOpacity(0.4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _stageBody() {
    switch (_stage) {
      case _Stage.intro:
        return _introStage();
      case _Stage.practice:
        return widget.subject.isNumbers ? _countingStage() : _wordStage();
      case _Stage.game:
        return _gameStage();
      case _Stage.done:
        return const SizedBox.shrink();
    }
  }

  // ---------------- stage 1: intro ----------------

  Widget _introStage() {
    final u = _unit;
    final s = widget.subject;

    Widget glyphWidget;
    if (s.isNumbers) {
      glyphWidget = GradientGlyph(
        glyph: u.glyph,
        size: 120.sp.clamp(96.0, 150.0),
        colors: [Color(0xFFFFE29A), u.color],
        onTap: _speakIntro,
      );
    } else if (s.id == 'en') {
      glyphWidget = Column(
        children: [
          GradientGlyph(
            glyph: u.glyph,
            size: 96.sp.clamp(76.0, 120.0),
            colors: [Color.lerp(u.color, Colors.white, 0.5)!, u.color],
            onTap: _speakIntro,
          ),
          GradientGlyph(
            glyph: u.glyph.toLowerCase(),
            size: 66.sp.clamp(52.0, 84.0),
            colors: [Color.lerp(u.color, Colors.white, 0.6)!, u.color],
            onTap: _speakIntro,
            extrude: false,
          ),
        ],
      );
    } else if (u.glyph.isEmpty) {
      glyphWidget = GestureDetector(
        onTap: _speakIntro,
        child: ShapeGlyph(
          kind: 'circle',
          color: u.color,
          size: 130.sp.clamp(100.0, 160.0),
        ),
      );
    } else if (_isShapeGlyph(u.glyph)) {
      glyphWidget = GestureDetector(
        onTap: _speakIntro,
        child: ShapeGlyph(
          kind: u.glyph,
          color: u.color,
          size: 130.sp.clamp(100.0, 160.0),
        ),
      );
    } else {
      glyphWidget = GradientGlyph(
        glyph: u.glyph,
        size: 120.sp.clamp(96.0, 150.0),
        colors: [Color.lerp(u.color, Colors.white, 0.5)!, u.color],
        onTap: _speakIntro,
      );
    }

    final name = context.isAr
        ? (s.id == 'ar' ? '${u.nameAr} — ${u.wordAr ?? ''}' : u.nameAr)
        : u.nameEn;

    return Center(
      key: const ValueKey('intro'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 6.sp),
          glyphWidget,
          SizedBox(height: 6.sp),
          Text(
            context.tr('tapToHear'),
            style: TextStyle(
                fontSize: 13.sp, color: AppColors.inkSoft),
          ),
          SizedBox(height: 12.sp),
          CharacterView(
            charId: s.guide,
            pose: 'point',
            size: 86.sp.clamp(64.0, 110.0),
            bubble: context.tr('tapGlyphHint'),
          ),
          SizedBox(height: 10.sp),
          BigButton(
            label: context.tr('continueWord'),
            icon: Icons.arrow_forward_rounded,
            color: s.color,
            onTap: _advance,
          ),
        ],
      ),
    );
  }

  bool _isShapeGlyph(String g) => [
        'circle', 'square', 'triangle', 'star',
        'heart', 'rectangle', 'diamond', 'oval'
      ].contains(g);

  // ---------------- stage 2a: word (letters) ----------------

  Widget _wordStage() {
    final u = _unit;
    final isArabicSubject = widget.subject.id == 'ar';
    final word = isArabicSubject
        ? (u.wordAr ?? '')
        : (u.wordEn ?? '');
    final wordTts = isArabicSubject ? (u.wordTtsAr ?? '') : (u.wordEn ?? '');

    return Center(
      key: const ValueKey('word'),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (u.imageAsset != null)
              PictureCard(
                objectName: u.imageAsset!,
                size: 190.sp.clamp(150.0, 230.0),
              ),
            SizedBox(height: 12.sp),
            Text(
              word,
              style: TextStyle(
                fontSize: 34.sp.clamp(26.0, 44.0),
                fontWeight: FontWeight.w800,
                color: u.color,
              ),
            ),
            if (isArabicSubject && u.forms.isNotEmpty) ...[
              SizedBox(height: 12.sp),
              Text(
                context.tr('forms'),
                style: TextStyle(
                    fontSize: 13.sp, color: AppColors.inkSoft),
              ),
              SizedBox(height: 6.sp),
              // Letter positional forms (beginning / middle / end).
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.sp, vertical: 8.sp),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = u.forms.length - 1; i >= 0; i--)
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8.sp),
                        child: Text(
                          u.forms[i],
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BigButton(
                  label: context.tr('listenWord'),
                  icon: Icons.volume_up_rounded,
                  color: AppColors.mint,
                  onTap: _speakWord,
                ),
                SizedBox(width: 12.sp),
                BigButton(
                  label: context.tr('continueWord'),
                  icon: Icons.arrow_forward_rounded,
                  color: widget.subject.color,
                  onTap: _advance,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- stage 2b: counting (numbers) ----------------

  Widget _countingStage() {
    final n = int.tryParse(_unit.glyph) ?? 0;
    if (n == 0) {
      // Zero: show an empty plate + fun explanation, then continue.
      return Center(
        key: const ValueKey('count0'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GradientGlyph(
                glyph: '0',
                size: 110.sp,
                colors: [Color(0xFFFFE29A), _unit.color]),
            SizedBox(height: 14.sp),
            Text(
              context.isAr ? 'هذا الصِفر... لا شيء إطلاقًا!' : 'Zero means nothing at all!',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16.sp),
            BigButton(
              label: context.tr('continueWord'),
              icon: Icons.arrow_forward_rounded,
              color: _unit.color,
              onTap: _advance,
            ),
          ],
        ),
      );
    }

    final countedNow = _counted;
    return Center(
      key: const ValueKey('count'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GradientGlyph(
            glyph: _unit.glyph,
            size: 84.sp.clamp(66.0, 104.0),
            colors: [Color(0xFFFFE29A), _unit.color],
            extrude: false,
          ),
          SizedBox(height: 10.sp),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp),
            child: Wrap(
              spacing: 10.sp,
              runSpacing: 10.sp,
              alignment: WrapAlignment.center,
              children: List.generate(n, (i) {
                final active = i < countedNow;
                return GestureDetector(
                  onTap: () => _tapCountItem(i),
                  child: AnimatedScale(
                    scale: active ? 1.0 : 0.94,
                    duration: const Duration(milliseconds: 180),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topRight,
                      children: [
                        Image.asset(
                          AppAssets.object('apple'),
                          width: 54.sp.clamp(42.0, 66.0),
                          height: 54.sp.clamp(42.0, 66.0),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => ShapeGlyph(
                              kind: 'circle',
                              color: AppColors.coral,
                              size: 50,
                              withFace: false),
                        ),
                        if (active)
                          Container(
                            padding: EdgeInsets.all(3.sp),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check_rounded,
                                color: Colors.white,
                                size: 13.sp.clamp(10.0, 16.0)),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 12.sp),
          Text(
            '${Helpers.digits(countedNow, arabic: context.isAr)} / ${Helpers.digits(n, arabic: context.isAr)}',
            style: TextStyle(
                fontSize: 22.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12.sp),
          BigButton(
            label: countedNow >= n
                ? context.tr('continueWord')
                : context.tr('continueWord'),
            icon: Icons.arrow_forward_rounded,
            color: _unit.color,
            onTap: countedNow >= n ? _advance : null,
          ),
        ],
      ),
    );
  }

  void _tapCountItem(int index) {
    if (index != _counted) return; // count in order, one by one
    final settings = context.read<SettingsService>();
    Haptics.pop(settings.hapticsOn);
    _audio.pop();
    setState(() => _counted += 1);
    final isAr = settings.isAr;
    if (isAr) {
      final names = [
        'صِفر', 'واحِد', 'اثنان', 'ثَلاثة', 'أَربعة', 'خَمسة',
        'سِتّة', 'سَبعة', 'ثَمانية', 'تِسعة', 'عَشَرة'
      ];
      _audio.narrateArabic(names[_counted.clamp(0, 10)]);
    } else {
      _audio.narrateAsset('audio/en/num_$_counted.ogg',
          fallbackEnText: '$_counted');
    }
  }

  // ---------------- stage 3: game ----------------

  Widget _gameStage() {
    final review = widget.unitIndex < 0;
    return GameHost(
      key: const ValueKey('game'),
      subject: widget.subject,
      unit: _unit,
      type: _gameType,
      reviewPool: review ? _reviewPool : null,
      onDone: _onGameDone,
    );
  }
}

/// Maps game types to their string keys.
String _gameKeyFor(GameType t) => switch (t) {
      GameType.listenChoose => 'gameListen',
      GameType.dragMatch => 'gameDrag',
      GameType.matchCase => 'gameDrag',
      GameType.memory => 'gameMemory',
      GameType.countFeed => 'gameFeed',
      GameType.balloons => 'gameBalloons',
      GameType.bubblesV => 'gameBubbles',
      GameType.collectStars => 'gameCollect',
      GameType.trainOrder => 'gameTrain',
      GameType.oddOne => 'gameOdd',
      GameType.findScene => 'gameFind',
      GameType.pattern => 'gamePattern',
    };
