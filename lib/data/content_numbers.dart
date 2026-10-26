import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'models.dart';

/// Numbers 0-10. Counting objects are drawn in-app (apples/balloons/stars),
/// so no picture assets are needed here.
const List<UnitDef> kNumbers = [
  UnitDef(
    id: 'num0', glyph: '0', nameAr: 'صِفر', nameEn: 'Zero', ttsAr: 'صِفر',
    audioEn: 'num_0', color: AppColors.purple,
  ),
  UnitDef(
    id: 'num1', glyph: '1', nameAr: 'واحِد', nameEn: 'One', ttsAr: 'واحِد',
    audioEn: 'num_1', color: AppColors.coral,
  ),
  UnitDef(
    id: 'num2', glyph: '2', nameAr: 'اثنان', nameEn: 'Two', ttsAr: 'اثنان',
    audioEn: 'num_2', color: AppColors.blue,
  ),
  UnitDef(
    id: 'num3', glyph: '3', nameAr: 'ثَلاثة', nameEn: 'Three', ttsAr: 'ثَلاثة',
    audioEn: 'num_3', color: AppColors.green,
  ),
  UnitDef(
    id: 'num4', glyph: '4', nameAr: 'أَربعة', nameEn: 'Four', ttsAr: 'أَربعة',
    audioEn: 'num_4', color: AppColors.orange,
  ),
  UnitDef(
    id: 'num5', glyph: '5', nameAr: 'خَمسة', nameEn: 'Five', ttsAr: 'خَمسة',
    audioEn: 'num_5', color: AppColors.sun,
  ),
  UnitDef(
    id: 'num6', glyph: '6', nameAr: 'سِتّة', nameEn: 'Six', ttsAr: 'سِتّة',
    audioEn: 'num_6', color: AppColors.teal,
  ),
  UnitDef(
    id: 'num7', glyph: '7', nameAr: 'سَبعة', nameEn: 'Seven', ttsAr: 'سَبعة',
    audioEn: 'num_7', color: AppColors.pink,
  ),
  UnitDef(
    id: 'num8', glyph: '8', nameAr: 'ثَمانية', nameEn: 'Eight', ttsAr: 'ثَمانية',
    audioEn: 'num_8', color: AppColors.brown,
  ),
  UnitDef(
    id: 'num9', glyph: '9', nameAr: 'تِسعة', nameEn: 'Nine', ttsAr: 'تِسعة',
    audioEn: 'num_9', color: AppColors.skyBlue,
  ),
  UnitDef(
    id: 'num10', glyph: '10', nameAr: 'عَشَرة', nameEn: 'Ten', ttsAr: 'عَشَرة',
    audioEn: 'num_10', color: AppColors.gold,
  ),
];
