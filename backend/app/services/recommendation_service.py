"""
Recommendation Service
-----------------------
Business-value features that stay strictly within safe bounds:
- suggest in-stock substitutes when a medication is unavailable
- suggest ALLOWED non-prescription related products (never prescription items)
- compute refill due-dates for chronic medication reminders
"""
from datetime import date, timedelta
from sqlalchemy.orm import Session

from app.models.medication import Medication, RelatedProduct


def get_available_substitutes(db: Session, medication: Medication) -> list[Medication]:
    """Returns substitutes for `medication` that currently have stock > 0."""
    candidates = medication.substitutes
    available = []
    for candidate in candidates:
        total_qty = sum(item.quantity for item in candidate.inventory_items)
        if total_qty > 0:
            available.append(candidate)
    return available


def get_related_products(db: Session, medication: Medication) -> list[RelatedProduct]:
    """Safe, non-prescription cross-sell suggestions tied to the medication's ingredient."""
    if not medication.active_ingredient_id:
        return []
    return db.query(RelatedProduct).filter(
        RelatedProduct.active_ingredient_id == medication.active_ingredient_id
    ).all()


def compute_next_reminder_date(frequency_days: int, start: date | None = None) -> date:
    start = start or date.today()
    return start + timedelta(days=frequency_days)


def is_in_stock(medication: Medication) -> tuple[bool, int]:
    total_qty = sum(item.quantity for item in medication.inventory_items)
    return total_qty > 0, total_qty
