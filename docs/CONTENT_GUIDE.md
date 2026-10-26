# دليل تعديل المحتوى — Content Guide

كل المحتوى التعليمي بيانات صريحة في مجلد `lib/data/` — لا حاجة للمس أي شاشة أو لعبة.

## 1) إضافة أو تعديل حرف عربي

افتح `lib/data/content_arabic.dart` وعدّل `UnitDef` أو أضف واحدًا:

```dart
UnitDef(
  id: 'jeem',                    // معرف فريد (يُستخدم لحفظ التقدم)
  glyph: 'ج',                    // الحرف المعروض
  nameAr: 'جيم',                 // الاسم المعروض
  nameEn: 'Jeem',
  ttsAr: 'جيم',                  // النص المنطوق بصوت الجهاز — اكتبه بالحركات
  wordAr: 'جَمَل',               // كلمة المثال
  wordTtsAr: 'جَمَل',
  wordEn: 'Camel',
  imageAsset: 'camel',           // assets/images/objects/camel.png
  forms: ['ج', 'جـ', 'ـجـ', 'ـج'], // منفصل/أول/وسط/آخر (بالتطويل)
  color: AppColors.brown,        // لون هوية الحرف
)
```

**متطلب النطق العربي الجيد:** اكتب `ttsAr` و`wordTtsAr` **بالحركات الكاملة** — محرك الجهاز ينتطق النص المشكول بدقة أعلى بكثير.

## 2) الحروف الإنجليزية (`content_english.dart`)

- `audioEn: 'letter_A'` → يُشغّل `assets/audio/en/letter_A.ogg`.
- كلمة المثال: `imageAsset: 'apple'` → الصورة + `assets/audio/en/word_apple.ogg`.
- لتسجيل كلمة جديدة: ضع ملف `word_<imageAsset>.ogg` (ogg vorbis) وسيُستخدم تلقائيًا، وإن غاب يُنطق بصوت الجهاز.

## 3) الأرقام والألوان والأشكال

- `content_numbers.dart`: `glyph` هو الرقم؛ ألعاب العد والقطار والبالونات تقرأه تلقائيًا.
- `content_colors_shapes.dart`: ألوان بلا `glyph` (تُرسم فقاعة وجه لطيفة بلون الوحدة)، والأشكال `glyph` يكون نوع الرسم: `circle square triangle star heart rectangle diamond oval`.

## 4) إضافة لعبة جديدة

1. `lib/data/models.dart`: أضف قيمة إلى `enum GameType`.
2. أنشئ `lib/games/my_game.dart` على نمط الألعاب الحالية: تستقبل `subject/unit/pool/onDone` وتنادي `onDone(GameResult(mistakes:…, completed: true, skill: '…'))`.
3. `lib/game_engine/game_host.dart`: أضف حالة في `switch`.
4. `lib/data/worlds.dart`: أدرجها في `gameRotation` لأي مادة.

استخدم الأدوات الجاهزة: `InstructionBar` (شريط تعليمات بنطق ثنائي)، `unitVisual` (رسم موحد للوحدة)، `narrateHint`/`narrateUnitName` (نطق)، `OptionCard` (بطاقات إجابة بحالات صح/خطأ/تلميح).

## 5) إضافة عالم (مادة) جديد

في `lib/data/worlds.dart`:
1. عرّف `SubjectDef` (خلفية `bgAsset`، شخصية `guide`، وحدات، دورة ألعاب).
2. أضفه إلى `kSubjects`.
3. أضف `WorldDef` إلى `kWorlds` مع `starThreshold` — الجزيرة تظهر في الخريطة تلقائيًا بموقعها في القائمة (عدّل مواضع `_spots` في `world_map_screen.dart` إن لزم).

## 6) المكافآت

- صندوق كل 15 نجمة: `kStarsPerChest`.
- الملصقات: قائمة `kStickers` (صورة + عتبة نجوم) — تُفتح تلقائيًا وتظهر في القلعة والاحتفالات.
- عتبات فتح العوالم: `starThreshold` في كل `WorldDef`، ويمكن لول الأمر فتح الكل من اللوحة.

## 7) الأصول

- صور الشخصيات: `assets/images/chars/<id>_<pose>.png` (pose = idle/point/cheer).
- صور الكائنات: `assets/images/objects/<name>.png` بخلفية شفافة (أو بيضاء).
- الخلفيات: `assets/images/bg/*.jpg`.
- سجل كل المسارات في مكان واحد: `lib/core/constants/app_assets.dart`.
- أدوات إعادة التوليد والمعالجة في `tools/` (تتطلب بيئة بايثون مع OpenCV/Pillow).
