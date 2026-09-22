# M-Fateh — Project State / حالة المشروع

> هذا الملف هو نقطة الاستئناف الرسمية للمشروع. إذا انقطعت محادثة ChatGPT أو بدأت محادثة جديدة، اقرأ هذا الملف أولاً ولا تبدأ المشروع من الصفر.
>
> آخر تحديث: 2026-09-22

## 1. هوية المشروع

- الاسم: **M-Fateh**
- المستودع: `fateh1989/M-Fateh`
- الفرع: `main`
- الأصل Upstream: `eidolonFIRE/xcNav`
- التقنية: Flutter / Dart / Android
- الترخيص: GPL-3.0. يجب الحفاظ على الترخيص ونَسب المشروع الأصلي.
- الهدف: تطوير xcNav إلى تطبيق طيران شخصي عربي للباراموتور باسم M-Fateh، مع الحفاظ على الوظائف الأساسية غير المتصلة بالإنترنت، ثم تطويره لاحقاً بميزات السلامة والوعي بالمحيط.
- Android applicationId الجديد: `com.mfateh.flight` حتى يكون M-Fateh تطبيقاً مستقلاً ولا يظهر كتحديث لـ xcNav.
- لا تغيّر المشروع إلى RUN أو YM أو Binaa. هذا مشروع مستقل.

## 2. فلسفة المشروع

الهاتف هو وحدة الحوسبة والعرض والاتصالات الأساسية. الوزن واستهلاك الطاقة مهمان جداً في الباراموتور، لذلك لا نضيف صندوقاً خارجياً إلا عندما لا يستطيع الهاتف أداء الوظيفة.

الاتجاه المستقبلي بعد استقرار النسخة العربية:
- الطقس والرياح.
- المجال الجوي وNOTAM.
- الوعي بالطائرات القريبة، ويفضل دعم ADS-B المباشر عند الإمكان.
- طبقة Obstacle Awareness.
- لاحقاً رادار mmWave / LiDAR خارجي خفيف عبر Bluetooth أو USB عند الحاجة، خصوصاً للرؤية في الضباب.
- تنبيهات اتجاه + مسافة + صوت/اهتزاز.
- الأولوية للعمل Offline، ثم استهلاك الطاقة والوزن.

لا تبدأ هذه الميزات قبل أن تصبح النسخة العربية الأساسية قابلة للفتح والتجربة إلا إذا طلب المستخدم تغيير الأولوية.

## 3. ما تم إنجازه

### التعريب
- أضيف `assets/translations/ar.json`.
- أضيفت العربية إلى `lib/locale.dart`.
- العربية أضيفت في نهاية enum لتجنب تغيير أرقام اللغات القديمة المخزنة للمستخدمين.
- اختبار `test/locale_test.dart` أصبح يختبر العربية تلقائياً.
- عولجت 28 ترجمة/مفتاحاً كانت مفقودة.
- اختبار Locale في GitHub Actions أصبح **ناجحاً**.
- EasyLocalization + MaterialApp يوفران RTL الأساسي تلقائياً عند اختيار العربية.
- ما زال يلزم اختبار بصري فعلي للـRTL والبحث عن left/right hard-coded في الواجهات.

### الاسم والهوية
- `MaterialApp.title` أصبح `M-Fateh`.
- `AndroidManifest.xml` أصبح label = `M-Fateh`.
- `applicationId` و namespace أصبحا `com.mfateh.flight`.
- السبب: النسخة الأولى ثبتها Android كتحديث لـ xcNav لأن المعرف بقي `com.xcnav`.

### CI / APK
أضيف workflow:
`.github/workflows/android-apk.yml`

المراحل:
1. checkout
2. Flutter stable
3. flutter pub get
4. locale tests
5. إنشاء `lib/secrets.dart` آمن للبناء المفتوح
6. flutter build apk --release
7. رفع Artifact باسم `M-Fateh-APK`

تمت إضافة fallback للتوقيع: إذا لم يوجد keystore الأصلي، يستخدم CI توقيع debug لإنتاج APK قابل للتثبيت والتجربة.

## 4. المشاكل التي ظهرت وكيف عولجت

### Build #1 — فشل
Run: 35675135570
Commit: `0fdfdc490d531a43ab4b1af87946ac3be2301edc`

السبب: اختبار اللغة وجد 28 مفتاحاً مفقوداً في العربية.
الإصلاح: إضافة جميع المفاتيح.
Commit: `629cad81aac6cb157c1293e222522abac45a1bd1`.

### Build #2 — فشل
Run: 35677079214

اختبار اللغة نجح، ثم فشل APK لأن upstream لا يضع `lib/secrets.dart` في المستودع.
المتغيرات المطلوبة شملت Datadog وprofile store وreflector endpoint.
الإصلاح: CI ينشئ secrets stub بقيم `unset` بدلاً من نسخ أسرار المطور الأصلي.
Commit: `d205c5361384e4ae4a2406d458b1b87b1acadfdc`.

### Build #3 — فشل
Run: 35677670398

تجاوز التعريب وsecrets ووصل إلى packageRelease.
الخطأ:
`SigningConfig "release" is missing required property "storeFile"`

الإصلاح: عند غياب key.properties يستخدم build توقيع debug.
Commit: `0572d7b3a90f09474ae6e20d9ec05bf74fd630a7`.

### Build #4 — نجاح
Run: 35680322060

أنتج APK فعلياً. لكن النسخة بقيت بمعرف `com.xcnav`، لذلك عند تثبيتها تعامل Android معها كتحديث لـ xcNav. هذه النسخة لا تعتبر النسخة الصحيحة النهائية لـM-Fateh.

### Build #5 — فشل
Run: 35684314736

