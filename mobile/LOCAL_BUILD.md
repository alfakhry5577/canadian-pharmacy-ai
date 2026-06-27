# LOCAL_BUILD.md — بناء محلي على Windows / macOS / Linux

هذا الدليل **يحتاج** تثبيت Flutter SDK و Android SDK على جهازك (خلافًا لـ `STEP_BY_STEP_BUILD.md` الذي لا
يحتاج أي تثبيت). استخدمه إن رغبت بالبناء بدون الاعتماد على GitHub Actions.

---

## المتطلبات المسبقة (مرة واحدة فقط، لكل الأنظمة)

| الأداة | الحد الأدنى | ملاحظة |
|---|---|---|
| Flutter SDK | قناة stable | `flutter doctor` يجب أن يُظهر علامة ✅ عند "Flutter" و "Android toolchain" |
| Java (JDK) | 17 | Temurin/OpenJDK |
| Android SDK | compileSdk 34, Build-Tools 34 | يُثبَّت عادة تلقائيًا مع Android Studio |
| Git | أي إصدار حديث | لتحميل/نقل المشروع فقط |

أسهل طريقة للحصول على كل ما سبق دفعة واحدة: ثبّت **Android Studio** (يتضمن Android SDK)، ثم ثبّت **Flutter**
بشكل منفصل واربطه بـ Android Studio من Settings → Languages & Frameworks → Flutter.

تحقق من جاهزية بيئتك بهذا الأمر (نفسه على الأنظمة الثلاثة):
```bash
flutter doctor
```
لا تستمر للخطوات التالية حتى يظهر ✅ أمام "Flutter" و "Android toolchain" على الأقل.

---

## macOS

```bash
# 1) تثبيت Flutter (إن لم يكن مثبّتًا)
brew install --cask flutter
# أو يدويًا: نزّل من docs.flutter.dev وأضِف bin/ إلى PATH في ~/.zshrc أو ~/.bash_profile

# 2) فك ضغط المشروع المُستلَم، ثم:
cd pharmacy-ai-assistant/mobile

# 3) جلب الحزم
flutter pub get

# 4) (اختياري) فحص الكود
flutter analyze
flutter test

# 5) بناء APK
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com

# 6) بناء AAB (لمتجر Google Play)
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

**الناتج:**
- APK: `mobile/build/app/outputs/flutter-apk/app-release.apk`
- AAB: `mobile/build/app/outputs/bundle/release/app-release.aab`

---

## Linux

```bash
# 1) تثبيت Flutter (إن لم يكن مثبّتًا) — عبر snap أو تحميل يدوي
sudo snap install flutter --classic
# أو يدويًا: نزّل الأرشيف من docs.flutter.dev وأضِف flutter/bin إلى PATH في ~/.bashrc

# 2) فك ضغط المشروع المُستلَم، ثم:
cd pharmacy-ai-assistant/mobile

# 3) جلب الحزم
flutter pub get

# 4) (اختياري) فحص الكود
flutter analyze
flutter test

# 5) بناء APK
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com

# 6) بناء AAB
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

**الناتج:** نفس المسارات المذكورة في قسم macOS أعلاه (مسارات Flutter موحّدة عبر الأنظمة).

---

## Windows (PowerShell)

```powershell
# 1) تثبيت Flutter (إن لم يكن مثبّتًا)
# نزّل zip من https://docs.flutter.dev/get-started/install/windows
# فك الضغط في مسار بلا مسافات، مثل C:\src\flutter
# أضِف C:\src\flutter\bin إلى متغيّر البيئة PATH (Settings > Edit environment variables)

# 2) فك ضغط المشروع المُستلَم، ثم:
cd pharmacy-ai-assistant\mobile

# 3) جلب الحزم
flutter pub get

# 4) (اختياري) فحص الكود
flutter analyze
flutter test

# 5) بناء APK
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com

# 6) بناء AAB
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

**الناتج:**
- APK: `mobile\build\app\outputs\flutter-apk\app-release.apk`
- AAB: `mobile\build\app\outputs\bundle\release\app-release.aab`

> ملاحظة Windows: إن ظهر خطأ متعلق بـ "Symlink support" عند أول `flutter pub get`، فعّل Developer Mode من
> Windows Settings → Privacy & Security → For developers، أو شغّل PowerShell كـ Administrator مرة واحدة.

---

## ملاحظات تنطبق على الأنظمة الثلاثة

### `--dart-define=API_BASE_URL=...` اختياري
بدونه، يستخدم التطبيق قيمة افتراضية مدمجة في الكود (مناسبة فقط للمحاكي المحلي). **غيّرها لعنوان خادمك
الحقيقي** قبل توزيع أي نسخة فعلية على مستخدمين.

### توقيع الإصدار (Release Signing) — اختياري لأول بناء
بدون `android/key.properties`، يُوقَّع APK/AAB تلقائيًا بمفتاح debug — يعمل للتثبيت والتجربة، **لكنه غير
مقبول لرفعه على متجر Google Play**. لتوليد توقيع إنتاج حقيقي:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties
# عدّل storePassword / keyPassword / keyAlias / storeFile داخل الملف الجديد بمسار ملف .jks الذي أنشأته
```
(الأمر `keytool` يأتي مع تثبيت JDK، متاح على الأنظمة الثلاثة بنفس الاسم.)

### Firebase — اختياري تمامًا لأول بناء
المشروع يبني وينجح بدون أي إعداد Firebase. لتفعيل الإشعارات الفورية الحقيقية لاحقًا:
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<معرّف مشروعك في Firebase>
```

### ✅ تأكيد: لا حاجة لتعديل أي ملف Source Code قبل أول تشغيل لأي أمر بناء أعلاه على أي من الأنظمة الثلاثة.
