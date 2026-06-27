"""
Alert Service
-------------
Centralizes creation of Alert rows so every part of the app (inventory checks,
prescription analysis, expiry scans) writes alerts in a consistent shape that
the pharmacist/admin dashboards can render.
"""
from datetime import datetime, timedelta
from sqlalchemy.orm import Session

from app.models.alert import Alert, AlertType
from app.models.medication import AlertSeverity, InventoryItem


def create_alert(
    db: Session,
    type_: AlertType,
    message_ar: str,
    severity: AlertSeverity = AlertSeverity.info,
    related_medication_id: int | None = None,
    related_prescription_id: int | None = None,
    customer_id: int | None = None,
) -> Alert:
    alert = Alert(
        type=type_,
        severity=severity,
        message_ar=message_ar,
        related_medication_id=related_medication_id,
        related_prescription_id=related_prescription_id,
        customer_id=customer_id,
    )
    db.add(alert)
    db.commit()
    db.refresh(alert)
    return alert


def scan_low_stock(db: Session) -> list[Alert]:
    """Creates low_stock alerts for inventory items at/under their reorder threshold."""
    items = db.query(InventoryItem).all()
    created = []
    for item in items:
        if item.quantity <= item.reorder_threshold:
            existing = db.query(Alert).filter(
                Alert.type == AlertType.low_stock,
                Alert.related_medication_id == item.medication_id,
                Alert.is_resolved == False,  # noqa: E712
            ).first()
            if existing:
                continue
            med_name = item.medication.name_ar if item.medication else f"#{item.medication_id}"
            alert = create_alert(
                db, AlertType.low_stock,
                message_ar=f"المخزون منخفض لدواء {med_name}: الكمية المتبقية {item.quantity}.",
                severity=AlertSeverity.warning,
                related_medication_id=item.medication_id,
            )
            created.append(alert)
    return created


def scan_expiring_soon(db: Session, days_ahead: int = 60) -> list[Alert]:
    """Creates expiry alerts for inventory batches expiring within `days_ahead` days."""
    cutoff = datetime.utcnow() + timedelta(days=days_ahead)
    items = db.query(InventoryItem).filter(
        InventoryItem.expiry_date.isnot(None),
        InventoryItem.expiry_date <= cutoff,
    ).all()
    created = []
    for item in items:
        existing = db.query(Alert).filter(
            Alert.type == AlertType.expiry,
            Alert.related_medication_id == item.medication_id,
            Alert.is_resolved == False,  # noqa: E712
        ).first()
        if existing:
            continue
        med_name = item.medication.name_ar if item.medication else f"#{item.medication_id}"
        alert = create_alert(
            db, AlertType.expiry,
            message_ar=f"دفعة من دواء {med_name} (رقم التشغيلة {item.batch_no or '-'}) "
                       f"تنتهي صلاحيتها في {item.expiry_date.date() if item.expiry_date else '-'}.",
            severity=AlertSeverity.warning,
            related_medication_id=item.medication_id,
        )
        created.append(alert)
    return created
