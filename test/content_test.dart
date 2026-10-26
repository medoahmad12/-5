import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/data/content_arabic.dart';
import 'package:little_explorers/data/content_english.dart';
import 'package:little_explorers/data/content_numbers.dart';
import 'package:little_explorers/data/content_colors_shapes.dart';
import 'package:little_explorers/data/worlds.dart';

void main() {
  group('content integrity', () {
    test('28 Arabic letters, unique ids & glyphs', () {
      expect(kArabicLetters.length, 28);
      expect(kArabicLetters.map((u) => u.id).toSet().length, 28);
      expect(kArabicLetters.map((u) => u.glyph).toSet().length, 28);
      for (final u in kArabicLetters) {
        expect(u.ttsAr.isNotEmpty, true, reason: '${u.id} ttsAr');
        expect(u.wordAr?.isNotEmpty ?? false, true, reason: '${u.id} word');
        expect(u.imageAsset != null, true, reason: '${u.id} image');
        expect(u.forms.length, 4, reason: '${u.id} forms');
      }
    });

    test('26 English letters with bundled narration', () {
      expect(kEnglishLetters.length, 26);
      expect(kEnglishLetters.map((u) => u.id).toSet().length, 26);
      for (final u in kEnglishLetters) {
        expect(u.audioEn, isNotNull, reason: '${u.id} audioEn');
        expect(u.imageAsset, isNotNull, reason: '${u.id} image');
      }
    });

    test('numbers 0..10', () {
      expect(kNumbers.length, 11);
      final values = kNumbers.map((u) => int.parse(u.glyph)).toList();
      expect(values, List.generate(11, (i) => i));
    });

    test('colors & shapes are valid', () {
      expect(kColors.length, 10);
      expect(kShapes.length, 8);
      for (final s in kShapes) {
        expect(
          ['circle', 'square', 'triangle', 'star', 'heart',
           'rectangle', 'diamond', 'oval'],
          contains(s.glyph),
        );
      }
    });

    test('worlds reference valid subjects & ascending thresholds', () {
      final thresholds = kWorlds.map((w) => w.starThreshold).toList();
      expect(thresholds, thresholds.toList()..sort());
      for (final w in kWorlds) {
        if (w.subjectId != null) {
          expect(kSubjects.containsKey(w.subjectId), true,
              reason: w.id);
        }
      }
    });

    test('sticker unlock thresholds are ascending & unique-ish', () {
      final thresholds =
          kStickers.map((s) => s.unlockStars).toList();
      expect(thresholds, thresholds.toList()..sort());
      expect(kStickers.first.unlockStars, 0);
    });
  });
}
