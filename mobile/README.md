# روشتة AI — Flutter Mobile App

تطبيق Android (وبنية جاهزة لـ iOS لاحقًا) يستخدم نفس FastAPI Backend الموجود في `../backend` — **لم يتم تعديل
الباك إند أو الفرونت إند Next.js إطلاقًا** في هذا العمل، وفق الطلب الصريح. هذا مجلد مستقل بالكامل: `mobile/`.

## ⚠️ ملاحظة شفافية حول التحقق (Verification)

حاولت تثبيت Flutter SDK فعليًا في بيئة البناء (sandbox) لتشغيل `flutter analyze`/`flutter test`/`flutter build`
والتحقق الآلي من الكود، لكن الشبكة هناك تمنع الوصول لخوادم تنزيل Dart SDK/Engine من Google (خارج نطاق
الدومينات المسموحة في تلك البيئة). لذلك:
- **لم يتم** تشغيل الكود فعليًا أو توليد APK/AAB في تلك البيئة.
- **تم** التحقق من كل ما هو قابل للفحص بدون Flutter SDK: صحة `pubspec.yaml` (YAML)، تطابق مفاتيح ملفات
  الترجمة AR/EN (JSON)، صحة كل ملفات `AndroidManifest.xml`/`styles.xml`/`colors.xml` (XML well-formed)، وصحة
  workflow الـ GitHub Actions (YAML).
- **أول بناء حقيقي** لهذا الكود سيحدث تلقائيًا عبر GitHub Actions (`.github/workflows/mobile-build.yml`) في
  أول push — وهو تحديدًا ما طلبتَه. إن ظهر أي خطأ Dart/Gradle لم يستطع هذا الفحص اليدوي رصده، افتحه كـ Issue
  وسأصلحه فورًا.

📋 **تدقيق شامل لاحق** (imports، providers، routes، Firebase، Gradle، إلخ) تم تنفيذه بأداة تحليل ساكن مخصّصة —
النتائج الكاملة، الأخطاء التي وُجدت وأُصلحت، وتقدير احتمال نجاح البناء: راجع
[`BUILD_READINESS_REPORT.md`](BUILD_READINESS_REPORT.md). أدوات التدقيق نفسها محفوظة في `scripts/static_audit/`.

---

## البنية

```
mobile/
├── lib/
│   ├── main.dart, app.dart
│   ├── core/            # theme, network (Dio+interceptors), storage, router, notifications, utils
│   ├── l10n/             # app_ar.arb (افتراضي) + app_en.arb
│   ├── data/             # models, services (Dio خام), repositories (Result<T>)
│   ├── providers/        # Riverpod: auth, theme/locale, medications, prescriptions, inventory, alerts, chat, reports, reminders, notifications
│   ├── widgets/          # مكوّنات مشتركة: أزرار، حالات فارغة/خطأ، شارات، Callout أمان
│   └── screens/          # auth, customer/*, pharmacist/*, admin/*
├── android/              # Gradle, Manifest, التوقيع, ProGuard
├── assets/images/        # أيقونة التطبيق + شاشة البداية (PNG حقيقية مولّدة)
└── test/                 # اختبارات وحدة (Validators, Formatters, ApiResult)
```

**التقنيات**: Flutter (stable) + Dart 3، Riverpod، Dio، go_router، Firebase Messaging +
flutter_local_notifications، flutter_secure_storage، Material 3، عربي RTL افتراضي + إنجليزي، Dark/Light Mode.

---

