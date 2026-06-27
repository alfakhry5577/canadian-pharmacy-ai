# STEP_BY_STEP_BUILD.md — بناء APK/AAB عبر GitHub Actions (بدون أي إعداد محلي)

هذا الدليل لا يحتاج تثبيت Flutter على جهازك. GitHub نفسه يبني APK و AAB ويضعهما جاهزين للتحميل.

---

## 1) إنشاء مستودع GitHub جديد

1. افتح https://github.com/new
2. اختر اسمًا (مثلاً `roshetta-ai`)
3. اتركه **Private** أو Public كما تفضّل — لا فرق على عمل الـ workflow
4. **لا** تُفعّل "Add a README file" أو ".gitignore" أو "license" من الخيارات الجاهزة (المشروع يحتوي ملفاته الخاصة بهذه الأمور فعلاً، وتفعيلها قد يتعارض)
5. اضغط "Create repository"

---

## 2) أي مجلدات/ملفات تُرفع

**ارفع المجلد الجذري كاملًا كما هو دون أي تعديل أو إعادة ترتيب** — فك ضغط الملف الذي استلمته، وستجد بداخله:

```
pharmacy-ai-assistant/
├── .github/workflows/mobile-build.yml   ← هذا ما يُشغّل البناء، يجب أن يبقى بهذا المسار تحديدًا
├── mobile/                               ← مشروع Flutter كاملًا، يجب أن يبقى بهذا الاسم تحديدًا
├── backend/
├── frontend/
├── database/
├── docs/
├── nginx/
├── docker-compose.yml
└── README.md
```

ارفع **كل المجلد بدون استثناء أي شيء**. لا تحتاج لاختيار ملفات بعينها — هذا أقل جهد ممكن، ويضمن بقاء
`.github/workflows/mobile-build.yml` و `mobile/` في مكانهما الصحيح تلقائيًا (الـ workflow يعتمد على هذا المسار
النسبي بالضبط).

### طريقة الرفع (الأسهل، بدون سطر أوامر Git)

1. في صفحة المستودع الجديد، اضغط "uploading an existing file"
2. اسحب **مجلد** `pharmacy-ai-assistant` بالكامل إلى المتصفح (المتصفحات الحديثة تدعم سحب مجلدات كاملة)
3. إن لم يدعم متصفحك سحب مجلد كامل: فك الضغط محليًا، ثم استخدم بدلاً من ذلك:

```bash
# يحتاج Git مثبّتًا فقط (لا يحتاج Flutter إطلاقًا)
cd pharmacy-ai-assistant
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<اسم_حسابك>/<اسم_المستودع>.git
git push -u origin main
```

---

## 3) تفعيل GitHub Actions

في أغلب الحالات **مُفعّل تلقائيًا** بمجرد وجود مجلد `.github/workflows/` في المستودع. تأكد فقط من:

1. اذهب لتبويب **Actions** في صفحة المستودع
2. إن ظهرت رسالة "Workflows aren't being run on this forked repository" (تظهر فقط لو كان المستودع Fork لا مستودعًا جديدًا) — اضغط "I understand my workflows, go ahead and enable them"
3. إن كان المستودع جديدًا (وليس Fork) فلن تحتاج لفعل أي شيء — أول push سيُشغّل الـ workflow تلقائيًا فورًا

---

## 4) الأسرار المطلوبة (GitHub Secrets)

### المطلوب فعليًا: **لا شيء**

البناء ينجح ويُنتج APK و AAB قابلين للتثبيت والتجربة **بدون أي Secret على الإطلاق** (يستخدم توقيع debug
تلقائيًا، ويعمل التطبيق بدون Firebase حقيقي).

### اختياري (فقط إن رغبت بنسخة جاهزة لمتجر Google Play لاحقًا)

اذهب إلى: صفحة المستودع → **Settings → Secrets and variables → Actions → New repository secret**

| الاسم | متى تحتاجه |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | لتوقيع إنتاج حقيقي بدلًا من debug (راجع `mobile/README.md` لإنشاء keystore) |
| `ANDROID_KEYSTORE_PASSWORD` | نفس السبب أعلاه |
| `ANDROID_KEY_ALIAS` | نفس السبب أعلاه |
| `ANDROID_KEY_PASSWORD` | نفس السبب أعلاه |
| `ANDROID_GOOGLE_SERVICES_JSON_BASE64` | فقط لتفعيل Firebase Push Notifications الحقيقية |

تخطّ هذا القسم بالكامل في أول تجربة — أضِفه فقط عندما تكون جاهزًا لرفع نسخة حقيقية لمتجر Play.

---

## 5) تشغيل الـ workflow

يعمل تلقائيًا، بدون أي ضغطة زر، في الحالات التالية:
- أي `git push` (لأي فرع — `branches: ["**"]`)
- أي Pull Request

لتشغيله يدويًا دون عمل push جديد:
1. تبويب **Actions**
2. من القائمة اليسرى اختر **"Mobile Build (APK & AAB)"**
3. اضغط **"Run workflow"** (زر على اليمين) → اختر الفرع → **"Run workflow"**

---

## 6) تحميل APK و AAB الناتجين

1. تبويب **Actions** → اضغط على آخر تشغيل ناجح (علامة ✅ خضراء) لـ "Mobile Build (APK & AAB)"
2. انتظر اكتمال كل الخطوات (يستغرق عادة 5–10 دقائق لأول تشغيل بسبب تحميل Flutter/Gradle، وأسرع بعدها بسبب التخزين المؤقت)
3. في أسفل صفحة التشغيل، قسم **"Artifacts"** يحتوي ملفين:
   - `roshetta-ai-release.apk`
   - `roshetta-ai-release.aab`
4. اضغط على أي منهما لتحميله — **ملاحظة مهمة**: GitHub يضغط كل Artifact في ملف `.zip` تلقائيًا، ففك الضغط
   بعد التحميل وستجد بداخله `app-release.apk` أو `app-release.aab` الفعلي

### إن رغبت أيضًا بإصدار GitHub Release رسمي مرفق به الملفان مباشرة (بدون .zip)

اعمل تاغ بصيغة `mobile-v` ثم رقم إصدار، مثل:
```bash
git tag mobile-v1.0.0
git push origin mobile-v1.0.0
```
سيظهر تلقائيًا في تبويب **Releases** بصفحة المستودع، مع رابط تحميل مباشر لـ `app-release.apk` و
`app-release.aab` دون الحاجة لفك أي ملف مضغوط.

---

## ✅ تأكيد: لا حاجة لأي تعديل في الكود قبل أول بناء

المشروع مُجهَّز بالكامل ليُبنى "كما هو":
- بدون `key.properties` → يوقّع تلقائيًا بمفتاح debug
- بدون `google-services.json` → يبني بدون Firebase (التطبيق يتعامل مع هذا بأمان دون توقف)
- بدون أي `--dart-define` → يستخدم قيمة افتراضية مدمجة في الكود لعنوان الـ API

أول push كافٍ تمامًا لإنتاج أول APK/AAB قابلين للتثبيت والتجربة.
