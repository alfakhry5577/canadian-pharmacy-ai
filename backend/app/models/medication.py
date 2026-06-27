import enum
from datetime import datetime

from sqlalchemy import (
    Column, Integer, String, Boolean, DateTime, Numeric, Text, ForeignKey, Table, Enum as SAEnum
)
from sqlalchemy.orm import relationship

from app.core.database import Base


class AlertSeverity(str, enum.Enum):
    info = "info"
    warning = "warning"
    critical = "critical"


class ActiveIngredient(Base):
    __tablename__ = "active_ingredients"

    id = Column(Integer, primary_key=True, index=True)
    name_en = Column(String(150), nullable=False, unique=True)
    name_ar = Column(String(150), nullable=False)

    medications = relationship("Medication", back_populates="active_ingredient")


# Self-referential many-to-many for medication substitutes
medication_substitutes = Table(
    "medication_substitutes",
    Base.metadata,
    Column("medication_id", Integer, ForeignKey("medications.id"), primary_key=True),
    Column("substitute_medication_id", Integer, ForeignKey("medications.id"), primary_key=True),
)


class Medication(Base):
    __tablename__ = "medications"

    id = Column(Integer, primary_key=True, index=True)
    name_en = Column(String(200), nullable=False, index=True)
    name_ar = Column(String(200), nullable=False, index=True)
    active_ingredient_id = Column(Integer, ForeignKey("active_ingredients.id"))
    dosage_form = Column(String(50))
    strength = Column(String(50))
    manufacturer = Column(String(150))
    requires_prescription = Column(Boolean, default=True)
    price = Column(Numeric(10, 2), nullable=False, default=0)

    # Informational-only fields — never used to auto-prescribe or auto-dose.
    general_usage = Column(Text)
    general_warnings = Column(Text)
    pregnancy_warning = Column(Text)
    pediatric_warning = Column(Text)
    elderly_warning = Column(Text)

    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    active_ingredient = relationship("ActiveIngredient", back_populates="medications")
    inventory_items = relationship("InventoryItem", back_populates="medication", cascade="all, delete-orphan")

    substitutes = relationship(
        "Medication",
        secondary=medication_substitutes,
        primaryjoin=id == medication_substitutes.c.medication_id,
        secondaryjoin=id == medication_substitutes.c.substitute_medication_id,
    )


class DrugInteraction(Base):
    __tablename__ = "drug_interactions"

    id = Column(Integer, primary_key=True, index=True)
    ingredient_a_id = Column(Integer, ForeignKey("active_ingredients.id"), nullable=False)
    ingredient_b_id = Column(Integer, ForeignKey("active_ingredients.id"), nullable=False)
    severity = Column(SAEnum(AlertSeverity), default=AlertSeverity.warning)
    description_ar = Column(Text, nullable=False)

    ingredient_a = relationship("ActiveIngredient", foreign_keys=[ingredient_a_id])
    ingredient_b = relationship("ActiveIngredient", foreign_keys=[ingredient_b_id])


class RelatedProduct(Base):
    """Non-medical / allowed supplementary products suggested alongside a medication."""
    __tablename__ = "related_products"

    id = Column(Integer, primary_key=True, index=True)
    active_ingredient_id = Column(Integer, ForeignKey("active_ingredients.id"))
    product_name_ar = Column(String(200), nullable=False)
    product_name_en = Column(String(200))
    category = Column(String(100))
    price = Column(Numeric(10, 2), default=0)
    note_ar = Column(Text)


class InventoryItem(Base):
    __tablename__ = "inventory"

    id = Column(Integer, primary_key=True, index=True)
    medication_id = Column(Integer, ForeignKey("medications.id"), nullable=False)
    quantity = Column(Integer, nullable=False, default=0)
    reorder_threshold = Column(Integer, nullable=False, default=10)
    batch_no = Column(String(80))
    expiry_date = Column(DateTime, nullable=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    medication = relationship("Medication", back_populates="inventory_items")

    @property
    def is_low_stock(self) -> bool:
        return self.quantity <= self.reorder_threshold
