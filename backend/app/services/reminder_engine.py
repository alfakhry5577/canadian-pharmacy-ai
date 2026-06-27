"""
Reminder Engine
---------------
Scans `reminders` for due refill dates, sends a notification, and advances
`next_reminder_date` by `frequency_days`. Designed to be triggered either:
  - manually, via POST /api/customer/reminders/run-due-scan (admin/pharmacist), or
  - on a schedule in production, e.g. a cron job or Celery beat task calling
    `run_due_reminders(db)` once per day.
"""
from datetime import date, timedelta
from sqlalchemy.orm import Session

from app.models.order import Reminder
from app.models.user import User
from app.services.notification_service import get_notification_service, create_in_app_notification


def run_due_reminders(db: Session, today: date | None = None) -> list[Reminder]:
    today = today or date.today()
    notifier = get_notification_service()

    due = db.query(Reminder).filter(Reminder.is_active == True, Reminder.next_reminder_date <= today).all()  # noqa: E712

    notified: list[Reminder] = []
    for reminder in due:
        customer = db.query(User).filter(User.id == reminder.customer_id).first()
        if not customer:
            continue

        med_name = reminder.medication.name_ar if reminder.medication else f"#{reminder.medication_id}"
        subject = "تذكير بإعادة شراء دواء"
        body = f"حان وقت إعادة شراء دواء {med_name}. لا تفوّت موعد دوائك المزمن."

        notifier.notify_in_app(customer.id, subject, body)
        create_in_app_notification(db, customer.id, subject, body)
        if customer.phone:
            notifier.notify_sms(customer.phone, body)
        notifier.notify_email(customer.email, subject, body)

        reminder.next_reminder_date = today + timedelta(days=reminder.frequency_days)
        notified.append(reminder)

    db.commit()
    return notified
