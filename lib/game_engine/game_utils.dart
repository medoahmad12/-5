import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../data/models.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../widgets/gradient_glyph.dart';
import '../widgets/shape_glyph.dart';

/// Narrate a game instruction: bundled English audio, or the device Arabic
/// voice. Safe to call anywhere inside the widget tree.
void narrateHint(BuildContext context,
    {required String arText, required String enKey}) {
  final audio = context.read<AudioService>();
  final isAr = context.read<SettingsService>().isAr;
  if (isAr) {
    audio.narrateArabic(arText);
  } else {
    audio.narrateAsset('audio/en/ins_$enKey.ogg',
        fallbackEnText: arText);
  }
}

/// Narrate a unit's name (letter / number / color / shape).
void narrateUnitName(
    BuildContext context, SubjectDef subject, UnitDef unit) {
  final audio = context.read<AudioService>();
  final isAr = context.read<SettingsService>().isAr;
  switch (subject.id) {
    case 'ar':
      audio.narrateArabic(unit.ttsAr);
      break;
    case 'en':
      if (unit.audioEn != null) {
        audio.narrateAsset('audio/en/${unit.audioEn}.ogg',
            fallbackEnText: unit.nameEn);
      } else {
        audio.narrateEnglish(unit.nameEn);
      }
      break;
    case 'num':
      if (isAr) {
        audio.narrateArabic(unit.ttsAr);
      } else if (unit.audioEn != null) {
        audio.narrateAsset('audio/en/${unit.audioEn}.ogg',
            fallbackEnText: unit.nameEn);
      }
      break;
    default:
      if (isAr) {
        audio.narrateArabic(unit.ttsAr);
      } else {
        audio.narrateEnglish(unit.nameEn);
      }
  }
}

/// Shared visual representation of a unit across games.
Widget unitVisual(BuildContext context, UnitDef unit, double size,
    {bool withFace = true}) {
  final isShape = [
    'circle', 'square', 'triangle', 'star',
    'heart', 'rectangle', 'diamond', 'oval'
  ].contains(unit.glyph);

  if (isShape) {
    return ShapeGlyph(
        kind: unit.glyph, color: unit.color, size: size, withFace: withFace);
  }
  if (unit.glyph.isEmpty) {
    // color blob
    return Container(
      width: size * 0.9,
      height: size * 0.9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Color.lerp(unit.color, Colors.white, 0.5)!,
            unit.color,
            Color.lerp(unit.color, Colors.black, 0.1)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: unit.color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: withFace ? _BlobFace(size: size) : null,
    );
  }
  return GradientGlyph(
    glyph: unit.glyph,
    size: size * 0.55,
    colors: [
      Color.lerp(unit.color, Colors.white, 0.55)!,
      unit.color,
    ],
    extrude: false,
  );
}

class _BlobFace extends StatelessWidget {
  final double size;
  const _BlobFace({required this.size});

  @override
  Widget build(BuildContext context) {
    final eye = size * 0.055;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _eye(eye),
            SizedBox(width: size * 0.18),
            _eye(eye),
          ],
        ),
        Container(
          width: size * 0.22,
          height: size * 0.1,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3335),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(size * 0.1),
              bottomRight: Radius.circular(size * 0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _eye(double e) => Container(
        width: e,
        height: e,
        decoration: const BoxDecoration(
          color: Color(0xFF3A3335),
          shape: BoxShape.circle,
        ),
      );
}

/// Checks whether an object image asset exists for a unit (for game design
/// that adapts: e.g. memory uses pictures when available).
bool unitHasImage(UnitDef unit) => unit.imageAsset != null;
