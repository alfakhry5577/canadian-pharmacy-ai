from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_pharmacist
from app.models.alert import Alert
from app.models.user import User
from app.schemas.reports import AlertOut, ReminderOut
from app.services import alert_service, reminder_engine

router = APIRouter(prefix="/api/alerts", tags=["alerts"])


@router.get("", response_model=list[AlertOut])
def list_alerts(
    resolved: bool = False,
    db: Session = Depends(get_db),
    _: User = Depends(require_pharmacist),
):
    return (
        db.query(Alert)
        .filter(Alert.is_resolved == resolved)
        .order_by(Alert.created_at.desc())
        .all()
    )


@router.post("/scan", response_model=list[AlertOut])
def run_alert_scan(db: Session = Depends(get_db), _: User = Depends(require_pharmacist)):
    """Triggers low-stock + expiry scans. In production this would run on a schedule (cron/Celery beat)."""
    created = alert_service.scan_low_stock(db) + alert_service.scan_expiring_soon(db)
    return created


@router.patch("/{alert_id}/resolve", response_model=AlertOut)
def resolve_alert(alert_id: int, db: Session = Depends(get_db), _: User = Depends(require_pharmacist)):
    alert = db.query(Alert).filter(Alert.id == alert_id).first()
    if alert:
        alert.is_resolved = True
        db.commit()
        db.refresh(alert)
    return alert


@router.post("/reminders-scan", response_model=list[ReminderOut])
def run_reminders_scan(db: Session = Depends(get_db), _: User = Depends(require_pharmacist)):
    """
    Manually triggers the medication reminder engine (see app/services/reminder_engine.py).
    In production this should instead run automatically once a day via cron/Celery beat —
    this endpoint exists for demos and on-demand testing.
    """
    return reminder_engine.run_due_reminders(db)
