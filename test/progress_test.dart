import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/services/progress_service.dart';
import 'package:little_explorers/data/worlds.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressService', () {
    test('stars accumulate and lessons count', () {
      final p = ProgressService();
      p.completeUnit('ar', 'alef', 3, 0);
      p.completeUnit('ar', 'ba', 2, 1);
      expect(p.totalStars, 5);
      expect(p.lessonsDone, 2);
      expect(p.unitStars('ar', 'alef'), 3);
    });

    test('unit unlocking follows the previous unit', () {
      final p = ProgressService();
      final subject = kSubjects['ar']!;
      expect(p.isUnitUnlocked(subject, 0), true);
      expect(p.isUnitUnlocked(subject, 1), false);
      p.completeUnit('ar', subject.units[0].id, 2, 0);
      expect(p.isUnitUnlocked(subject, 1), true);
      expect(p.isUnitUnlocked(subject, 2), false);
    });

    test('best stars are kept (no downgrade)', () {
      final p = ProgressService();
      p.completeUnit('num', 'num3', 3, 0);
      p.completeUnit('num', 'num3', 1, 4);
      expect(p.unitStars('num', 'num3'), 3);
      expect(p.progressOf('num', 'num3').plays, 2);
    });

    test('stickers unlock by star thresholds, chests every 15', () {
      final p = ProgressService();
      // 16 stars -> apple (4), toto (6), fish (10), bobo (14) + 1 chest
      var stars = 0;
      for (var i = 0; i < 8; i++) {
        p.completeUnit('num', 'num$i', 2, 0);
        stars += 2;
      }
      expect(stars, 16);
      expect(p.stickers.contains('st_apple'), true);
      expect(p.stickers.contains('st_toto'), true);
      expect(p.stickers.contains('st_fish'), true);
      expect(p.stickers.contains('st_bobo'), true);
      expect(p.stickers.contains('st_foufo'), false); // needs 22
      expect(p.chestsOpened, 1);
    });

    test('review queue add/clear and subject filtering', () {
      final p = ProgressService();
      p.addReview('ar.sheen');
      p.addReview('ar.sad');
      p.addReview('num.num4');
      expect(p.hasReviewFor('ar'), true);
      expect(p.reviewUnitsFor(kSubjects['ar']!).length, 2);
      p.clearReview('ar.sheen');
      expect(p.reviewUnitsFor(kSubjects['ar']!).length, 1);
      expect(p.hasReviewFor('en'), false);
    });

    test('skill levels compute from correct/wrong', () {
      final p = ProgressService();
      for (var i = 0; i < 8; i++) {
        p.recordSkill('memory', true);
      }
      for (var i = 0; i < 2; i++) {
        p.recordSkill('memory', false);
      }
      expect(p.skillLevel('memory'), 4); // 8/10 -> 4 of 5
      expect(p.skillLevel('counting'), 0);
    });

    test('reset clears everything', () {
      final p = ProgressService();
      p.completeUnit('ar', 'alef', 3, 0);
      p.resetAll();
      expect(p.totalStars, 0);
      expect(p.stickers, isEmpty);
      expect(p.chestsOpened, 0);
    });
  });
}
