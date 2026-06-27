import enum
from datetime import datetime

from sqlalchemy import (
    Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Numeric, Enum as SAEnum
)
from sqlalchemy.orm import relationship

from app.core.database import Base


class PrescriptionStatus(str, enum.Enum):
    pending = "pending"        # uploaded, not yet analyzed
    analyzed = "analyzed"      # OCR + AI extraction done, awaiting pharmacist review
    reviewed = "reviewed"      # pharmacist confirmed / corrected the extraction
    dispensed = "dispensed"    # order fulfilled
    rejected = "rejected"      # pharmacist rejected (e.g. unreadable / invalid)


class Prescription(Base):
    __tablename__ = "prescriptions"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    pharmacist_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    image_path = Column(String(500), nullable=False)
    raw_ocr_text = Column(Text)
    status = Column(SAEnum(PrescriptionStatus), default=PrescriptionStatus.pending)
    pharmacist_notes = Column(Text)

    created_at = Column(DateTime, default=datetime.utcnow)
    reviewed_at = Column(DateTime, nullable=True)

    items = relationship("PrescriptionItem", back_populates="prescription", cascade="all, delete-orphan")


class PrescriptionItem(Base):
    __tablename__ = "prescription_items"

    id = Column(Integer, primary_key=True, index=True)
    prescription_id = Column(Integer, ForeignKey("prescriptions.id"), nullable=False)

    extracted_medication_name = Column(String(200), nullable=False)
    matched_medication_id = Column(Integer, ForeignKey("medications.id"), nullable=True)

    # Stored EXACTLY as read from the prescription — the system never edits these.
    dosage_text = Column(String(100))
    frequency_text = Column(String(100))
    duration_text = Column(String(100))

    confidence_score = Column(Numeric(4, 3), default=0)  # 0..1
    pharmacist_confirmed = Column(Boolean, default=False)

    prescription = relationship("Prescription", back_populates="items")
    matched_medication = relationship("Medication")
