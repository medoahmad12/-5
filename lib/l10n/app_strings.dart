import 'package:flutter/material.dart';

/// A bilingual string pair (Arabic first — the app's primary language).
class Str {
  final String ar;
  final String en;
  const Str(this.ar, this.en);
}

/// Tiny localization layer: no codegen, fully offline, easy for content editors.
/// Usage:  context.tr('wellDone')   /   context.isAr
class S {
  S._();

  static const Map<String, Str> _map = {
    // ---- General / onboarding ----
    'appName': Str('عالم المستكشفين الصغار', 'Little Explorers World'),
    'tagline': Str('تعلّم باللعب والاكتشاف', 'Learn by playing and exploring'),
    'chooseLanguage': Str('اختر لغة التطبيق', 'Choose app language'),
    'arabicLang': Str('العربية', 'Arabic'),
    'englishLang': Str('الإنجليزية', 'English'),
    'whatsName': Str('ما اسمك يا بطل؟', "What's your name, hero?"),
    'nameHint': Str('اسمك أو لقبك', 'Your name or nickname'),
    'chooseFriend': Str('اختر صديقك المفضل', 'Pick your favorite friend'),
    'letsGo': Str('هيا نبدأ المغامرة', "Let's start the adventure"),
    'skip': Str('تخطي', 'Skip'),
    'hello': Str('أهلاً', 'Hello'),
    'privateNote': Str('بلا إعلانات • بلا إنترنت • بلا جمع بيانات',
        'No ads • No internet • No data collection'),

    // ---- Worlds ----
    'worldMap': Str('خريطة العوالم', 'World Map'),
    'worldArabic': Str('جزيرة الحروف', 'Letters Island'),
    'worldEnglish': Str('مدينة الحروف الإنجليزية', 'English City'),
    'worldNumbers': Str('حديقة الأرقام', 'Numbers Garden'),
    'worldColors': Str('غابة الألوان والأشكال', 'Colors & Shapes Forest'),
    'worldCastle': Str('قلعة الأبطال', 'Heroes Castle'),
    'locked': Str('مقفل', 'Locked'),
    'needStars': Str('اجمع @n نجومًا لفتح هذا العالم',
        'Collect @n stars to unlock'),
    'stars': Str('نجوم', 'Stars'),
    'progress': Str('التقدم', 'Progress'),

    // ---- Hub / lesson ----
    'continueWord': Str('تابع', 'Continue'),
    'nextUnit': Str('التالي', 'Next'),
    'backToMap': Str('رجوع للخريطة', 'Back to map'),
    'tapGlyphHint': Str('المس الحرف لتسمع صوته', 'Tap the letter to hear it'),
    'tapNumHint': Str('المس الرقم وعدّ معي', 'Tap the number and count with me'),
    'tapShapeHint': Str('المس الشكل لتسمعه', 'Tap the shape to hear it'),
    'thisIs': Str('هذا هو', 'This is'),
    'word': Str('الكلمة', 'Word'),
    'forms': Str('أشكال الحرف', 'Letter shapes'),
    'tapToHear': Str('المس لتسمع', 'Tap to hear'),
    'listenWord': Str('اسمع الكلمة', 'Hear the word'),

    // ---- Games ----
    'gameListen': Str('اختر ما تسمع', 'Choose what you hear'),
    'gameDrag': Str('اسحب إلى الصورة المناسبة', 'Drag to the right picture'),
    'gameMemory': Str('جد الأزواج المتشابهة', 'Find the matching pairs'),
    'gameFeed': Str('أطعم توتو', 'Feed Toto'),
    'gameBalloons': Str('فقّع البالونات', 'Pop the balloons'),
    'gameBubbles': Str('فقاعات الحروف', 'Letter bubbles'),
    'gameCollect': Str('اجمع النجوم', 'Collect the stars'),
    'gameTrain': Str('رتب القطار', 'Sort the train'),
    'gameOdd': Str('اختر المختلف', 'Find the odd one'),
    'gameFind': Str('ابحث عن الحرف', 'Find the letter'),
    'gamePattern': Str('أكمل النمط', 'Complete the pattern'),
    'replay': Str('أعد الاستماع', 'Listen again'),
    'feedHint': Str('أطعم توتو @n جزرات', 'Feed Toto @n carrots'),
    'popHint': Str('فقّع @n بالونات', 'Pop @n balloons'),
    'popLetterHint': Str('فقّع فقاعات حرف @g', 'Pop bubbles with letter @g'),
    'collectHint': Str('اجمع @n نجومًا', 'Collect @n stars'),
    'findHint': Str('أين حرف @g؟', 'Where is letter @g?'),
    'orderHint': Str('رتّب الأرقام من الصغير للكبير',
        'Sort numbers from small to big'),
    'oddHint': Str('أيّها مختلف؟', 'Which one is different?'),
    'patternHint': Str('ماذا يأتي في الفراغ؟', 'What goes in the gap?'),
    'dragHint': Str('اسحب الحرف إلى الصورة', 'Drag the letter to the picture'),
    'matchCaseHint': Str('طابق الحرف الكبير مع الصغير',
        'Match the big letter with the small one'),
    'listenHint': Str('استمع واختر', 'Listen and choose'),

    // ---- Feedback ----
    'wellDone': Str('أحسنت!', 'Well done!'),
    'greatJob': Str('عمل رائع!', 'Great job!'),
    'youStar': Str('أنت نجم!', 'You are a star!'),
    'tryAgain': Str('حاول مرة أخرى', 'Try again'),
    'almost': Str('قريب جدًا!', 'Almost!'),
    'starEarned': Str('نجمة جديدة!', 'New star!'),
    'treasureOpen': Str('فتحت صندوق الكنوز!', 'Treasure chest opened!'),
    'newSticker': Str('ملصق جديد!', 'New sticker!'),
    'lessonDone': Str('أكملت المرحلة', 'Lesson complete'),

    // ---- Castle ----
    'yourStickers': Str('ملصقاتك', 'Your stickers'),
    'yourHeroes': Str('أبطالك', 'Your heroes'),
    'chests': Str('صناديق الكنوز', 'Treasure chests'),
    'keepExploring': Str('واصل الاستكشاف لتجمع المزيد!',
        'Keep exploring to collect more!'),
    'lockedSticker': Str('اجمع @n نجومًا', 'Collect @n stars'),

    // ---- Parent zone ----
    'parentZone': Str('منطقة الكبار فقط', 'Grown-ups only'),
    'parentGateHint': Str('هذا القسم مخصص لولي الأمر.\nحلّ العملية للمتابعة.',
        'This area is for parents.\nSolve the problem to continue.'),
    'solve': Str('كم يساوي', 'What is'),
    'wrongTry': Str('إجابة غير صحيحة، حاول مجددًا', 'Wrong answer, try again'),
    'dashboard': Str('لوحة الوالد', 'Parent dashboard'),
    'progressOverview': Str('نظرة عامة', 'Overview'),
    'skills': Str('المهارات', 'Skills'),
    'skillRecognition': Str('التعرّف', 'Recognition'),
    'skillListening': Str('الاستماع', 'Listening'),
    'skillCounting': Str('العدّ', 'Counting'),
    'skillMemory': Str('الذاكرة', 'Memory'),
    'needsReview': Str('يحتاج مراجعة', 'Needs review'),
    'noReview': Str('لا شيء يحتاج مراجعة الآن', 'Nothing needs review now'),
    'settings': Str('الإعدادات', 'Settings'),
    'sound': Str('المؤثرات الصوتية', 'Sound effects'),
    'music': Str('الموسيقى', 'Music'),
    'haptics': Str('الاهتزاز', 'Vibration'),
    'reduceMotion': Str('تقليل الحركة', 'Reduce motion'),
    'unlockAllWorlds': Str('فتح كل العوالم', 'Unlock all worlds'),
    'language': Str('اللغة', 'Language'),
    'resetProgress': Str('إعادة ضبط التقدم', 'Reset progress'),
    'resetConfirmTitle': Str('إعادة ضبط كل التقدم؟', 'Reset all progress?'),
    'resetConfirmBody': Str(
        'سيُحذف كل تقدم الطفل ونجومه وملصقاته نهائيًا.',
        'All of the child\'s stars, stickers and progress will be permanently deleted.'),
    'cancel': Str('إلغاء', 'Cancel'),
    'confirm': Str('نعم، إعادة الضبط', 'Yes, reset'),
    'completedOf': Str('@done من @total', '@done of @total'),
    'exitChild': Str('رجوع لعالم الطفل', 'Back to child world'),
    'quickReview': Str('مراجعة سريعة مع فوفو', 'Quick review with Foufou'),
    'reviewDesc': Str('لنراجع ما يحتاجها قليلًا', 'A little practice, just for you'),
    'lessonsDone': Str('دروس مكتملة', 'Lessons done'),
    'totalStars': Str('مجموع النجوم', 'Total stars'),
  };

  static String trOf(String key, bool isAr) {
    final s = _map[key];
    if (s == null) return key;
    return isAr ? s.ar : s.en;
  }

  /// Replace simple @placeholders: fill('needStars', {'n': '8'})
  static String fill(String template, Map<String, String> values) {
    var out = template;
    values.forEach((k, v) {
      out = out.replaceAll('@$k', v);
    });
    return out;
  }
}

extension TrContext on BuildContext {
  bool get isAr =>
      Localizations.localeOf(this, nullOk: true)?.languageCode != 'en';

  String tr(String key) => S.trOf(key, isAr);

  String trF(String key, Map<String, String> values) =>
      S.fill(tr(key), values);
}

extension TrNoCtx on String {
  String trRaw(bool isAr) => S.trOf(this, isAr);
}
