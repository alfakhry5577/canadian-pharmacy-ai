from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel


class AlertOut(BaseModel):
    id: int
    type: str
    severity: str
    related_medication_id: int | None
    related_prescription_id: int | None
    customer_id: int | None
    message_ar: str
    is_resolved: bool
    created_at: datetime

    class Config:
        from_attributes = True


class TopMedicationStat(BaseModel):
    medication_id: int
    name_ar: str
    total_quantity_sold: int
    total_revenue: Decimal


class SalesSummary(BaseModel):
    period_label: str
    total_orders: int
    total_revenue: Decimal
    top_medications: list[TopMedicationStat]
    low_stock_count: int
    expiring_soon_count: int


class LoyaltyAccountOut(BaseModel):
    id: int
    customer_id: int
    points: int
    tier: str

    class Config:
        from_attributes = True


class ReminderOut(BaseModel):
    id: int
    medication_id: int
    frequency_days: int
    next_reminder_date: datetime
    is_active: bool

    class Config:
        from_attributes = True


class ReminderCreate(BaseModel):
    medication_id: int
    frequency_days: int = 30
