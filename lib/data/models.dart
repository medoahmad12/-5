import 'package:flutter/material.dart';

/// ---------------- Game types ----------------
///
/// Each engine implements one real interaction mechanic:
enum GameType {
  listenChoose, // hear a sound -> pick the right card
  dragMatch, // drag a glyph onto the matching picture
  matchCase, // match uppercase with lowercase (English)
  memory, // flip cards, find pairs
  countFeed, // drag items one-by-one to feed a character
  balloons, // pop exactly N balloons
  bubblesV, // letter bubbles float up, pop the right ones
  collectStars, // collect stars inside a scene
  trainOrder, // order numbers so the train departs
  oddOne, // find the different item
  findScene, // find hidden letters inside a scene
  pattern, // complete a simple AB pattern
}

/// ---------------- Learning units ----------------
///
/// One unit = one letter / number / color / shape lesson.
class UnitDef {
  final String id; // unique key, e.g. 'alef', 'b', 'num3', 'red'
  final String glyph; // what is displayed big ('أ', 'A', '3' or '' for blobs)
  final String nameAr;
  final String nameEn;
  final String ttsAr; // text spoken by the device TTS engine (with diacritics)
  final String? audioEn; // bundled English narration key (nullable)
  final String? wordAr; // example word (Arabic)
  final String? wordEn; // example word (English)
  final String? wordTtsAr; // device TTS for the Arabic word
  final String? imageAsset; // object picture (asset name under objects/)
  final List<String> forms; // Arabic letter position forms (iso/init/med/fin)
  final Color color; // theme tint of this unit

  const UnitDef({
    required this.id,
    required this.glyph,
    required this.nameAr,
    required this.nameEn,
    required this.ttsAr,
    this.audioEn,
    this.wordAr,
    this.wordEn,
    this.wordTtsAr,
    this.imageAsset,
    this.forms = const [],
    this.color = const Color(0xFF4EA8DE),
  });

  String get wordKey => imageAsset ?? '';
}

/// ---------------- Subjects (learning tracks) ----------------
class SubjectDef {
  final String id; // 'ar', 'en', 'num', 'col'
  final String titleAr;
  final String titleEn;
  final String bgAsset; // hub background
  final String guide; // character id: lulu / toto / bobo / foufo
  final Color color;
  final List<UnitDef> units;
  final List<GameType> gameRotation; // cycled per lesson
  final bool isLetters; // affects intro/word stage widgets
  final bool isNumbers; // enables counting intro + number games

  const SubjectDef({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bgAsset,
    required this.guide,
    required this.color,
    required this.units,
    required this.gameRotation,
    this.isLetters = false,
    this.isNumbers = false,
  });

  UnitDef unit(String id) => units.firstWhere((u) => u.id == id);
}

/// ---------------- Worlds on the map ----------------
class WorldDef {
  final String id;
  final String titleAr;
  final String titleEn;
  final String bgAsset;
  final String thumbChar; // character shown in the island bubble
  final String iconGlyph; // small glyph drawn on the node
  final Color color;
  final int starThreshold; // stars needed to unlock
  final String? subjectId; // opens a subject hub, null = castle screen

  const WorldDef({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bgAsset,
    required this.thumbChar,
    required this.iconGlyph,
    required this.color,
    required this.starThreshold,
    this.subjectId,
  });
}

/// ---------------- Stickers ----------------
class StickerDef {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? imageAsset; // object/character asset
  final String? glyph; // drawn fallback (e.g. star glyph)
  final Color color;
  final int unlockStars; // total stars needed

  const StickerDef({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageAsset,
    this.glyph,
    required this.color,
    required this.unlockStars,
  });
}

/// ---------------- Game result ----------------
class GameResult {
  final int mistakes;
  final bool completed;
  final String skill; // which skill this game trains
  const GameResult({
    required this.mistakes,
    required this.completed,
    required this.skill,
  });

  /// 3 stars = flawless, 2 stars = a few tries, 1 star = finished anyway.
  /// No timers, no pressure — a child always finishes with at least one star.
  int get stars => !completed
      ? 0
      : mistakes == 0
          ? 3
          : mistakes <= 2
              ? 2
              : 1;
}
