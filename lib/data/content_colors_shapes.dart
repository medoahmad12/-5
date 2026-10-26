import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'models.dart';

/// Colors & Shapes. These units are drawn programmatically:
///  - colors: a cute bouncing color-blob character (no picture assets)
///  - shapes: glyph field carries the shape kind for the custom painter
const List<UnitDef> kColors = [
  UnitDef(
    id: 'red', glyph: '', nameAr: 'أَحْمَر', nameEn: 'Red', ttsAr: 'أَحْمَر',
    audioEn: null, color: Color(0xFFE4572E),
  ),
  UnitDef(
    id: 'blue', glyph: '', nameAr: 'أَزْرَق', nameEn: 'Blue', ttsAr: 'أَزْرَق',
    audioEn: null, color: Color(0xFF4EA8DE),
  ),
  UnitDef(
    id: 'green', glyph: '', nameAr: 'أَخْضَر', nameEn: 'Green', ttsAr: 'أَخْضَر',
    audioEn: null, color: Color(0xFF58C27D),
  ),
  UnitDef(
    id: 'yellow', glyph: '', nameAr: 'أَصْفَر', nameEn: 'Yellow', ttsAr: 'أَصْفَر',
    audioEn: null, color: Color(0xFFFFC93C),
  ),
  UnitDef(
    id: 'orange', glyph: '', nameAr: 'بُرْتُقَالِيّ', nameEn: 'Orange', ttsAr: 'بُرْتُقَالِيّ',
    audioEn: null, color: Color(0xFFFF9F5A),
  ),
  UnitDef(
    id: 'pink', glyph: '', nameAr: 'وَرْدِيّ', nameEn: 'Pink', ttsAr: 'وَرْدِيّ',
    audioEn: null, color: Color(0xFFFF8FB1),
  ),
  UnitDef(
    id: 'purple', glyph: '', nameAr: 'بَنَفْسَجِيّ', nameEn: 'Purple', ttsAr: 'بَنَفْسَجِيّ',
    audioEn: null, color: Color(0xFFA78BFA),
  ),
  UnitDef(
    id: 'brown', glyph: '', nameAr: 'بُنِّيّ', nameEn: 'Brown', ttsAr: 'بُنِّيّ',
    audioEn: null, color: Color(0xFFA47148),
  ),
  UnitDef(
    id: 'black', glyph: '', nameAr: 'أَسْوَد', nameEn: 'Black', ttsAr: 'أَسْوَد',
    audioEn: null, color: Color(0xFF4A4447),
  ),
  UnitDef(
    id: 'white', glyph: '', nameAr: 'أَبْيَض', nameEn: 'White', ttsAr: 'أَبْيَض',
    audioEn: null, color: Color(0xFFF4F1EA),
  ),
];

const List<UnitDef> kShapes = [
  UnitDef(
    id: 'circle', glyph: 'circle', nameAr: 'دائِرَة', nameEn: 'Circle', ttsAr: 'دائِرَة',
    color: AppColors.coral,
  ),
  UnitDef(
    id: 'square', glyph: 'square', nameAr: 'مُرَبَّع', nameEn: 'Square', ttsAr: 'مُرَبَّع',
    color: AppColors.blue,
  ),
  UnitDef(
    id: 'triangle', glyph: 'triangle', nameAr: 'مُثَلَّث', nameEn: 'Triangle', ttsAr: 'مُثَلَّث',
    color: AppColors.green,
  ),
  UnitDef(
    id: 'star', glyph: 'star', nameAr: 'نَجْمَة', nameEn: 'Star', ttsAr: 'نَجْمَة',
    color: AppColors.sun,
  ),
  UnitDef(
    id: 'heart', glyph: 'heart', nameAr: 'قَلْب', nameEn: 'Heart', ttsAr: 'قَلْب',
    color: AppColors.pink,
  ),
  UnitDef(
    id: 'rectangle', glyph: 'rectangle', nameAr: 'مُسْتَطيل', nameEn: 'Rectangle', ttsAr: 'مُسْتَطيل',
    color: AppColors.orange,
  ),
  UnitDef(
    id: 'diamond', glyph: 'diamond', nameAr: 'مَعِين', nameEn: 'Diamond', ttsAr: 'مَعِين',
    color: AppColors.purple,
  ),
  UnitDef(
    id: 'oval', glyph: 'oval', nameAr: 'بَيْضَة', nameEn: 'Oval', ttsAr: 'بَيْضَة',
    color: AppColors.teal,
  ),
];
