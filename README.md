# روشتة AI — Pharmacy AI Assistant

منصة ذكية تربط **الزبون** و **الصيدلاني**: رفع وتحليل الوصفات الطبية بالـ OCR والذكاء الاصطناعي، بحث ذكي عن
الأدوية والبدائل، محرك سلامة دوائي (تكرار/تعارض/حساسية/فئات خاصة)، إدارة مخزون وتنبيهات، تقارير مبيعات،
نظام ولاء، تذكير بإعادة الشراء، ودردشة AI آمنة — مع التزام صارم بعدم التشخيص أو تغيير الجرعات.

> **EN summary:** An AI-assisted pharmacy platform (FastAPI + PostgreSQL backend, Next.js 14 + TypeScript
> frontend) covering prescription OCR/AI analysis, drug search & substitutes, a deterministic drug-safety
> engine, inventory/alerts, sales reports, loyalty, reminders, and a guarded AI chat assistant. RTL Arabic UI
> with English-friendly architecture. See "Known Gaps & Future Work" below for an honest account of what is
> fully wired end-to-end versus what is a UI scaffold awaiting backend endpoints.

---

## لمحة سريعة عن حالة المشروع

| الطبقة | الحالة |
|---|---|
| Backend (FastAPI) | ✅ يعمل end-to-end، مُختبر بـ 14 اختبار pytest ناجح (auth, RBAC, بحث, OCR حقيقي, تحليل AI, محرك السلامة, مراجعة الصيدلاني, إشعارات) |
| قاعدة البيانات | ✅ PostgreSQL schema كامل (`database/schema.sql`) + SQLAlchemy models مطابقة |
| Frontend (Next.js 14) | ✅ يُبنى بنجاح (`npm run build`، 25 صفحة، فحص TypeScript كامل بدون أخطاء) |
| Docker / docker-compose / Nginx | ✅ ملفات جاهزة، تركيبتها صحيحة (YAML مُتحقق منه) |
| CI/CD (GitHub Actions) | ✅ pipeline لاختبار الـ backend وبناء الـ frontend + نشر صور Docker |
| تطبيق Flutter (Android) | ✅ مشروع كامل (شاشات/Riverpod/Dio/Firebase)، بناء APK/AAB تلقائي عبر GitHub Actions عند كل push — لم يُختبر محليًا بسبب قيود الشبكة في بيئة البناء (موضّح بصراحة في `mobile/README.md`) |
| شاشات الإدارة (مستخدمون / Audit Log / AI Monitoring / Settings) | ⚠️ واجهات جاهزة بجودة كاملة، لكنها **scaffolds** ببيانات توضيحية بانتظار endpoints مطابقة — مُعلَّم بوضوح داخل كل شاشة |

---

## المعمارية

```
                 ┌────────────┐        ┌──────────────────┐        ┌─────────────┐
   المستخدم  ──▶ │   Nginx    │ ──────▶│  Next.js Frontend │        │  PostgreSQL │
                 │ (reverse   │        │  (App Router,     │        └──────┬──────┘
                 │  proxy)    │        │   React Query,    │               │
                 │            │──────▶ │   Zustand, Axios) │        ┌──────▼──────┐
                 └────────────┘   API  └─────────┬─────────┘        │   FastAPI   │
                                       calls      │ axios            │   Backend   │
                                                   └─────────────────▶│             │
                                                                     │  OCR (Tesseract)
                                                                     │  AI (Claude API / mock)
                                                                     │  Safety Engine (rules)
                                                                     │  Notifications
                                                                     └─────────────┘
```

**فصل مهم بين الطبقتين:**
- **محرك السلامة الدوائي** (`backend/app/services/safety_engine.py`) قائم على قواعد محددة (deterministic) ولا
  يستدعي أي نموذج AI — يمكن اختباره واعتماده بثقة كاملة، وهذا متعمَّد لتقليل اعتماد القرارات الحساسة على نموذج
  احتمالي.
- **طبقة AI** (`backend/app/services/ai_service.py`) مسؤولة فقط عن: (أ) تحويل نص OCR الخام إلى بنود منظّمة،
  (ب) الدردشة العامة. كلتاهما محكومتان بـ `SAFETY_SYSTEM_PROMPT` صريح يمنع التشخيص وتغيير الجرعات، ويُحوِّل أي
  حالة غامضة أو خطيرة لمراجعة إنسان.

---

## بنية المشروع

