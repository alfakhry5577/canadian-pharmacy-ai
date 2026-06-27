# Static Audit Scripts

أدوات Python بديلة عن `flutter analyze` (للاستخدام فقط في بيئات بلا وصول لـ Flutter SDK). تُشغَّل بالترتيب:

```bash
cd mobile
python3 scripts/static_audit/1_extract_imports.py   # يبني فهرسًا في /tmp أو مجلد مؤقت — عدّل المسارات إن لزم
python3 scripts/static_audit/2_check_imports.py
python3 scripts/static_audit/3_deep_checks.py
python3 scripts/static_audit/4_constructor_arity_check.py
python3 scripts/static_audit/5_firebase_checks.py
python3 scripts/static_audit/6_final_checks.py
python3 scripts/static_audit/7_unused_imports_check.py
```

**ملاحظة مهمة**: هذه الأدوات تحليل بنيوي/heuristic بـ regex، **ليست بديلاً عن `flutter analyze` الحقيقي**.
راجع `BUILD_READINESS_REPORT.md` في جذر `mobile/` لمعرفة حدودها الدقيقة والنتائج الكاملة، بما فيها الحالات
التي أعطت نتائج كاذبة (false positives) من هذه الأدوات نفسها وكيف تم تمييزها.

القيمة الحقيقية لهذه الأدوات: فحص سريع لمشاكل بنيوية (imports مفقودة، providers غير معرّفة، عدم تطابق
معاملات Constructor، تناقض إعدادات Android) **قبل** تشغيل `flutter build` الأبطأ والأثقل — مفيدة كخطوة أولى في
CI مستقبلًا، لا كبديل لها.

تأكد من تعديل المسار `ROOT = "/home/claude/pharmacy-ai-assistant/mobile"` في رأس كل سكربت إلى مسار مشروعك
الفعلي قبل إعادة التشغيل محليًا.