كان commit وسيطاً أثناء تغيير applicationId؛ تبعه تعديل Manifest، لذلك لا نعتمد هذا البناء.

### Build #6 — نجاح
Run: 35684319515
Commit: `30b52d82a7002f0a482d0a0e96f483be17baaefb`

أنتج Artifact `M-Fateh-APK` بمعرف مستقل `com.mfateh.flight`.
Artifact ID: `10675979144`.
تم تنزيله واستخراج APK باسم `M-Fateh-v2.apk`.
المستخدم ثبته، لكنه أفاد أن التطبيق **لا يفتح**.

هذه الملاحظة مهمة: نجاح GitHub Build لا يعني أن التطبيق يعمل Runtime.

## 5. مشكلة Runtime الحالية

بعد أن قال المستخدم إن M-Fateh-v2 لا يفتح، تمت مراجعة `lib/main.dart`.

وجد أن التطبيق قبل `runApp` ينفذ:
`DatadogSdk.instance.initialize(...)`

بينما CI ينشئ مفاتيح Datadog بقيمة `unset` لأن مفاتيح upstream خاصة وغير موجودة في المستودع. هذا مرشح قوي لانهيار التطبيق عند startup قبل ظهور Flutter UI.

تم تعديل `main.dart`:
- إذا كانت مفاتيح Datadog حقيقية: يبدأ Datadog كالمعتاد.
- إذا كانت `unset`: يتجاوز Datadog تماماً ولا يمنع تشغيل M-Fateh.
- لا نضع مفاتيح المطور الأصلي الخاصة في المستودع.

Commit:
`9d95ba0a21532dffcc309db2756bc34856289125`

## 6. الحالة الحية عند كتابة هذا الملف

Build #7:
- Run ID: `35689075859`
- Head commit: `9d95ba0a21532dffcc309db2756bc34856289125`
- الحالة عند آخر فحص قبل كتابة الملف: **in_progress**
- الهدف: اختبار إصلاح startup/Datadog وإنتاج APK جديد.

يجب عند الاستئناف أولاً فحص Build #7. إذا نجح:
1. تنزيل Artifact الجديد فقط.
2. استخراج APK.
3. إعطاؤه للمستخدم للتثبيت.
4. لا تدّع أن مشكلة الفتح حُلّت حتى يفتحه المستخدم فعلياً أو يتم الحصول على runtime log يؤكد ذلك.

إذا لم يفتح APK الجديد:
- لا تخمّن.
- احصل على Android crash log / logcat إن أمكن عبر الجهاز/RDC/Termux أو طريقة متاحة.
- أصلح الاستثناء الحقيقي التالي.
- لا تعدل عدة أشياء عشوائياً في وقت واحد.

## 7. Commits المهمة

- `d7eff5823385b36b27272e89fc23ec99aeffb620` — إنشاء ar.json أول مرة.
- `f5a7b018998fd5c218d4b79d3b88941d653d6e58` — إضافة العربية.
- `c07fa10f84ec0867a0e7839f1e87caf1507712b2` — توسعة التعريب.
- `1e4d7d746c2f0cae15224d10d6ab4579c451ff16` — حماية ترتيب enum وإضافة العربية في النهاية.
- `3c31b13f3ccac77b3c954bb7eb3976fb597344d0` — عنوان M-Fateh.
- `0fdfdc490d531a43ab4b1af87946ac3be2301edc` — GitHub Actions APK workflow.
- `629cad81aac6cb157c1293e222522abac45a1bd1` — إصلاح 28 مفتاحاً عربياً.
- `d205c5361384e4ae4a2406d458b1b87b1acadfdc` — secrets stub للبناء المفتوح.
- `0572d7b3a90f09474ae6e20d9ec05bf74fd630a7` — debug signing fallback.
- `dfc895f071d3c0ab2a56e795abed5ec83b230646` — applicationId مستقل.
- `30b52d82a7002f0a482d0a0e96f483be17baaefb` — Android launcher branding.
- `9d95ba0a21532dffcc309db2756bc34856289125` — تعطيل Datadog عند غياب credentials.

## 8. أشياء لم تكتمل بعد

- إثبات أن APK يفتح فعلياً على جهاز المستخدم.
- اختبار الواجهة العربية بصرياً.
- مراجعة RTL في custom widgets:
  `Alignment.centerLeft/right`,
  `EdgeInsets.only(left/right)`,
  `Positioned(left/right)`.
  استخدم Directional equivalents فقط عندما يكون الانعكاس صحيحاً دلالياً؛ لا تقلب أدوات الطيران/الخريطة عشوائياً.
- مراجعة ar.json للعبارات التي ما زالت إنجليزية وليست اختصارات تقنية مقصودة.
- الحفاظ على attribution في about_description، وذكر Caleb Johnson والمشروع الأصلي بصورة صحيحة.
- فحص الوظائف التي كانت تعتمد على private backend: profile store / group reflector / telemetry. لا تدّع أنها تعمل بمجرد أن يفتح التطبيق.
- تغيير patrol app_name في pubspec إذا بقي xcNav، بعد التأكد أنه لا يكسر الاختبارات.
- أيقونة M-Fateh الخاصة لم تُنجز بعد.

## 9. قاعدة النجاح

لا يعتبر M-Fateh جاهزاً لمجرد أن CI أخضر.

الحد الأدنى للمرحلة الحالية:
- CI أخضر.
- APK مستقل باسم وهوية M-Fateh.
- التطبيق يفتح على جهاز المستخدم.
- العربية قابلة للاختيار وتظهر.
- RTL الأساسي يعمل دون كسر واجهة الطيران.
- وظائف xcNav المحلية الأساسية لا تنهار بسبب إزالة private services.

بعد ذلك فقط نبدأ ميزات M-Fateh الجديدة.
