from datetime import datetime
from pydantic import BaseModel

from app.models.prescription import PrescriptionStatus


class PrescriptionItemOut(BaseModel):
    id: int
    extracted_medication_name: str
    matched_medication_id: int | None
    dosage_text: str | None
    frequency_text: str | None
    duration_text: str | None
    confidence_score: float
    pharmacist_confirmed: bool

    class Config:
        from_attributes = True


class PrescriptionItemUpdate(BaseModel):
    matched_medication_id: int | None = None
    dosage_text: str | None = None
    frequency_text: str | None = None
    duration_text: str | None = None
    pharmacist_confirmed: bool | None = None


class PrescriptionOut(BaseModel):
    id: int
    customer_id: int
    pharmacist_id: int | None
    image_path: str
    raw_ocr_text: str | None
    status: PrescriptionStatus
    pharmacist_notes: str | None
    created_at: datetime
    reviewed_at: datetime | None
    items: list[PrescriptionItemOut] = []

    class Config:
        from_attributes = True


class PrescriptionReviewUpdate(BaseModel):
    status: PrescriptionStatus
    pharmacist_notes: str | None = None


class SafetyFlag(BaseModel):
    type: str           # duplicate_medication | drug_interaction | allergy | special_population
    severity: str        # info | warning | critical
    message_ar: str


class PrescriptionAnalysisResult(BaseModel):
    """Returned right after OCR + AI extraction, before pharmacist review."""
    prescription: PrescriptionOut
    safety_flags: list[SafetyFlag] = []
    disclaimer_ar: str = (
        "هذا تحليل أولي بالذكاء الاصطناعي لمساعدتك على الفهم فقط، وهو غير نهائي ولا يحل محل "
        "مراجعة الصيدلاني المرخّص لوصفتك الأصلية قبل صرف أي دواء."
    )
