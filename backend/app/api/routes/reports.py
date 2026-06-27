from datetime import datetime, timedelta
from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_pharmacist
from app.models.order import Order, OrderItem
from app.models.medication import Medication, InventoryItem
from app.models.user import User
from app.schemas.reports import SalesSummary, TopMedicationStat

router = APIRouter(prefix="/api/reports", tags=["reports"])


@router.get("/sales-summary", response_model=SalesSummary)
def sales_summary(
    days: int = Query(30, description="عدد الأيام الماضية للتقرير"),
    db: Session = Depends(get_db),
    _: User = Depends(require_pharmacist),
):
    since = datetime.utcnow() - timedelta(days=days)

    orders = db.query(Order).filter(Order.created_at >= since).all()
    total_revenue = sum((o.total_amount for o in orders), Decimal("0"))

    top_rows = (
        db.query(
            OrderItem.medication_id,
            Medication.name_ar,
            func.sum(OrderItem.quantity).label("qty"),
            func.sum(OrderItem.quantity * OrderItem.unit_price).label("revenue"),
        )
        .join(Medication, Medication.id == OrderItem.medication_id)
        .join(Order, Order.id == OrderItem.order_id)
        .filter(Order.created_at >= since)
        .group_by(OrderItem.medication_id, Medication.name_ar)
        .order_by(func.sum(OrderItem.quantity).desc())
        .limit(10)
        .all()
    )

    top_medications = [
        TopMedicationStat(
            medication_id=row.medication_id,
            name_ar=row.name_ar,
            total_quantity_sold=int(row.qty or 0),
            total_revenue=Decimal(row.revenue or 0),
        )
        for row in top_rows
    ]

    low_stock_count = len([i for i in db.query(InventoryItem).all() if i.is_low_stock])
    expiring_cutoff = datetime.utcnow() + timedelta(days=60)
    expiring_soon_count = (
        db.query(InventoryItem)
        .filter(InventoryItem.expiry_date.isnot(None), InventoryItem.expiry_date <= expiring_cutoff)
        .count()
    )

    return SalesSummary(
        period_label=f"آخر {days} يومًا",
        total_orders=len(orders),
        total_revenue=total_revenue,
        top_medications=top_medications,
        low_stock_count=low_stock_count,
        expiring_soon_count=expiring_soon_count,
    )