## التشغيل محليًا

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # المحاكي Android -> الباك إند على جهازك
```

شغّل الباك إند أولًا (راجع `../backend/README.md`)، وتأكد من تشغيل `python -m app.db.seed_data` للحصول على
حسابات تجريبية (admin/pharmacist/customer — راجع الجذر الرئيسي للمشروع).

على جهاز حقيقي (ليس محاكيًا)، استبدل `10.0.2.2` بعنوان IP الفعلي لجهازك على الشبكة المحلية، أو برابط نطاق حقيقي.

---

## إعداد Firebase (Push Notifications)

ملف `lib/firebase_options.dart` المُرفق هو **placeholder غير فعّال** عمدًا (موضّح بتعليق في رأس الملف). لتفعيل
Firebase Cloud Messaging فعليًا:

```bash
dart pub global activate flutterfire_cli
cd mobile
flutterfire configure --project=<your-firebase-project-id>
```

هذا الأمر يستبدل `firebase_options.dart` بقيم حقيقية، وينزّل `android/app/google-services.json` تلقائيًا.
بدون هذه الخطوة، يعمل التطبيق بشكل طبيعي تمامًا — فقط الإشعارات الفورية (push) تبقى معطّلة (انظر معالجة الخطأ
السلسة في `lib/main.dart`).

### ⚠️ Endpoint مطلوب على الـ Backend (غير موجود حاليًا)

لتسجيل FCM token لكل مستخدم على الخادم، يحتاج الباك إند مسارًا جديدًا غير موجود اليوم:

```python
# يُقترح إضافته في backend/app/api/routes/notifications.py (إضافة، لا تعديل لما هو موجود)
@router.post("/device-token")
def register_device_token(payload: DeviceTokenIn, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # احفظ (user_id, fcm_token, platform) في جدول جديد device_tokens
    ...
```

التطبيق يستدعي هذا المسار بأمان (يتجاهل 404 بهدوء) — راجع `lib/data/services/app_notification_service.dart`.

---

## بناء APK محليًا

```bash
cd mobile
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com
# الناتج: build/app/outputs/flutter-apk/app-release.apk
```

بدون `android/key.properties`، يستخدم هذا البناء توقيع debug تلقائيًا (يعمل للتثبيت والتجربة، **غير مقبول
لمتجر Google Play**).

## بناء AAB (لمتجر Google Play)

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.yourdomain.com
# الناتج: build/app/outputs/bundle/release/app-release.aab
```

---

## توقيع نسخة الإنتاج (Release Signing)

```bash
# 1) إنشاء keystore حقيقي (مرة واحدة فقط، واحفظه في مكان آمن — لا تفقده):
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2) أنشئ android/key.properties من القالب:
cp android/key.properties.example android/key.properties
# عدّل storePassword / keyPassword / keyAlias / storeFile (مسار مطلق لملف .jks) داخل الملف

# 3) android/key.properties و android/*.jks مُستثناة من Git تلقائيًا (.gitignore) — لا ترفعهما إلى GitHub مطلقًا.

# 4) أعد البناء:
flutter build appbundle --release
```

---

## CI/CD — بناء APK/AAB تلقائيًا عند كل Push

ملف `.github/workflows/mobile-build.yml` (في جذر المشروع، لا داخل `mobile/`، لأن GitHub Actions يقرأ فقط من
`.github/workflows` في جذر المستودع) يقوم تلقائيًا بكل push أو PR بـ:
1. تثبيت Flutter + Java 17
2. `flutter pub get` + `flutter analyze` + `flutter test`
3. بناء APK و AAB (release)
4. رفعهما كـ Artifacts قابلة للتحميل من تبويب Actions في GitHub
5. عند دفع تاغ بصيغة `mobile-v1.0.0`: إنشاء GitHub Release يرفق الملفين تلقائيًا

### لتفعيل توقيع إنتاج حقيقي داخل CI (اختياري)

أضف 4 Secrets في إعدادات المستودع (Settings → Secrets and variables → Actions):

| Secret | القيمة |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -i upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | كلمة مرور الـ keystore |
| `ANDROID_KEY_ALIAS` | `upload` (أو ما اخترته) |
| `ANDROID_KEY_PASSWORD` | كلمة مرور المفتاح |

وإن رغبت بتفعيل Firebase داخل CI أيضًا: أضف `ANDROID_GOOGLE_SERVICES_JSON_BASE64` (= `base64 -i google-services.json`).

بدون هذه الـ secrets، يستمر البناء بنجاح (توقيع debug) — مناسب لفحص أن الكود يُبنى بدون أخطاء على كل push،
وهو ما طُلب تحديدًا.

---

## دليل تحضير متجر Google Play (مختصر)

1. أنشئ حساب Google Play Console (رسم تسجيل لمرة واحدة).
2. أنشئ تطبيقًا جديدًا، application ID: `com.roshetta.pharmacy` (مضبوط في `android/app/build.gradle`).
3. ارفع `app-release.aab` الموقّع بمفتاح إنتاج حقيقي (لا توقيع debug) إلى "Internal testing" أولًا.
4. أكمل "App content": Privacy Policy URL، Data safety form (التطبيق يرفع صور وصفات طبية — صرّح بذلك بدقة)،
   Content rating.
5. لقطات الشاشة + أيقونة 512×512 (استخدم `assets/images/app_icon.png` كنقطة بداية، بدّلها بتصميم نهائي معتمد).
6. بعد اعتماد Internal testing، انتقل تدريجيًا لـ Closed → Open → Production.

⚠️ **بيانات صحية حساسة**: بما أن التطبيق يرفع صور وصفات طبية، التزم بسياسة Google Play لتطبيقات الرعاية
الصحية، وأكمل نموذج Data Safety بدقة (ما تجمعه، كيف تخزّنه، هل تشاركه).

---

## الأعمال المستقبلية (Known Gaps — بصراحة كاملة)

نفس نهج الشفافية المعتمد في الباك إند والفرونت إند:

- **Forgot Password / OTP**: الواجهة كاملة (`screens/auth/forgot_password_screen.dart`) لكنها تحتاج
  `POST /api/auth/forgot-password` و `/api/auth/reset-password` على الباك إند (غير موجودين حاليًا).
- **تسجيل FCM token على الخادم**: يحتاج `POST /api/notifications/device-token` (مقترح أعلاه).
- **شاشات الإدارة (مستخدمون / سجل التدقيق / مراقبة AI)**: واجهات كاملة الجودة ببيانات توضيحية (mock)، معلَّمة
  بشارة `ScaffoldNoticeBanner` صريحة — مطابقة تمامًا لما هو في نسخة الويب.
- **بث الدردشة الحقيقي (token streaming)**: الباك إند يُرجع ردًا كاملاً دفعة واحدة؛ لا يوجد تأثير "كتابة تدريجية"
  مزيّف هنا (خلافًا لنسخة الويب) — الرسالة تظهر كاملة عند وصولها.
- **iOS**: البنية (Riverpod/Dio/go_router/الشاشات) مستقلة عن المنصة بالكامل، لكن لم يتم إنشاء مجلد `ios/`
  أو ضبط Info.plist/الأذونات — مطلوب فقط إن احتجت نسخة iOS لاحقًا.
