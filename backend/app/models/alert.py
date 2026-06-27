import enum
from datetime import datetime

from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.medication import AlertSeverity


class AlertType(str, enum.Enum):
    low_stock = "low_stock"
    expiry = "expiry"
    duplicate_medication = "duplicate_medication"
    drug_interaction = "drug_interaction"
    allergy = "allergy"
    special_population = "special_population"  # pregnancy / pediatric / elderly


class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    type = Column(SAEnum(AlertType), nullable=False)
    severity = Column(SAEnum(AlertSeverity), default=AlertSeverity.info)

    related_medication_id = Column(Integer, ForeignKey("medications.id"), nullable=True)
    related_prescription_id = Column(Integer, ForeignKey("prescriptions.id"), nullable=True)
    customer_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    message_ar = Column(Text, nullable=False)
    is_resolved = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    medication = relationship("Medication")
