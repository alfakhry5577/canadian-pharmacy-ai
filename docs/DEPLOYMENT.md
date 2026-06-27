# دليل النشر للإنتاج

هذا الدليل يفترض خادمًا واحدًا (VM) لتشغيل docker-compose. لمقياس أكبر (Kubernetes، قواعد بيانات مُدارة)
المبادئ نفسها تنطبق مع فروقات في طبقة البنية التحتية فقط.

## 1) المتطلبات الأساسية
- خادم Linux (Ubuntu 22.04+ مثلاً) مع Docker + Docker Compose v2.
- دومين يشير إلى IP الخادم (لـ TLS).
- مفتاح `ANTHROPIC_API_KEY` إن رغبت بتفعيل الذكاء الاصطناعي الحقيقي (اختياري — المشروع يعمل بوضع محاكاة بدونه).

## 2) إعداد متغيرات البيئة
```bash
git clone <repo-url> && cd pharmacy-ai-assistant
cp .env.example .env
```
عدّل في `.env`:
- `POSTGRES_PASSWORD` — كلمة مرور قوية وفريدة.
- `JWT_SECRET_KEY` — أنشئ مفتاحًا عشوائيًا طويلاً: `openssl rand -hex 32`.
- `ANTHROPIC_API_KEY` — إن توفر.
- `NEXT_PUBLIC_API_URL` — اضبطه على عنوان الدومين العام (مثل `https://api.yourdomain.com` إذا فصلت
  الـ backend عن نفس الدومين، أو اتركه يشير لمسار `/api` النسبي عبر Nginx إن استخدمت دومينًا واحدًا).

## 3) التشغيل
```bash
docker compose up --build -d
docker compose exec backend python -m app.db.seed_data   # بيانات تجريبية أولية (اختياري، احذفه في إنتاج حقيقي)
```

## 4) TLS / HTTPS
أسهل طريقة: ضع Nginx الحالي خلف Caddy أو certbot، أو استبدل `nginx/nginx.conf` بإعداد يتضمن:
```nginx
listen 443 ssl;
ssl_certificate     /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
```
واستخدم `certbot --nginx` (بعد تثبيت certbot على الخادم، خارج الحاوية) لإصدار الشهادة وتجديدها تلقائيًا.

## 5) قاعدة البيانات والترحيلات
هذا المشروع يستخدم `Base.metadata.create_all()` لإنشاء الجداول تلقائيًا عند أول تشغيل — مناسب للتجربة
والنشر الأولي. **قبل أي تعديل لاحق على الـ schema في بيئة فيها بيانات حقيقية**:
1. أضف Alembic: `pip install alembic && alembic init alembic`.
2. ولّد أول ترحيل من النماذج الحالية: `alembic revision --autogenerate -m "init"`.
3. منذ تلك اللحظة، كل تغيير في `app/models/*` يجب أن يصاحبه ترحيل Alembic جديد بدلاً من الاعتماد على
   `create_all()`.

## 6) النسخ الاحتياطي
```bash
# نسخة احتياطية يومية لقاعدة البيانات (أضفها لـ cron)
docker compose exec -T db pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > backup_$(date +%F).sql.gz

# نسخ مجلد صور الوصفات (أو انتقل لتخزين S3 كما هو موصى به في README)
docker compose exec -T backend tar czf - /app/uploads > uploads_backup_$(date +%F).tar.gz
```

## 7) المهام المجدولة (Cron)
أضف على الخادم (خارج الحاوية) أو كحاوية منفصلة بسيطة:
```cron
0 8 * * * curl -s -X POST https://yourdomain.com/api/alerts/scan -H "Authorization: Bearer $PHARMACIST_TOKEN"
0 9 * * * curl -s -X POST https://yourdomain.com/api/alerts/reminders-scan -H "Authorization: Bearer $PHARMACIST_TOKEN"
```
(الأفضل لاحقًا: استبدالها بـ Celery beat أو APScheduler داخل الـ backend نفسه دون الاعتماد على توكن طويل الأمد.)

## 8) المراقبة (Monitoring)
- `GET /health` على الـ backend مناسب لفحوصات health check لأي أداة (Uptime Kuma، Kubernetes liveness probe، إلخ).
- صورة الـ backend تتضمن `HEALTHCHECK` مدمجة في Dockerfile.
- وصّل سجلات الحاويات (`docker compose logs -f`) بأداة تجميع سجلات (Loki/CloudWatch/إلخ) في إنتاج حقيقي.

## 9) قائمة تحقق قبل الذهاب للإنتاج الحقيقي
راجع قسم **"ملاحظات أمنية مهمة"** و **"الأعمال المستقبلية"** في `README.md` الجذري — تحديدًا:
تقييد تسجيل admin/pharmacist، نقل تخزين الصور لـ S3 بروابط موقّعة، إضافة rate limiting، واعتماد Alembic.
