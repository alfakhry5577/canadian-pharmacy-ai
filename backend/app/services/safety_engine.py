"""
Drug Safety Engine
-------------------
Pure, deterministic, rule-based checks over already-matched medications.
This module NEVER calls the LLM and NEVER makes a treatment decision —
it only raises flags for a human (pharmacist) to review. This separation
keeps the safety-critical logic auditable and testable without any AI
non-determinism.
"""
from collections import Counter
from sqlalchemy.orm import Session

from app.models.medication import Medication, DrugInteraction
from app.models.user import User
from app.schemas.prescription import SafetyFlag


def check_duplicates(medications: list[Medication]) -> list[SafetyFlag]:
    flags = []
    ingredient_counts = Counter(
        m.active_ingredient_id for m in medications if m.active_ingredient_id is not None
    )
    for ingredient_id, count in ingredient_counts.items():
        if count > 1:
            names = [m.name_ar for m in medications if m.active_ingredient_id == ingredient_id]
            flags.append(SafetyFlag(
                type="duplicate_medication",
                severity="warning",
                message_ar=f"تم رصد أكثر من دواء بنفس المادة الفعالة في الوصفة: {', '.join(names)}. "
                           f"يرجى تأكيد عدم وجود ازدواجية قبل الصرف.",
            ))
    return flags


def check_interactions(db: Session, medications: list[Medication]) -> list[SafetyFlag]:
    flags = []
    ingredient_ids = [m.active_ingredient_id for m in medications if m.active_ingredient_id]
    if len(ingredient_ids) < 2:
        return flags

    interactions = db.query(DrugInteraction).filter(
        DrugInteraction.ingredient_a_id.in_(ingredient_ids),
        DrugInteraction.ingredient_b_id.in_(ingredient_ids),
    ).all()

    for interaction in interactions:
        flags.append(SafetyFlag(
            type="drug_interaction",
            severity=interaction.severity.value if hasattr(interaction.severity, "value") else str(interaction.severity),
            message_ar=interaction.description_ar,
        ))
    return flags


def check_allergies(medications: list[Medication], allergy_substances: list[str]) -> list[SafetyFlag]:
    flags = []
    if not allergy_substances:
        return flags
    allergy_set = {a.strip().lower() for a in allergy_substances}
    for med in medications:
        ingredient_name = (med.active_ingredient.name_en.lower() if med.active_ingredient else "")
        if ingredient_name and ingredient_name in allergy_set:
            flags.append(SafetyFlag(
                type="allergy",
                severity="critical",
                message_ar=f"تحذير: المستخدم لديه حساسية مسجّلة من '{med.active_ingredient.name_ar}' "
                           f"الموجودة في دواء {med.name_ar}. يجب مراجعة الصيدلاني فورًا قبل الصرف.",
            ))
    return flags


def check_special_population(medications: list[Medication], customer: User | None) -> list[SafetyFlag]:
    flags = []
    if customer is None:
        return flags

    age = customer.age()
    for med in medications:
        if customer.is_pregnant and med.pregnancy_warning:
            flags.append(SafetyFlag(
                type="special_population", severity="warning",
                message_ar=f"تحذير حمل لدواء {med.name_ar}: {med.pregnancy_warning}",
            ))
        if age is not None and age < 12 and med.pediatric_warning:
            flags.append(SafetyFlag(
                type="special_population", severity="warning",
                message_ar=f"تحذير للأطفال لدواء {med.name_ar}: {med.pediatric_warning}",
            ))
        if age is not None and age >= 65 and med.elderly_warning:
            flags.append(SafetyFlag(
                type="special_population", severity="warning",
                message_ar=f"تحذير لكبار السن لدواء {med.name_ar}: {med.elderly_warning}",
            ))
    return flags


def run_full_safety_check(
    db: Session,
    medications: list[Medication],
    customer: User | None = None,
) -> list[SafetyFlag]:
    """Runs every safety check and returns the combined list of flags."""
    allergy_substances = [a.substance_name for a in (customer.allergies if customer else [])]
    flags: list[SafetyFlag] = []
    flags += check_duplicates(medications)
    flags += check_interactions(db, medications)
    flags += check_allergies(medications, allergy_substances)
    flags += check_special_population(medications, customer)
    return flags
