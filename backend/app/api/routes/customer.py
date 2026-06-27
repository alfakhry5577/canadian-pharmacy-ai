from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.order import Reminder, LoyaltyAccount, LoyaltyTransaction
from app.models.medication import Medication
from app.schemas.reports import ReminderOut, ReminderCreate, LoyaltyAccountOut
from app.services.recommendation_service import compute_next_reminder_date

router = APIRouter(prefix="/api/customer", tags=["customer"])


@router.get("/reminders", response_model=list[ReminderOut])
def list_reminders(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return (
        db.query(Reminder)
        .filter(Reminder.customer_id == current_user.id, Reminder.is_active == True)  # noqa: E712
        .order_by(Reminder.next_reminder_date.asc())
        .all()
    )


@router.post("/reminders", response_model=ReminderOut, status_code=201)
def create_reminder(
    payload: ReminderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not db.query(Medication).filter(Medication.id == payload.medication_id).first():
        raise HTTPException(status_code=404, detail="الدواء غير موجود")

    reminder = Reminder(
        customer_id=current_user.id,
        medication_id=payload.medication_id,
        frequency_days=payload.frequency_days,
        next_reminder_date=compute_next_reminder_date(payload.frequency_days),
    )
    db.add(reminder)
    db.commit()
    db.refresh(reminder)
    return reminder


@router.delete("/reminders/{reminder_id}", status_code=204)
def cancel_reminder(reminder_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    reminder = db.query(Reminder).filter(
        Reminder.id == reminder_id, Reminder.customer_id == current_user.id
    ).first()
    if reminder:
        reminder.is_active = False
        db.commit()


@router.get("/loyalty", response_model=LoyaltyAccountOut)
def my_loyalty(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    account = db.query(LoyaltyAccount).filter(LoyaltyAccount.customer_id == current_user.id).first()
    if not account:
        account = LoyaltyAccount(customer_id=current_user.id)
        db.add(account)
        db.commit()
        db.refresh(account)
    return account