```
pharmacy-ai-assistant/
├── backend/                # FastAPI app
│   ├── app/
│   │   ├── core/           # config, database, security (JWT), RBAC deps
│   │   ├── models/         # SQLAlchemy ORM models
│   │   ├── schemas/        # Pydantic request/response schemas
│   │   ├── api/routes/     # auth, medications, prescriptions, inventory, alerts, chat, reports, customer, notifications
│   │   ├── services/       # ocr_service, ai_service, safety_engine, recommendation_service, alert_service, notification_service, reminder_engine
│   │   └── db/seed_data.py
│   ├── tests/               # pytest — 14 passing tests
│   └── Dockerfile
├── frontend/                 # Next.js 14 App Router + TypeScript
│   ├── app/                  # routes only (login, register, customer/*, pharmacist/*, admin/*)
│   ├── components/ui/        # shadcn-style primitives (Radix-based)
│   ├── components/shared/    # Navbar, Footer, PageHeader, badges, NotificationBell...
│   ├── features/             # feature-scoped components (auth, search, prescriptions, chat, inventory, reports, reminders, loyalty)
│   ├── services/             # Axios calls grouped by domain
│   ├── hooks/                 # React Query hooks wrapping services
│   ├── store/                 # Zustand: auth store (persisted), UI/toast store
│   ├── lib/                    # axios client, cn(), formatters, constants/route map
│   ├── types/                  # shared TS types (mirrors backend schemas)
│   ├── providers/               # QueryProvider, AppProviders
│   ├── layouts/                  # DashboardLayout, AuthLayout, RoleGuard
│   └── Dockerfile
├── database/schema.sql
├── nginx/nginx.conf
├── docker-compose.yml
├── .github/workflows/ci.yml, docker-publish.yml
└── docs/API.md, DEPLOYMENT.md
```

---

## التشغيل محليًا (بدون Docker)

### Backend
```bash
cd backend
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env                 # عدّل القيم عند الحاجة
python -m app.db.seed_data           # بيانات تجريبية + 3 حسابات (انظر أدناه)
uvicorn app.main:app --reload        # http://localhost:8000  — وثائق تفاعلية على /docs
```

> لتفعيل OCR العربي محليًا: `sudo apt install tesseract-ocr tesseract-ocr-ara tesseract-ocr-eng`
> بدون مفتاح `ANTHROPIC_API_KEY`، تعمل خدمة الذكاء الاصطناعي في **وضع محاكاة (mock) واضح المعالم** —
> راجع `app/services/ai_service.py` — حتى يبقى المشروع قابلاً للتشغيل والاختبار دون أي حساب خارجي.

### Frontend
```bash
cd frontend
cp .env.local.example .env.local
npm install
npm run dev                           # http://localhost:3000
```

### حسابات تجريبية (من seed_data.py)
| الدور | البريد | كلمة المرور |
|---|---|---|
| Admin | admin@roshetta.ai | Admin@12345 |
| Pharmacist | pharmacist@roshetta.ai | Pharma@12345 |
| Customer | customer@roshetta.ai | Customer@12345 |

---

---

## تطبيق الموبايل (Flutter)

تطبيق Android كامل (Flutter + Riverpod + Dio + go_router + Firebase Messaging) يستخدم نفس الباك إند أعلاه
بدون أي تعديل عليه. التفاصيل الكاملة، تعليمات البناء، وتوليد APK/AAB تلقائيًا عبر GitHub Actions:
👉 [`mobile/README.md`](mobile/README.md)

---

## التشغيل عبر Docker Compose

```bash
cp .env.example .env                 # عدّل كلمات المرور والمفاتيح
docker compose up --build
# Nginx على http://localhost  (يوجّه / للفرونت إند، و /api و /uploads و /docs للباك إند)
```

تفاصيل الإنتاج الكاملة (TLS، النسخ الاحتياطي، الترحيلات) في [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).

---

## الاختبارات

```bash
cd backend && python -m pytest tests/ -v     # 14 اختبارًا — auth, RBAC, search, OCR حقيقي, AI mock, safety engine, notifications
cd frontend && npm run typecheck && npm run build   # فحص الأنواع + بناء إنتاجي كامل لـ 25 صفحة
```

كل الأرقام أعلاه (14 اختبارًا، 25 صفحة) تم التحقق منها فعليًا أثناء بناء هذا المشروع، وليست تقديرية.

---

## متغيرات البيئة (Backend `.env`)

