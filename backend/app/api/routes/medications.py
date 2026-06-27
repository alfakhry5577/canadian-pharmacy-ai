from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_pharmacist
from app.models.medication import Medication
from app.models.user import User
from app.schemas.medication import MedicationOut, MedicationSearchResult, MedicationCreate
from app.services.recommendation_service import is_in_stock, get_available_substitutes

router = APIRouter(prefix="/api/medications", tags=["medications"])


@router.get("/search", response_model=list[MedicationSearchResult])
def search_medications(
    q: str = Query(min_length=2, description="اسم الدواء أو المادة الفعالة (عربي أو إنجليزي)"),
    db: Session = Depends(get_db),
):
    like = f"%{q}%"
    medications = (
        db.query(Medication)
        .filter(
            Medication.is_active == True,  # noqa: E712
            or_(Medication.name_ar.ilike(like), Medication.name_en.ilike(like)),
        )
        .limit(30)
        .all()
    )

    results = []
    for med in medications:
        in_stock, qty = is_in_stock(med)
        substitutes = [] if in_stock else get_available_substitutes(db, med)
        results.append(MedicationSearchResult(
            medication=MedicationOut.model_validate(med),
            in_stock=in_stock,
            quantity_available=qty,
            substitutes=[MedicationOut.model_validate(s) for s in substitutes],
        ))
    return results


@router.get("/{medication_id}", response_model=MedicationOut)
def get_medication(medication_id: int, db: Session = Depends(get_db)):
    med = db.query(Medication).filter(Medication.id == medication_id).first()
    if not med:
        raise HTTPException(status_code=404, detail="الدواء غير موجود")
    return med


@router.post("", response_model=MedicationOut, status_code=201)
def create_medication(
    payload: MedicationCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_pharmacist),
):
    med = Medication(**payload.model_dump())
    db.add(med)
    db.commit()
    db.refresh(med)
    return med
