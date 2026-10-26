import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import 'models.dart';
import 'content_arabic.dart';
import 'content_english.dart';
import 'content_numbers.dart';
import 'content_colors_shapes.dart';

/// The four learning subjects. Each has its own island, guide character,
/// background and a rotation of game engines (so lessons feel different).
const SubjectDef kSubjectArabic = SubjectDef(
  id: 'ar',
  titleAr: 'جزيرة الحروف',
  titleEn: 'Letters Island',
  bgAsset: AppAssets.bgArabic,
  guide: 'lulu',
  color: AppColors.green,
  units: kArabicLetters,
  gameRotation: [GameType.listenChoose, GameType.dragMatch, GameType.bubblesV,
                 GameType.findScene, GameType.memory],
  isLetters: true,
);

const SubjectDef kSubjectEnglish = SubjectDef(
  id: 'en',
  titleAr: 'مدينة الحروف الإنجليزية',
  titleEn: 'English City',
  bgAsset: AppAssets.bgEnglish,
  guide: 'bobo',
  color: AppColors.blue,
  units: kEnglishLetters,
  gameRotation: [GameType.listenChoose, GameType.matchCase, GameType.dragMatch,
                 GameType.findScene],
  isLetters: true,
);

const SubjectDef kSubjectNumbers = SubjectDef(
  id: 'num',
  titleAr: 'حديقة الأرقام',
  titleEn: 'Numbers Garden',
  bgAsset: AppAssets.bgNumbers,
  guide: 'toto',
  color: AppColors.mint,
  units: kNumbers,
  gameRotation: [GameType.countFeed, GameType.balloons, GameType.trainOrder,
                 GameType.listenChoose],
  isNumbers: true,
);

const SubjectDef kSubjectColors = SubjectDef(
  id: 'col',
  titleAr: 'غابة الألوان والأشكال',
  titleEn: 'Colors & Shapes Forest',
  bgAsset: AppAssets.bgColors,
  guide: 'foufo',
  color: AppColors.pink,
  units: [...kColors, ...kShapes],
  gameRotation: [GameType.listenChoose, GameType.oddOne, GameType.pattern],
);

const Map<String, SubjectDef> kSubjects = {
  'ar': kSubjectArabic,
  'en': kSubjectEnglish,
  'num': kSubjectNumbers,
  'col': kSubjectColors,
};

/// The five islands of the world map. Thresholds keep the learning path
/// progressive without ever blocking a child for long (parents can unlock all).
const List<WorldDef> kWorlds = [
  WorldDef(
    id: 'w_ar',
    titleAr: 'جزيرة الحروف',
    titleEn: 'Letters Island',
    bgAsset: AppAssets.bgArabic,
    thumbChar: 'lulu',
    iconGlyph: 'أ',
    color: AppColors.green,
    starThreshold: 0,
    subjectId: 'ar',
  ),
  WorldDef(
    id: 'w_num',
    titleAr: 'حديقة الأرقام',
    titleEn: 'Numbers Garden',
    bgAsset: AppAssets.bgNumbers,
    thumbChar: 'toto',
    iconGlyph: '٣',
    color: AppColors.mint,
    starThreshold: 8,
    subjectId: 'num',
  ),
  WorldDef(
    id: 'w_en',
    titleAr: 'مدينة الحروف الإنجليزية',
    titleEn: 'English City',
    bgAsset: AppAssets.bgEnglish,
    thumbChar: 'bobo',
    iconGlyph: 'A',
    color: AppColors.blue,
    starThreshold: 16,
    subjectId: 'en',
  ),
  WorldDef(
    id: 'w_col',
    titleAr: 'غابة الألوان والأشكال',
    titleEn: 'Colors & Shapes Forest',
    bgAsset: AppAssets.bgColors,
    thumbChar: 'foufo',
    iconGlyph: '★',
    color: AppColors.pink,
    starThreshold: 24,
    subjectId: 'col',
  ),
  WorldDef(
    id: 'w_castle',
    titleAr: 'قلعة الأبطال',
    titleEn: 'Heroes Castle',
    bgAsset: AppAssets.bgCastle,
    thumbChar: 'luluCheer',
    iconGlyph: '♥',
    color: AppColors.gold,
    starThreshold: 30,
    subjectId: null,
  ),
];

/// Treasure-chest every N stars.
const int kStarsPerChest = 15;

const List<StickerDef> kStickers = [
  StickerDef(id: 'st_lulu', nameAr: 'لولو', nameEn: 'Lulu',
      imageAsset: 'chars/lulu_idle.png', color: AppColors.lulu, unlockStars: 0),
  StickerDef(id: 'st_apple', nameAr: 'تفاحة', nameEn: 'Apple',
      imageAsset: 'objects/apple.png', color: AppColors.coral, unlockStars: 4),
  StickerDef(id: 'st_toto', nameAr: 'توتو', nameEn: 'Toto',
      imageAsset: 'chars/toto_idle.png', color: AppColors.toto, unlockStars: 6),
  StickerDef(id: 'st_fish', nameAr: 'سمكة', nameEn: 'Fish',
      imageAsset: 'objects/fish.png', color: AppColors.skyBlue, unlockStars: 10),
  StickerDef(id: 'st_bobo', nameAr: 'بوبو', nameEn: 'Bobo',
      imageAsset: 'chars/bobo_idle.png', color: AppColors.bobo, unlockStars: 14),
  StickerDef(id: 'st_bee', nameAr: 'نحلة', nameEn: 'Bee',
      imageAsset: 'objects/bee.png', color: AppColors.gold, unlockStars: 18),
  StickerDef(id: 'st_foufo', nameAr: 'فوفو', nameEn: 'Foufou',
      imageAsset: 'chars/foufo_idle.png', color: AppColors.foufo, unlockStars: 22),
  StickerDef(id: 'st_kite', nameAr: 'طائرة ورقية', nameEn: 'Kite',
      imageAsset: 'objects/kite.png', color: AppColors.teal, unlockStars: 26),
  StickerDef(id: 'st_crown', nameAr: 'تاج', nameEn: 'Crown',
      imageAsset: 'objects/crown.png', color: AppColors.gold, unlockStars: 32),
  StickerDef(id: 'st_gift', nameAr: 'هدية', nameEn: 'Gift',
      imageAsset: 'objects/gift.png', color: AppColors.pink, unlockStars: 38),
  StickerDef(id: 'st_moon', nameAr: 'قمر', nameEn: 'Moon',
      imageAsset: 'objects/moon.png', color: AppColors.sun, unlockStars: 44),
  StickerDef(id: 'st_zebra', nameAr: 'حمار وحشي', nameEn: 'Zebra',
      imageAsset: 'objects/zebra.png', color: AppColors.ink, unlockStars: 50),
];
