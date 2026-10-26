import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'models.dart';

/// English letters A-Z for beginners:
///  - bundled studio-quality narration (letter name + example word)
///  - upper/lower pair is built by the lesson UI (glyph + glyph.toLowerCase())
///  - words reuse the same object pictures as the Arabic island when possible
const List<UnitDef> kEnglishLetters = [
  UnitDef(
    id: 'a', glyph: 'A', nameAr: 'إيه', nameEn: 'A', ttsAr: 'إيه',
    audioEn: 'letter_A', wordAr: 'تُفَّاحَة', wordEn: 'Apple',
    wordTtsAr: 'آبل', imageAsset: 'apple', color: AppColors.coral,
  ),
  UnitDef(
    id: 'b', glyph: 'B', nameAr: 'بي', nameEn: 'B', ttsAr: 'بي',
    audioEn: 'letter_B', wordAr: 'كُرَة', wordEn: 'Ball',
    wordTtsAr: 'بول', imageAsset: 'ball', color: AppColors.blue,
  ),
  UnitDef(
    id: 'c', glyph: 'C', nameAr: 'سي', nameEn: 'C', ttsAr: 'سي',
    audioEn: 'letter_C', wordAr: 'قِطّ', wordEn: 'Cat',
    wordTtsAr: 'كات', imageAsset: 'cat', color: AppColors.gold,
  ),
  UnitDef(
    id: 'd', glyph: 'D', nameAr: 'دي', nameEn: 'D', ttsAr: 'دي',
    audioEn: 'letter_D', wordAr: 'بَطَّة', wordEn: 'Duck',
    wordTtsAr: 'دك', imageAsset: 'duck', color: AppColors.sun,
  ),
  UnitDef(
    id: 'e', glyph: 'E', nameAr: 'إي', nameEn: 'E', ttsAr: 'إي',
    audioEn: 'letter_E', wordAr: 'فِيل', wordEn: 'Elephant',
    wordTtsAr: 'إيلفنت', imageAsset: 'elephant', color: AppColors.purple,
  ),
  UnitDef(
    id: 'f', glyph: 'F', nameAr: 'إف', nameEn: 'F', ttsAr: 'إف',
    audioEn: 'letter_F', wordAr: 'سَمَكَة', wordEn: 'Fish',
    wordTtsAr: 'فيش', imageAsset: 'fish', color: AppColors.skyBlue,
  ),
  UnitDef(
    id: 'g', glyph: 'G', nameAr: 'جي', nameEn: 'G', ttsAr: 'جي',
    audioEn: 'letter_G', wordAr: 'زَرَافَة', wordEn: 'Giraffe',
    wordTtsAr: 'جيراف', imageAsset: 'giraffe', color: AppColors.mint,
  ),
  UnitDef(
    id: 'h', glyph: 'H', nameAr: 'إتش', nameEn: 'H', ttsAr: 'إتش',
    audioEn: 'letter_H', wordAr: 'حِصَان', wordEn: 'Horse',
    wordTtsAr: 'هورس', imageAsset: 'horse', color: AppColors.brown,
  ),
  UnitDef(
    id: 'i', glyph: 'I', nameAr: 'آي', nameEn: 'I', ttsAr: 'آي',
    audioEn: 'letter_I', wordAr: 'آيس كريم', wordEn: 'Ice cream',
    wordTtsAr: 'آيس كريم', imageAsset: 'ice_cream', color: AppColors.pink,
  ),
  UnitDef(
    id: 'j', glyph: 'J', nameAr: 'جيه', nameEn: 'J', ttsAr: 'جيه',
    audioEn: 'letter_J', wordAr: 'عَصِير', wordEn: 'Juice',
    wordTtsAr: 'جوس', imageAsset: 'juice', color: AppColors.orange,
  ),
  UnitDef(
    id: 'k', glyph: 'K', nameAr: 'كيه', nameEn: 'K', ttsAr: 'كيه',
    audioEn: 'letter_K', wordAr: 'طَائِرَة وَرَقِيَّة', wordEn: 'Kite',
    wordTtsAr: 'كايت', imageAsset: 'kite', color: AppColors.teal,
  ),
  UnitDef(
    id: 'l', glyph: 'L', nameAr: 'إل', nameEn: 'L', ttsAr: 'إل',
    audioEn: 'letter_L', wordAr: 'أَسَد', wordEn: 'Lion',
    wordTtsAr: 'لاين', imageAsset: 'lion', color: AppColors.lulu,
  ),
  UnitDef(
    id: 'm', glyph: 'M', nameAr: 'إم', nameEn: 'M', ttsAr: 'إم',
    audioEn: 'letter_M', wordAr: 'قَمَر', wordEn: 'Moon',
    wordTtsAr: 'مون', imageAsset: 'moon', color: AppColors.gold,
  ),
  UnitDef(
    id: 'n', glyph: 'N', nameAr: 'إن', nameEn: 'N', ttsAr: 'إن',
    audioEn: 'letter_N', wordAr: 'عِشّ', wordEn: 'Nest',
    wordTtsAr: 'نيست', imageAsset: 'nest', color: AppColors.brown,
  ),
  UnitDef(
    id: 'o', glyph: 'O', nameAr: 'أو', nameEn: 'O', ttsAr: 'أو',
    audioEn: 'letter_O', wordAr: 'بُرْتُقَال', wordEn: 'Orange',
    wordTtsAr: 'أورنج', imageAsset: 'orange', color: AppColors.orange,
  ),
  UnitDef(
    id: 'p', glyph: 'P', nameAr: 'بي', nameEn: 'P', ttsAr: 'بي',
    audioEn: 'letter_P', wordAr: 'بِنغوين', wordEn: 'Penguin',
    wordTtsAr: 'بنغوين', imageAsset: 'penguin', color: AppColors.skyBlue,
  ),
  UnitDef(
    id: 'q', glyph: 'Q', nameAr: 'كيو', nameEn: 'Q', ttsAr: 'كيو',
    audioEn: 'letter_Q', wordAr: 'تَاج المَلِكَة', wordEn: "Queen's crown",
    wordTtsAr: 'كوين', imageAsset: 'crown', color: AppColors.gold,
  ),
  UnitDef(
    id: 'r', glyph: 'R', nameAr: 'آر', nameEn: 'R', ttsAr: 'آر',
    audioEn: 'letter_R', wordAr: 'وَرْدَة', wordEn: 'Rose',
    wordTtsAr: 'روز', imageAsset: 'rose', color: AppColors.coral,
  ),
  UnitDef(
    id: 's', glyph: 'S', nameAr: 'إس', nameEn: 'S', ttsAr: 'إس',
    audioEn: 'letter_S', wordAr: 'شَمْس', wordEn: 'Sun',
    wordTtsAr: 'صن', imageAsset: 'sun', color: AppColors.sun,
  ),
  UnitDef(
    id: 't', glyph: 'T', nameAr: 'تي', nameEn: 'T', ttsAr: 'تي',
    audioEn: 'letter_T', wordAr: 'شَجَرَة', wordEn: 'Tree',
    wordTtsAr: 'تري', imageAsset: 'tree', color: AppColors.green,
  ),
  UnitDef(
    id: 'u', glyph: 'U', nameAr: 'يو', nameEn: 'U', ttsAr: 'يو',
    audioEn: 'letter_U', wordAr: 'مِظَلَّة', wordEn: 'Umbrella',
    wordTtsAr: 'أمبريلا', imageAsset: 'umbrella', color: AppColors.blue,
  ),
  UnitDef(
    id: 'v', glyph: 'V', nameAr: 'في', nameEn: 'V', ttsAr: 'في',
    audioEn: 'letter_V', wordAr: 'شَاحِنَة صَغِيرَة', wordEn: 'Van',
    wordTtsAr: 'فان', imageAsset: 'van', color: AppColors.teal,
  ),
  UnitDef(
    id: 'w', glyph: 'W', nameAr: 'دبليو', nameEn: 'W', ttsAr: 'دبليو',
    audioEn: 'letter_W', wordAr: 'ذِئْب', wordEn: 'Wolf',
    wordTtsAr: 'وولف', imageAsset: 'wolf', color: AppColors.inkSoft,
  ),
  UnitDef(
    id: 'x', glyph: 'X', nameAr: 'إكس', nameEn: 'X', ttsAr: 'إكس',
    audioEn: 'letter_X', wordAr: 'سَلَّة موسيقية', wordEn: 'Xylophone',
    wordTtsAr: 'زايلفون', imageAsset: 'xylophone', color: AppColors.purple,
  ),
  UnitDef(
    id: 'y', glyph: 'Y', nameAr: 'واي', nameEn: 'Y', ttsAr: 'واي',
    audioEn: 'letter_Y', wordAr: 'يويو', wordEn: 'Yo-yo',
    wordTtsAr: 'يو يو', imageAsset: 'yoyo', color: AppColors.coral,
  ),
  UnitDef(
    id: 'z', glyph: 'Z', nameAr: 'زيد', nameEn: 'Z', ttsAr: 'زيد',
    audioEn: 'letter_Z', wordAr: 'حِمار وَحْشِيّ', wordEn: 'Zebra',
    wordTtsAr: 'زيبرا', imageAsset: 'zebra', color: AppColors.ink,
  ),
];
