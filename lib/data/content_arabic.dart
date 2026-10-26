import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'models.dart';

/// The 28 Arabic letters with:
///  - name + diacritised TTS text (spoken by the device's Arabic voice)
///  - an example word that starts with the letter + matching picture asset
///  - positional forms (isolated / initial / medial / final) using tatweel
///
/// Editing guide: add/change a letter by editing one UnitDef below.
/// [imageAsset] must match a file in assets/images/objects/<name>.png
const List<UnitDef> kArabicLetters = [
  UnitDef(
    id: 'alef', glyph: 'أ', nameAr: 'أَلِف', nameEn: 'Alif', ttsAr: 'أَلِف',
    wordAr: 'أَسَد', wordTtsAr: 'أَسَد', wordEn: 'Lion', imageAsset: 'lion',
    forms: ['أ', 'ـأ', 'ـأ', 'ـأ'], color: AppColors.orange,
  ),
  UnitDef(
    id: 'ba', glyph: 'ب', nameAr: 'باء', nameEn: 'Ba', ttsAr: 'باء',
    wordAr: 'بَطَّة', wordTtsAr: 'بَطَّة', wordEn: 'Duck', imageAsset: 'duck',
    forms: ['ب', 'بـ', 'ـبـ', 'ـب'], color: AppColors.sun,
  ),
  UnitDef(
    id: 'ta', glyph: 'ت', nameAr: 'تاء', nameEn: 'Ta', ttsAr: 'تاء',
    wordAr: 'تُفَّاحَة', wordTtsAr: 'تُفَّاحَة', wordEn: 'Apple', imageAsset: 'apple',
    forms: ['ت', 'تـ', 'ـتـ', 'ـت'], color: AppColors.coral,
  ),
  UnitDef(
    id: 'tha', glyph: 'ث', nameAr: 'ثاء', nameEn: 'Tha', ttsAr: 'ثاء',
    wordAr: 'ثَعْلَب', wordTtsAr: 'ثَعْلَب', wordEn: 'Fox', imageAsset: 'fox',
    forms: ['ث', 'ثـ', 'ـثـ', 'ـث'], color: AppColors.mint,
  ),
  UnitDef(
    id: 'jeem', glyph: 'ج', nameAr: 'جيم', nameEn: 'Jeem', ttsAr: 'جيم',
    wordAr: 'جَمَل', wordTtsAr: 'جَمَل', wordEn: 'Camel', imageAsset: 'camel',
    forms: ['ج', 'جـ', 'ـجـ', 'ـج'], color: AppColors.brown,
  ),
  UnitDef(
    id: 'haa', glyph: 'ح', nameAr: 'حاء', nameEn: 'Hha', ttsAr: 'حاء',
    wordAr: 'حِصَان', wordTtsAr: 'حِصَان', wordEn: 'Horse', imageAsset: 'horse',
    forms: ['ح', 'حـ', 'ـحـ', 'ـح'], color: AppColors.blue,
  ),
  UnitDef(
    id: 'khaa', glyph: 'خ', nameAr: 'خاء', nameEn: 'Khaa', ttsAr: 'خاء',
    wordAr: 'خَرُوف', wordTtsAr: 'خَرُوف', wordEn: 'Sheep', imageAsset: 'sheep',
    forms: ['خ', 'خـ', 'ـخـ', 'ـخ'], color: AppColors.purple,
  ),
  UnitDef(
    id: 'dal', glyph: 'د', nameAr: 'دال', nameEn: 'Dal', ttsAr: 'دال',
    wordAr: 'دُبّ', wordTtsAr: 'دُبّ', wordEn: 'Bear', imageAsset: 'bear',
    forms: ['د', 'ـد', 'ـد', 'د'], color: AppColors.pink,
  ),
  UnitDef(
    id: 'dhal', glyph: 'ذ', nameAr: 'ذال', nameEn: 'Dhal', ttsAr: 'ذال',
    wordAr: 'ذِئْب', wordTtsAr: 'ذِئْب', wordEn: 'Wolf', imageAsset: 'wolf',
    forms: ['ذ', 'ـذ', 'ـذ', 'ذ'], color: AppColors.teal,
  ),
  UnitDef(
    id: 'raa', glyph: 'ر', nameAr: 'راء', nameEn: 'Raa', ttsAr: 'راء',
    wordAr: 'رُمَّان', wordTtsAr: 'رُمَّان', wordEn: 'Pomegranate', imageAsset: 'pomegranate',
    forms: ['ر', 'ـر', 'ـر', 'ر'], color: AppColors.red,
  ),
  UnitDef(
    id: 'zay', glyph: 'ز', nameAr: 'زاي', nameEn: 'Zay', ttsAr: 'زاي',
    wordAr: 'زَرَافَة', wordTtsAr: 'زَرَافَة', wordEn: 'Giraffe', imageAsset: 'giraffe',
    forms: ['ز', 'ـز', 'ـز', 'ز'], color: AppColors.gold,
  ),
  UnitDef(
    id: 'seen', glyph: 'س', nameAr: 'سين', nameEn: 'Seen', ttsAr: 'سين',
    wordAr: 'سَمَكَة', wordTtsAr: 'سَمَكَة', wordEn: 'Fish', imageAsset: 'fish',
    forms: ['س', 'سـ', 'ـسـ', 'ـس'], color: AppColors.skyBlue,
  ),
  UnitDef(
    id: 'sheen', glyph: 'ش', nameAr: 'شين', nameEn: 'Sheen', ttsAr: 'شين',
    wordAr: 'شَمْس', wordTtsAr: 'شَمْس', wordEn: 'Sun', imageAsset: 'sun',
    forms: ['ش', 'شـ', 'ـشـ', 'ـش'], color: AppColors.sun,
  ),
  UnitDef(
    id: 'sad', glyph: 'ص', nameAr: 'صاد', nameEn: 'Sad', ttsAr: 'صاد',
    wordAr: 'صَقْر', wordTtsAr: 'صَقْر', wordEn: 'Falcon', imageAsset: 'falcon',
    forms: ['ص', 'صـ', 'ـصـ', 'ـص'], color: AppColors.brown,
  ),
  UnitDef(
    id: 'dad', glyph: 'ض', nameAr: 'ضاد', nameEn: 'Dad', ttsAr: 'ضاد',
    wordAr: 'ضِفْدَع', wordTtsAr: 'ضِفْدَع', wordEn: 'Frog', imageAsset: 'frog',
    forms: ['ض', 'ضـ', 'ـضـ', 'ـض'], color: AppColors.green,
  ),
  UnitDef(
    id: 'taa', glyph: 'ط', nameAr: 'طاء', nameEn: 'Taa', ttsAr: 'طاء',
    wordAr: 'طَائِرَة', wordTtsAr: 'طَائِرَة', wordEn: 'Airplane', imageAsset: 'airplane',
    forms: ['ط', 'طـ', 'ـطـ', 'ـط'], color: AppColors.blue,
  ),
  UnitDef(
    id: 'dha', glyph: 'ظ', nameAr: 'ظاء', nameEn: 'Dhaa', ttsAr: 'ظاء',
    wordAr: 'ظَبْي', wordTtsAr: 'ظَبْي', wordEn: 'Oryx', imageAsset: 'oryx',
    forms: ['ظ', 'ظـ', 'ـظـ', 'ـظ'], color: AppColors.mint,
  ),
  UnitDef(
    id: 'ain', glyph: 'ع', nameAr: 'عين', nameEn: 'Ain', ttsAr: 'عين',
    wordAr: 'عُصْفُور', wordTtsAr: 'عُصْفُور', wordEn: 'Bird', imageAsset: 'bird',
    forms: ['ع', 'عـ', 'ـعـ', 'ـع'], color: AppColors.skyBlue,
  ),
  UnitDef(
    id: 'ghain', glyph: 'غ', nameAr: 'غين', nameEn: 'Ghain', ttsAr: 'غين',
    wordAr: 'غَزَال', wordTtsAr: 'غَزَال', wordEn: 'Gazelle', imageAsset: 'gazelle',
    forms: ['غ', 'غـ', 'ـغـ', 'ـغ'], color: AppColors.mint,
  ),
  UnitDef(
    id: 'fa', glyph: 'ف', nameAr: 'فاء', nameEn: 'Fa', ttsAr: 'فاء',
    wordAr: 'فِيل', wordTtsAr: 'فِيل', wordEn: 'Elephant', imageAsset: 'elephant',
    forms: ['ف', 'فـ', 'ـفـ', 'ـف'], color: AppColors.purple,
  ),
  UnitDef(
    id: 'qaf', glyph: 'ق', nameAr: 'قاف', nameEn: 'Qaf', ttsAr: 'قاف',
    wordAr: 'قَمَر', wordTtsAr: 'قَمَر', wordEn: 'Moon', imageAsset: 'moon',
    forms: ['ق', 'قـ', 'ـقـ', 'ـق'], color: AppColors.sun,
  ),
  UnitDef(
    id: 'kaf', glyph: 'ك', nameAr: 'كاف', nameEn: 'Kaf', ttsAr: 'كاف',
    wordAr: 'كِتَاب', wordTtsAr: 'كِتَاب', wordEn: 'Book', imageAsset: 'book',
    forms: ['ك', 'كـ', 'ـكـ', 'ـك'], color: AppColors.coral,
  ),
  UnitDef(
    id: 'lam', glyph: 'ل', nameAr: 'لام', nameEn: 'Lam', ttsAr: 'لام',
    wordAr: 'لَيْمُون', wordTtsAr: 'لَيْمُون', wordEn: 'Lemon', imageAsset: 'lemon',
    forms: ['ل', 'لـ', 'ـلـ', 'ـل'], color: AppColors.sun,
  ),
  UnitDef(
    id: 'meem', glyph: 'م', nameAr: 'ميم', nameEn: 'Meem', ttsAr: 'ميم',
    wordAr: 'مَوْز', wordTtsAr: 'مَوْز', wordEn: 'Banana', imageAsset: 'banana',
    forms: ['م', 'مـ', 'ـمـ', 'ـم'], color: AppColors.gold,
  ),
  UnitDef(
    id: 'noon', glyph: 'ن', nameAr: 'نون', nameEn: 'Noon', ttsAr: 'نون',
    wordAr: 'نَحْلَة', wordTtsAr: 'نَحْلَة', wordEn: 'Bee', imageAsset: 'bee',
    forms: ['ن', 'نـ', 'ـنـ', 'ـن'], color: AppColors.gold,
  ),
  UnitDef(
    id: 'ha', glyph: 'ه', nameAr: 'هاء', nameEn: 'Ha', ttsAr: 'هاء',
    wordAr: 'هَدِيَّة', wordTtsAr: 'هَدِيَّة', wordEn: 'Gift', imageAsset: 'gift',
    forms: ['ه', 'هـ', 'ـهـ', 'ـه'], color: AppColors.pink,
  ),
  UnitDef(
    id: 'waw', glyph: 'و', nameAr: 'واو', nameEn: 'Waw', ttsAr: 'واو',
    wordAr: 'وَرْدَة', wordTtsAr: 'وَرْدَة', wordEn: 'Rose', imageAsset: 'rose',
    forms: ['و', 'ـو', 'ـو', 'و'], color: AppColors.coral,
  ),
  UnitDef(
    id: 'ya', glyph: 'ي', nameAr: 'ياء', nameEn: 'Ya', ttsAr: 'ياء',
    wordAr: 'يَد', wordTtsAr: 'يَد', wordEn: 'Hand', imageAsset: 'hand',
    forms: ['ي', 'يـ', 'ـيـ', 'ـي'], color: AppColors.brown,
  ),
];
