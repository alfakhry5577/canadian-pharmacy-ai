from datetime import date

from app.models.user import User, UserRole, CustomerAllergy
from app.models.medication import ActiveIngredient, Medication, DrugInteraction, AlertSeverity
from app.services import safety_engine


def _ingredient(db, name_en, name_ar):
    ing = ActiveIngredient(name_en=name_en, name_ar=name_ar)
    db.add(ing)
    db.commit()
    db.refresh(ing)
    return ing


def _medication(db, name_en, name_ar, ingredient, **kwargs):
    med = Medication(name_en=name_en, name_ar=name_ar, active_ingredient_id=ingredient.id, price=1, **kwargs)
    db.add(med)
    db.commit()
    db.refresh(med)
    return med


def test_detects_duplicate_active_ingredient(db_session):
    paracetamol = _ingredient(db_session, "Paracetamol", "باراسيتامول")
    panadol = _medication(db_session, "Panadol", "بنادول", paracetamol)
    adol = _medication(db_session, "Adol", "أدول", paracetamol)

    flags = safety_engine.check_duplicates([panadol, adol])
    assert len(flags) == 1
    assert flags[0].type == "duplicate_medication"


def test_detects_known_drug_interaction(db_session):
    warfarin = _ingredient(db_session, "Warfarin", "وارفارين")
    aspirin = _ingredient(db_session, "Aspirin", "أسبرين")
    db_session.add(DrugInteraction(
        ingredient_a_id=warfarin.id, ingredient_b_id=aspirin.id,
        severity=AlertSeverity.critical, description_ar="تعارض خطير",
    ))
    db_session.commit()

    med_a = _medication(db_session, "Coumadin", "كومادين", warfarin)
    med_b = _medication(db_session, "Aspocid", "أسبوسيد", aspirin)

    flags = safety_engine.check_interactions(db_session, [med_a, med_b])
    assert len(flags) == 1
    assert flags[0].severity == "critical"


def test_detects_allergy_conflict():
    ibu = ActiveIngredient(name_en="Ibuprofen", name_ar="إيبوبروفين")
    med = Medication(name_en="Brufen", name_ar="بروفين", active_ingredient=ibu, price=1)
    flags = safety_engine.check_allergies([med], ["ibuprofen"])
    assert len(flags) == 1
    assert flags[0].type == "allergy"
    assert flags[0].severity == "critical"


def test_pregnancy_warning_surfaced():
    customer = User(
        full_name="Test", email="p@example.com", password_hash="x",
        role=UserRole.customer, is_pregnant=True,
    )
    med = Medication(name_en="Brufen", name_ar="بروفين", price=1, pregnancy_warning="يُنصح بالحذر أثناء الحمل")
    flags = safety_engine.check_special_population([med], customer)
    assert len(flags) == 1
    assert "حمل" in flags[0].message_ar
