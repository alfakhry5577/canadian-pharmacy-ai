import os
import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.config import get_settings
from app.core.deps import get_current_user, require_pharmacist
from app.models.user import User
from app.models.medication import Medication
from app.models.prescription import Prescription, PrescriptionItem, PrescriptionStatus
from app.models.alert import AlertType
from app.models.medication import AlertSeverity
from app.schemas.prescription import (
    PrescriptionOut, PrescriptionAnalysisResult, PrescriptionReviewUpdate, PrescriptionItemUpdate,
)
from app.services import ocr_service, ai_service, safety_engine, alert_service
from app.services.notification_service import get_notification_service, create_in_app_notification

router = APIRouter(prefix="/api/prescriptions", tags=["prescriptions"])
settings = get_settings()


def _match_medication(db: Session, extracted_name: str) -> Medication | None:
    """Best-effort fuzzy match of an OCR-extracted name against the catalog."""
    like = f"%{extracted_name.strip()}%"
    return (
        db.query(Medication)
        .filter(
            Medication.is_active == True,  # noqa: E712
            (Medication.name_ar.ilike(like)) | (Medication.name_en.ilike(like)),
        )
        .first()
    )


@router.post("/upload", response_model=PrescriptionAnalysisResult, status_code=201)
def upload_prescription(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    ext = os.path.splitext(file.filename or "")[1] or ".jpg"
    filename = f"{uuid.uuid4().hex}{ext}"
    saved_path = os.path.join(settings.UPLOAD_DIR, filename)

    with open(saved_path, "wb") as f:
        f.write(file.file.read())

    prescription = Prescription(
        customer_id=current_user.id,
        image_path=saved_path,
        status=PrescriptionStatus.pending,
    )
    db.add(prescription)
    db.commit()
    db.refresh(prescription)

    # 1) OCR
    raw_text = ocr_service.extract_text(saved_path)
    prescription.raw_ocr_text = raw_text

    # 2) AI structuring (never invents values — see ai_service.SAFETY_SYSTEM_PROMPT)
    extracted_items = ai_service.structure_prescription_text(raw_text)

    matched_medications: list[Medication] = []
    for item in extracted_items:
        matched = _match_medication(db, item.extracted_medication_name)
        if matched:
            matched_medications.append(matched)
        db.add(PrescriptionItem(
            prescription_id=prescription.id,
            extracted_medication_name=item.extracted_medication_name,
            matched_medication_id=matched.id if matched else None,
            dosage_text=item.dosage_text,
            frequency_text=item.frequency_text,
            duration_text=item.duration_text,
            confidence_score=item.confidence_score,
        ))

    prescription.status = PrescriptionStatus.analyzed
    db.commit()
    db.refresh(prescription)

    # 3) Deterministic safety checks (separate from the AI step, see safety_engine)
    safety_flags = safety_engine.run_full_safety_check(db, matched_medications, current_user)

    for flag in safety_flags:
        alert_service.create_alert(
            db,
            type_=AlertType(flag.type),
            message_ar=flag.message_ar,
            severity=AlertSeverity(flag.severity),
            related_prescription_id=prescription.id,
            customer_id=current_user.id,
        )

    return PrescriptionAnalysisResult(
        prescription=PrescriptionOut.model_validate(prescription),
        safety_flags=safety_flags,
    )


@router.get("/mine", response_model=list[PrescriptionOut])
def my_prescriptions(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return (
        db.query(Prescription)
        .filter(Prescription.customer_id == current_user.id)
        .order_by(Prescription.created_at.desc())
        .all()
    )


@router.get("/queue", response_model=list[PrescriptionOut])
def review_queue(db: Session = Depends(get_db), _: User = Depends(require_pharmacist)):
    """Prescriptions waiting for pharmacist review, oldest first."""
    return (
        db.query(Prescription)
        .filter(Prescription.status == PrescriptionStatus.analyzed)
        .order_by(Prescription.created_at.asc())
        .all()
    )


@router.get("/{prescription_id}", response_model=PrescriptionOut)
def get_prescription(prescription_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    prescription = db.query(Prescription).filter(Prescription.id == prescription_id).first()
    if not prescription:
        raise HTTPException(status_code=404, detail="الوصفة غير موجودة")
    if current_user.role.value == "customer" and prescription.customer_id != current_user.id:
        raise HTTPException(status_code=403, detail="لا يمكنك الوصول لهذه الوصفة")
    return prescription


@router.patch("/items/{item_id}", response_model=PrescriptionOut)
def update_prescription_item(
    item_id: int,
    payload: PrescriptionItemUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_pharmacist),
):
    """Pharmacist corrects/confirms an AI-extracted item — human has final say."""
    item = db.query(PrescriptionItem).filter(PrescriptionItem.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="بند الوصفة غير موجود")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(item, field, value)
    db.commit()
    return db.query(Prescription).filter(Prescription.id == item.prescription_id).first()


@router.patch("/{prescription_id}/review", response_model=PrescriptionOut)
def review_prescription(
    prescription_id: int,
    payload: PrescriptionReviewUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_pharmacist),
):
    prescription = db.query(Prescription).filter(Prescription.id == prescription_id).first()
    if not prescription:
        raise HTTPException(status_code=404, detail="الوصفة غير موجودة")

    prescription.status = payload.status
    prescription.pharmacist_notes = payload.pharmacist_notes
    prescription.pharmacist_id = current_user.id
    prescription.reviewed_at = datetime.utcnow()
    db.commit()
    db.refresh(prescription)

    customer = db.query(User).filter(User.id == prescription.customer_id).first()
    if customer:
        status_label = "تمت الموافقة على" if payload.status == PrescriptionStatus.reviewed else "تم رفض"
        notifier = get_notification_service()
        message = f"{status_label} وصفتك الطبية رقم #{prescription.id}."
        if payload.pharmacist_notes:
            message += f" ملاحظة الصيدلاني: {payload.pharmacist_notes}"
        notifier.notify_in_app(customer.id, "تحديث حالة الوصفة", message)
        create_in_app_notification(db, customer.id, "تحديث حالة الوصفة", message)
        notifier.notify_email(customer.email, "تحديث حالة الوصفة", message)

    return prescription
