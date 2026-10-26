import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models.dart';
import '../data/worlds.dart';

/// Progress of one learning unit (a letter, a number, a color...).
class UnitProgress {
  int stars;
  int mistakes;
  int plays;

  UnitProgress({this.stars = 0, this.mistakes = 0, this.plays = 0});

  Map<String, dynamic> toJson() =>
      {'s': stars, 'm': mistakes, 'p': plays};

  factory UnitProgress.fromJson(Map<String, dynamic> j) => UnitProgress(
        stars: (j['s'] as num?)?.toInt() ?? 0,
        mistakes: (j['m'] as num?)?.toInt() ?? 0,
        plays: (j['p'] as num?)?.toInt() ?? 0,
      );
}

/// What the child earns when finishing a lesson.
class RewardInfo {
  final List<StickerDef> newStickers;
  final int newChests;
  const RewardInfo({this.newStickers = const [], this.newChests = 0});
  bool get isEmpty => newStickers.isEmpty && newChests == 0;
}

/// All child progress, saved locally as JSON (survives restarts & reboots).
class ProgressService extends ChangeNotifier {
  String childName = '';
  String avatar = 'lulu'; // favorite character id

  /// key: '<subjectId>.<unitId>'
  Map<String, UnitProgress> units = {};

  /// skill -> [correctCount, wrongCount]
  Map<String, List<int>> skills = {};

  /// Concept ids ('<subject>.<unit>') that need a friendly review.
  List<String> reviewQueue = [];

  /// Owned sticker ids.
  List<String> stickers = [];

  int chestsOpened = 0;

  static const String _key = 'little_explorers_progress_v1';

  // ---------------- aggregates ----------------

  int get totalStars =>
      units.values.fold(0, (sum, u) => sum + u.stars);

  int get lessonsDone =>
      units.values.where((u) => u.stars > 0).length;

  UnitProgress progressOf(String subjectId, String unitId) {
    final k = '$subjectId.$unitId';
    return units.putIfAbsent(k, () => UnitProgress());
  }

  int unitStars(String subjectId, String unitId) =>
      progressOf(subjectId, unitId).stars;

  /// A unit unlocks when the previous one has at least one star.
  bool isUnitUnlocked(SubjectDef subject, int index) {
    if (index <= 0) return true;
    return unitStars(subject.id, subject.units[index - 1].id) > 0;
  }

  /// Index of the first not-yet-completed unit (the "next" node).
  int firstIncompleteIndex(SubjectDef subject) {
    for (var i = 0; i < subject.units.length; i++) {
      if (unitStars(subject.id, subject.units[i].id) == 0) return i;
    }
    return subject.units.length - 1;
  }

  bool worldUnlocked(WorldDef world, {required bool unlockAll}) =>
      unlockAll || totalStars >= world.starThreshold;

  int subjectCompletedCount(SubjectDef subject) => subject.units
      .where((u) => unitStars(subject.id, u.id) > 0)
      .length;

  // ---------------- updates ----------------

  RewardInfo completeUnit(
      String subjectId, String unitId, int stars, int mistakes) {
    final p = progressOf(subjectId, unitId);
    p.stars = max(p.stars, stars);
    p.plays += 1;
    p.mistakes += mistakes;
    clearReview('$subjectId.$unitId');
    final reward = _grantRewards();
    save();
    notifyListeners();
    return reward;
  }

  RewardInfo _grantRewards() {
    final total = totalStars;

    // New stickers by star thresholds.
    final gained = <StickerDef>[];
    for (final st in kStickers) {
      if (stickers.contains(st.id)) continue;
      if (total >= st.unlockStars) {
        stickers.add(st.id);
        gained.add(st);
      }
    }

    // Treasure chests every kStarsPerChest stars.
    final shouldOpen = total ~/ kStarsPerChest;
    var newChests = shouldOpen - chestsOpened;
    if (newChests < 0) newChests = 0;
    chestsOpened = max(chestsOpened, shouldOpen);

    // A chest grants one random unowned sticker (if any are left).
    if (newChests > 0) {
      final locked = kStickers.where((s) => !stickers.contains(s.id)).toList();
      if (locked.isNotEmpty) {
        final drop = locked[Random().nextInt(locked.length)];
        stickers.add(drop.id);
        gained.add(drop);
      }
    }
    return RewardInfo(newStickers: gained, newChests: newChests);
  }

  void recordSkill(String skill, bool correct) {
    final pair = skills.putIfAbsent(skill, () => [0, 0]);
    if (correct) {
      pair[0] += 1;
    } else {
      pair[1] += 1;
    }
    save();
    notifyListeners();
  }

  void addReview(String conceptKey) {
    if (!reviewQueue.contains(conceptKey)) {
      reviewQueue.add(conceptKey);
      save();
      notifyListeners();
    }
  }

  void clearReview(String conceptKey) {
    if (reviewQueue.remove(conceptKey)) {
      save();
      notifyListeners();
    }
  }

  /// Mastery level 0..5 derived from the correct/attempt ratio.
  int skillLevel(String skill) {
    final pair = skills[skill];
    if (pair == null) return 0;
    final total = pair[0] + pair[1];
    if (total == 0) return 0;
    return ((pair[0] / total) * 5).round().clamp(0, 5);
  }

  bool hasReviewFor(String subjectId) =>
      reviewQueue.any((k) => k.startsWith('$subjectId.'));

  List<UnitDef> reviewUnitsFor(SubjectDef subject) {
    final keys = reviewQueue
        .where((k) => k.startsWith('${subject.id}.'))
        .toSet();
    return subject.units
        .where((u) => keys.contains('${subject.id}.${u.id}'))
        .toList();
  }

  void setProfile({String? name, String? avatarId}) {
    if (name != null) childName = name;
    if (avatarId != null) avatar = avatarId;
    save();
    notifyListeners();
  }

  void resetAll() {
    childName = '';
    avatar = 'lulu';
    units = {};
    skills = {};
    reviewQueue = [];
    stickers = [];
    chestsOpened = 0;
    save();
    notifyListeners();
  }

  // ---------------- persistence ----------------

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      childName = (map['name'] as String?) ?? '';
      avatar = (map['avatar'] as String?) ?? 'lulu';
      chestsOpened = (map['chests'] as num?)?.toInt() ?? 0;
      stickers = ((map['stickers'] as List?) ?? [])
          .map((e) => e.toString())
          .toList();
      reviewQueue = ((map['review'] as List?) ?? [])
          .map((e) => e.toString())
          .toList();
      units = {};
      ((map['units'] as Map?) ?? {}).forEach((k, v) {
        units[k.toString()] =
            UnitProgress.fromJson((v as Map).cast<String, dynamic>());
      });
      skills = {};
      ((map['skills'] as Map?) ?? {}).forEach((k, v) {
        skills[k.toString()] =
            ((v as List).map((e) => (e as num).toInt())).toList();
      });
    } catch (_) {
      // Corrupted progress must never crash the app — start fresh instead.
      debugPrint('ProgressService: corrupted save ignored');
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode({
        'name': childName,
        'avatar': avatar,
        'chests': chestsOpened,
        'stickers': stickers,
        'review': reviewQueue,
        'units': units.map((k, v) => MapEntry(k, v.toJson())),
        'skills': skills,
      }));
    } catch (_) {}
  }
}
