from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel


class ActiveIngredientOut(BaseModel):
    id: int
    name_en: str
    name_ar: str

    class Config:
        from_attributes = True


class MedicationOut(BaseModel):
    id: int
    name_en: str
    name_ar: str
    dosage_form: str | None
    strength: str | None
    manufacturer: str | None
    requires_prescription: bool
    price: Decimal
    general_usage: str | None
    general_warnings: str | None
    pregnancy_warning: str | None
    pediatric_warning: str | None
    elderly_warning: str | None
    active_ingredient: ActiveIngredientOut | None = None

    class Config:
        from_attributes = True


class MedicationSearchResult(BaseModel):
    medication: MedicationOut
    in_stock: bool
    quantity_available: int
    substitutes: list[MedicationOut] = []


class MedicationCreate(BaseModel):
    name_en: str
    name_ar: str
    active_ingredient_id: int | None = None
    dosage_form: str | None = None
    strength: str | None = None
    manufacturer: str | None = None
    requires_prescription: bool = True
    price: Decimal = Decimal("0")
    general_usage: str | None = None
    general_warnings: str | None = None
    pregnancy_warning: str | None = None
    pediatric_warning: str | None = None
    elderly_warning: str | None = None


class InventoryItemOut(BaseModel):
    id: int
    medication_id: int
    quantity: int
    reorder_threshold: int
    batch_no: str | None
    expiry_date: datetime | None
    is_low_stock: bool

    class Config:
        from_attributes = True


class InventoryUpdate(BaseModel):
    quantity: int | None = None
    reorder_threshold: int | None = None
    batch_no: str | None = None
    expiry_date: datetime | None = None
