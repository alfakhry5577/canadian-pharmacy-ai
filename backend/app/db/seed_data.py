"""
Seed Data
---------
Populates the database with a realistic demo dataset:
  - 3 demo users (admin / pharmacist / customer) with known passwords
  - active ingredients + medications (common ones, Arabic + English) with substitutes
  - inventory batches (including a deliberately low-stock + an expiring-soon item)
  - one known drug interaction pair, for the safety engine to demonstrate
  - related (non-prescription) cross-sell products

Run with:  python -m app.db.seed_data
"""
from datetime import date, datetime, timedelta

from app.core.database import Base, engine, SessionLocal
from app.core.security import hash_password
import app.models  # noqa: F401
from app.models.user import User, UserRole
from app.models.medication import ActiveIngredient, Medication, InventoryItem, DrugInteraction, RelatedProduct, AlertSeverity
from app.models.order import LoyaltyAccount


def run():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    if db.query(User).first():
        print("Database already has data — skipping seed.")
        db.close()
        return

    # ---------------- Users ----------------
    admin = User(
        full_name="مدير النظام", email="admin@roshetta.ai", phone="0900000001",
        password_hash=hash_password("Admin@12345"), role=UserRole.admin,
    )
    pharmacist = User(
        full_name="د. سارة الصيدلانية", email="pharmacist@roshetta.ai", phone="0900000002",
        password_hash=hash_password("Pharma@12345"), role=UserRole.pharmacist,
    )
    customer = User(
        full_name="أحمد الزبون", email="customer@roshetta.ai", phone="0900000003",
        password_hash=hash_password("Customer@12345"), role=UserRole.customer,
        date_of_birth=date(1990, 5, 1),
    )
    db.add_all([admin, pharmacist, customer])
    db.commit()

    db.add(LoyaltyAccount(customer_id=customer.id, points=120, tier="bronze"))

    # ---------------- Active ingredients ----------------
    paracetamol = ActiveIngredient(name_en="Paracetamol", name_ar="باراسيتامول")
    ibuprofen = ActiveIngredient(name_en="Ibuprofen", name_ar="إيبوبروفين")
    amoxicillin = ActiveIngredient(name_en="Amoxicillin", name_ar="أموكسيسيلين")
    warfarin = ActiveIngredient(name_en="Warfarin", name_ar="وارفارين")
    aspirin = ActiveIngredient(name_en="Aspirin", name_ar="أسبرين")
    cetirizine = ActiveIngredient(name_en="Cetirizine", name_ar="سيتيريزين")
    db.add_all([paracetamol, ibuprofen, amoxicillin, warfarin, aspirin, cetirizine])
    db.commit()

    # ---------------- Medications ----------------
    panadol = Medication(
        name_en="Panadol 500mg", name_ar="بنادول 500 ملغ", active_ingredient_id=paracetamol.id,
        dosage_form="tablet", strength="500mg", manufacturer="GSK", requires_prescription=False,
        price=3.50,
        general_usage="يستخدم عمومًا لتسكين الألم الخفيف إلى المتوسط وخفض الحرارة.",
        general_warnings="تجاوز الجرعة القصوى اليومية قد يضر بالكبد. لا يستخدم مع أدوية أخرى تحتوي باراسيتامول.",
        elderly_warning="يفضل تقليل الجرعة القصوى اليومية لدى كبار السن الذين لديهم قصور كبدي.",
    )
    adol = Medication(
        name_en="Adol 500mg", name_ar="أدول 500 ملغ", active_ingredient_id=paracetamol.id,
        dosage_form="tablet", strength="500mg", manufacturer="Local Pharma", requires_prescription=False,
        price=2.00,
        general_usage="بديل لخفض الحرارة وتسكين الألم الخفيف، نفس المادة الفعالة (باراسيتامول).",
    )
    brufen = Medication(
        name_en="Brufen 400mg", name_ar="بروفين 400 ملغ", active_ingredient_id=ibuprofen.id,
        dosage_form="tablet", strength="400mg", manufacturer="Abbott", requires_prescription=False,
        price=4.00,
        general_usage="مضاد التهاب غير ستيرويدي يستخدم للألم والالتهاب.",
        general_warnings="قد يسبب تهيّجًا في المعدة. يُحذر استخدامه مع مضادات التخثر دون مراجعة الصيدلاني.",
        pregnancy_warning="يُنصح بعدم استخدامه في الثلث الثالث من الحمل إلا بتوجيه طبي.",
    )
    augmentin = Medication(
        name_en="Augmentin 625mg", name_ar="أوغمنتين 625 ملغ", active_ingredient_id=amoxicillin.id,
        dosage_form="tablet", strength="625mg", manufacturer="GSK", requires_prescription=True,
        price=12.00,
        general_usage="مضاد حيوي واسع المدى، يصرف فقط بوصفة طبية.",
        general_warnings="يجب إتمام مدة العلاج الكاملة حتى مع تحسن الأعراض.",
    )
    amoxil = Medication(
        name_en="Amoxil 500mg", name_ar="أموكسيل 500 ملغ", active_ingredient_id=amoxicillin.id,
        dosage_form="capsule", strength="500mg", manufacturer="Local Pharma", requires_prescription=True,
        price=9.00,
        general_usage="مضاد حيوي بديل بنفس المادة الفعالة لأوغمنتين (يحتاج تأكيد الصيدلاني).",
    )
    warfarin_med = Medication(
        name_en="Coumadin 5mg", name_ar="كومادين 5 ملغ", active_ingredient_id=warfarin.id,
        dosage_form="tablet", strength="5mg", manufacturer="Bristol", requires_prescription=True,
        price=15.00,
        general_usage="مضاد تخثر يصرف فقط بوصفة طبية ويتطلب متابعة دورية.",
        elderly_warning="يتطلب متابعة دقيقة للجرعة لدى كبار السن لخطر النزيف.",
    )
    aspirin_med = Medication(
        name_en="Aspocid 100mg", name_ar="أسبوسيد 100 ملغ", active_ingredient_id=aspirin.id,
        dosage_form="tablet", strength="100mg", manufacturer="Bayer", requires_prescription=False,
        price=2.50,
        general_usage="يستخدم بجرعات منخفضة للوقاية القلبية حسب توجيه الطبيب.",
    )
    zyrtec = Medication(
        name_en="Zyrtec 10mg", name_ar="زيرتك 10 ملغ", active_ingredient_id=cetirizine.id,
        dosage_form="tablet", strength="10mg", manufacturer="UCB", requires_prescription=False,
        price=6.00,
        general_usage="مضاد هيستامين لأعراض الحساسية مثل العطاس وحكة العين.",
        pediatric_warning="يحتاج تعديل الجرعة لدى الأطفال تحت 6 سنوات — يرجى مراجعة الصيدلاني.",
    )

    meds = [panadol, adol, brufen, augmentin, amoxil, warfarin_med, aspirin_med, zyrtec]
    db.add_all(meds)
    db.commit()

    # ---------------- Substitutes ----------------
    panadol.substitutes.append(adol)
    adol.substitutes.append(panadol)
    augmentin.substitutes.append(amoxil)
    amoxil.substitutes.append(augmentin)
    db.commit()

    # ---------------- Drug interaction (for the safety engine demo) ----------------
    db.add(DrugInteraction(
        ingredient_a_id=warfarin.id,
        ingredient_b_id=aspirin.id,
        severity=AlertSeverity.critical,
        description_ar="تحذير تعارض دوائي: الجمع بين الوارفارين والأسبرين يزيد بشكل كبير من خطر النزيف. "
                        "يجب مراجعة الطبيب أو الصيدلاني قبل الاستخدام المشترك.",
    ))
    db.add(DrugInteraction(
        ingredient_a_id=warfarin.id,
        ingredient_b_id=ibuprofen.id,
        severity=AlertSeverity.warning,
        description_ar="قد يزيد الإيبوبروفين من خطر النزيف عند استخدامه مع الوارفارين. يُفضل تجنب الجمع بدون توجيه طبي.",
    ))
    db.commit()

    # ---------------- Inventory ----------------
    today = datetime.utcnow()
    db.add_all([
        InventoryItem(medication_id=panadol.id, quantity=300, reorder_threshold=50, batch_no="P-001", expiry_date=today + timedelta(days=400)),
        InventoryItem(medication_id=adol.id, quantity=8, reorder_threshold=20, batch_no="A-001", expiry_date=today + timedelta(days=200)),   # low stock
        InventoryItem(medication_id=brufen.id, quantity=120, reorder_threshold=30, batch_no="B-001", expiry_date=today + timedelta(days=45)), # expiring soon
        InventoryItem(medication_id=augmentin.id, quantity=0, reorder_threshold=15, batch_no="AU-001", expiry_date=today + timedelta(days=300)), # out of stock -> triggers substitute suggestion
        InventoryItem(medication_id=amoxil.id, quantity=60, reorder_threshold=15, batch_no="AM-001", expiry_date=today + timedelta(days=300)),
        InventoryItem(medication_id=warfarin_med.id, quantity=40, reorder_threshold=10, batch_no="W-001", expiry_date=today + timedelta(days=500)),
        InventoryItem(medication_id=aspirin_med.id, quantity=200, reorder_threshold=30, batch_no="AS-001", expiry_date=today + timedelta(days=500)),
        InventoryItem(medication_id=zyrtec.id, quantity=75, reorder_threshold=20, batch_no="Z-001", expiry_date=today + timedelta(days=400)),
    ])

    # ---------------- Related (cross-sell, non-prescription) products ----------------
    db.add_all([
        RelatedProduct(
            active_ingredient_id=paracetamol.id, product_name_ar="فيتامين سي فوار 1000mg",
            product_name_en="Vitamin C Effervescent 1000mg", category="supplement", price=8.0,
            note_ar="مكمل غذائي مسموح، يقترح عند شراء أدوية البرد لدعم المناعة.",
        ),
        RelatedProduct(
            active_ingredient_id=ibuprofen.id, product_name_ar="جل تبريد موضعي للألم",
            product_name_en="Cooling Pain Relief Gel", category="device", price=10.0,
            note_ar="منتج موضعي غير دوائي يكمّل تسكين الألم.",
        ),
        RelatedProduct(
            active_ingredient_id=cetirizine.id, product_name_ar="بخاخ أنف لمياه البحر",
            product_name_en="Saline Nasal Spray", category="hygiene", price=6.0,
            note_ar="منتج مساعد آمن لأعراض الحساسية الأنفية.",
        ),
    ])

    db.commit()
    db.close()
    print("Seed complete:")
    print("  Admin login:      admin@roshetta.ai / Admin@12345")
    print("  Pharmacist login: pharmacist@roshetta.ai / Pharma@12345")
    print("  Customer login:   customer@roshetta.ai / Customer@12345")


if __name__ == "__main__":
    run()