| المتغير | الوصف |
|---|---|
| `DATABASE_URL` | اتصال قاعدة البيانات (SQLite افتراضيًا للتطوير، PostgreSQL للإنتاج) |
| `JWT_SECRET_KEY` | مفتاح توقيع JWT — **يجب تغييره في الإنتاج** |
| `ANTHROPIC_API_KEY` | اختياري — بدونه تعمل خدمة AI بوضع محاكاة محلي |
| `AI_MODEL` | اسم نموذج Claude المستخدم |
| `TESSERACT_LANGS` | لغات OCR، الافتراضي `ara+eng` |
| `ALLOWED_ORIGINS` | نطاقات CORS المسموحة |

(Frontend `.env.local`): `NEXT_PUBLIC_API_URL` فقط — رابط الـ backend.

---

## ملاحظات أمنية مهمة (يجب تطبيقها قبل الإنتاج الحقيقي)

1. **تسجيل ذاتي بدور admin/pharmacist**: حاليًا `POST /api/auth/register` يسمح باختيار أي دور بحرية — هذا
   مناسب للتجربة والتطوير فقط. في الإنتاج، يجب تقييد إنشاء حسابات admin/pharmacist لمسار محمي يديره admin فقط.
2. **تخزين صور الوصفات**: تُخزَّن حاليًا على القرص المحلي وتُعرض عبر static mount عام (`/uploads`). بيانات
   الوصفات الطبية حساسة — في الإنتاج استخدم تخزينًا خاصًا (S3/GCS) مع روابط مؤقتة موقَّعة (signed URLs) بدلاً
   من مسار عام.
3. **معدل الطلبات (Rate limiting)**: لا توجد حاليًا حماية rate-limiting على `/api/auth/login` أو `/api/chat/send`
   — أضِف `slowapi` أو حماية على مستوى Nginx قبل الإنتاج.
4. **الترحيلات (Migrations)**: الـ backend يستخدم `Base.metadata.create_all()` للتطوير السريع. في الإنتاج
   استخدم **Alembic** بدلاً من ذلك للتحكم بتطور الـ schema بأمان.
5. **JWT_SECRET_KEY و ANTHROPIC_API_KEY**: لا تُدرج أبدًا في صور Docker أو الواجهة الأمامية — فقط متغيرات بيئة
   على الخادم (كما هو مطبَّق حاليًا).

---

## الأعمال المستقبلية (Known Gaps — موضّحة بصراحة)

الميزات التالية لها **واجهة أمامية كاملة الجودة** ولكنها بحاجة لعمل Backend إضافي لتصبح حقيقية بالكامل:

- **إدارة المستخدمين (Admin)**: يحتاج `GET/PATCH/DELETE /api/admin/users`.
- **سجل التدقيق (Audit Log)**: يحتاج جدول `audit_logs` + middleware لتسجيل كل إجراء حساس.
- **مراقبة الذكاء الاصطناعي**: يحتاج تسجيل تحليلي لكل استدعاء AI (الزمن، نسبة التصعيد، التكلفة).
- **إعدادات النظام من الواجهة**: حاليًا الإعدادات تُضبط من `.env` فقط؛ يحتاج `GET/PATCH /api/admin/settings`.
- **دردشة AI بالبث الحقيقي (true token streaming)**: الحالي يُرجع ردًا كاملاً دفعة واحدة؛ الواجهة تُحاكي تأثير
  البث (typewriter) — للبث الحقيقي يلزم SSE أو WebSocket من جهة الـ backend.
- **مزودات SMS/Email حقيقية**: `notification_service.py` جاهز بواجهة Provider قابلة للتوصيل، ويعمل افتراضيًا
  بتسجيل (log) فقط — التفعيل الحقيقي يحتاج مفاتيح Twilio/SendGrid (أمثلة جاهزة في تعليقات الكود).
- **مهام مجدولة (Scheduler)**: فحص المخزون والتذكيرات حاليًا يُشغَّل يدويًا عبر endpoints (`/api/alerts/scan`,
  `/api/alerts/reminders-scan`) — للإنتاج، شغّلها عبر cron أو Celery beat مرة يوميًا.

---

## الترخيص

هذا مشروع توضيحي (starter / reference implementation) — راجعه وأضِف اختباراتك وسياساتك الأمنية الخاصة قبل
استخدامه في صيدلية حقيقية تتعامل مع بيانات مرضى فعلية.
