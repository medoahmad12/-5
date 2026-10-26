/// Central registry of every bundled asset path.
/// Nothing in the app builds asset strings by hand — always use this class,
/// so renaming an asset is a one-line change.
class AppAssets {
  AppAssets._();

  // ---------------- Backgrounds ----------------
  static const String bgMap = 'assets/images/bg/bg_map.jpg';
  static const String bgArabic = 'assets/images/bg/bg_arabic.jpg';
  static const String bgEnglish = 'assets/images/bg/bg_english.jpg';
  static const String bgNumbers = 'assets/images/bg/bg_numbers.jpg';
  static const String bgColors = 'assets/images/bg/bg_colors.jpg';
  static const String bgCastle = 'assets/images/bg/bg_castle.jpg';

  // ---------------- Characters: [char]_[pose].png ----------------
  static String char(String id, String pose) =>
      'assets/images/chars/${id}_$pose.png';
  static const String luluIdle = 'assets/images/chars/lulu_idle.png';
  static const String luluPoint = 'assets/images/chars/lulu_point.png';
  static const String luluCheer = 'assets/images/chars/lulu_cheer.png';
  static const String totoIdle = 'assets/images/chars/toto_idle.png';
  static const String totoPoint = 'assets/images/chars/toto_point.png';
  static const String totoCheer = 'assets/images/chars/toto_cheer.png';
  static const String boboIdle = 'assets/images/chars/bobo_idle.png';
  static const String boboPoint = 'assets/images/chars/bobo_point.png';
  static const String boboCheer = 'assets/images/chars/bobo_cheer.png';
  static const String foufoIdle = 'assets/images/chars/foufo_idle.png';
  static const String foufoPoint = 'assets/images/chars/foufo_point.png';
  static const String foufoCheer = 'assets/images/chars/foufo_cheer.png';

  // ---------------- Object pictures ----------------
  static String object(String name) => 'assets/images/objects/$name.png';

  // ---------------- App icon ----------------
  static const String icon = 'assets/icon.png';

  // ---------------- Audio: bundled English narration ----------------
  static String enLetter(String letter) =>
      'audio/en/letter_${letter.toUpperCase()}.ogg';
  static String enWord(String key) => 'audio/en/word_$key.ogg';
  static String enNumber(int n) => 'audio/en/num_$n.ogg';
  static String enInstruction(String key) => 'audio/en/ins_$key.ogg';

  // ---------------- Audio: sound effects ----------------
  static String sfx(String name) => 'audio/sfx/$name.wav';
  // Available: tap, pop, star, success, gentle, whoosh, treasure, unlock, count

  // ---------------- Audio: music ----------------
  static const String musicLoop = 'audio/music/peaceful_loop.ogg';
}
