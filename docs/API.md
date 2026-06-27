# مرجع API — روشتة AI

> الوثائق التفاعلية الكاملة (Swagger UI) متاحة دائمًا على `GET /docs`، وOpenAPI JSON على `GET /openapi.json`،
> طالما أن الـ backend يعمل. هذا الملف خريطة سريعة بشرية للمسارات الرئيسية وقواعد الصلاحيات.

رمز الصلاحية المطلوب لكل مسار:
- 🌐 عام (لا يحتاج تسجيل دخول)
- 🔑 يحتاج تسجيل دخول (أي دور)
- 👤 Customer فقط
- 💊 Pharmacist أو Admin
- 🛡️ Admin فقط

## Auth — `/api/auth`
| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| POST | `/register` | 🌐 | تسجيل مستخدم جديد، يُرجع JWT |
| POST | `/login` | 🌐 | تسجيل الدخول، يُرجع JWT |
| GET | `/me` | 🔑 | بيانات المستخدم الحالي |
| POST | `/me/allergies` | 🔑 | إضافة حساسية معروفة |
| POST | `/me/chronic-conditions` | 🔑 | إضافة حالة مزمنة |

## Medications — `/api/medications`
| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| GET | `/search?q=` | 🌐 | بحث بالاسم العربي/الإنجليزي، يُرجع حالة التوفر والبدائل |
| GET | `/{id}` | 🌐 | تفاصيل دواء |
| POST | `` | 💊 | إضافة دواء جديد للكتالوج |

## Prescriptions — `/api/prescriptions`
| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| POST | `/upload` | 👤 | رفع صورة، يُشغّل OCR → AI → محرك السلامة في طلب واحد |
| GET | `/mine` | 👤 | وصفات المستخدم الحالي |
| GET | `/queue` | 💊 | قائمة الوصفات بانتظار المراجعة |
| GET | `/{id}` | 🔑 | تفاصيل وصفة (العميل يرى وصفته فقط) |
| PATCH | `/items/{item_id}` | 💊 | تعديل/تأكيد بند مستخرج |
| PATCH | `/{id}/review` | 💊 | قرار الصيدلاني النهائي (reviewed/rejected) — يرسل إشعارًا للعميل |

## Inventory — `/api/inventory`
| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| GET | `` | 💊 | كل دفعات المخزون |
| GET | `/low-stock` | 💊 | الدفعات تحت حد إعادة الطلب |
| POST | `/{medication_id}` | 💊 | إضافة دفعة مخزون |
| PATCH | `/{item_id}` | 💊 | تعديل دفعة |

## Alerts — `/api/alerts`
| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| GET | `?resolved=` | 💊 | قائمة التنبيهات |
| POST | `/scan` | 💊 | فحص فوري لمخزون منخفض/منتهي الصلاحية |
| POST | `/reminders-scan` | 💊 | تشغيل يدوي لمحرك التذكير (راجع reminder_engine.py) |
| PATCH | `/{id}/resolve` | 💊 | تعليم تنبيه كمحلول |

## Chat — `/api/chat`
| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| POST | `/send` | 🔑 | إرسال رسالة، يُرجع رد AI + علم التصعيد |
| GET | `/{session_id}/history` | 🔑 | سجل جلسة محادثة |

## Reports — `/api/reports`
| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| GET | `/sales-summary?days=` | 💊 | إيرادات، أكثر الأدوية طلبًا، مخزون منخفض/منتهي |

## Customer — `/api/customer`
| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| GET/POST | `/reminders` | 👤 | تذكيرات إعادة الشراء |
| DELETE | `/reminders/{id}` | 👤 | إلغاء تذكير |
| GET | `/loyalty` | 👤 | نقاط وفئة الولاء |

## Notifications — `/api/notifications`
| Method | Path | صلاحية | الوصف |
|---|---|---|---|
| GET | `/mine` | 🔑 | آخر 50 إشعارًا |
| GET | `/unread-count` | 🔑 | عدد الإشعارات غير المقروءة |
| PATCH | `/{id}/read` | 🔑 | تعليم إشعار كمقروء |

---

### مثال استخدام سريع (curl)

```bash
# تسجيل الدخول
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"customer@roshetta.ai","password":"Customer@12345"}' | python3 -c "import sys,json;print(json.load(sys.stdin)['access_token'])")

# بحث عن دواء
curl -s -G "http://localhost:8000/api/medications/search" --data-urlencode "q=بنادول" -H "Authorization: Bearer $TOKEN"

# رفع وصفة
curl -s -X POST http://localhost:8000/api/prescriptions/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@/path/to/prescription.jpg"
```
