from datetime import date

from app.models.user import User, UserRole
from app.models.medication import Medication
from app.models.order import Reminder
from app.models.notification import Notification
from app.services import reminder_engine


def test_reminder_engine_notifies_and_advances_date(db_session):
    customer = User(
        full_name="Test Customer", email="rem@example.com", password_hash="x",
        role=UserRole.customer, phone="0911111111",
    )
    db_session.add(customer)
    db_session.commit()

    med = Medication(name_en="Coumadin", name_ar="كومادين", price=1)
    db_session.add(med)
    db_session.commit()

    reminder = Reminder(
        customer_id=customer.id, medication_id=med.id,
        frequency_days=30, next_reminder_date=date.today(),
    )
    db_session.add(reminder)
    db_session.commit()

    notified = reminder_engine.run_due_reminders(db_session)
    assert len(notified) == 1

    db_session.refresh(reminder)
    assert reminder.next_reminder_date > date.today()

    notifications = db_session.query(Notification).filter(Notification.user_id == customer.id).all()
    assert len(notifications) == 1
    assert "كومادين" in notifications[0].body


def test_prescription_review_creates_customer_notification(client):
    resp = client.post("/api/auth/register", json={
        "full_name": "Pharm", "email": "ph_notif@example.com", "password": "StrongPass123", "role": "pharmacist",
    })
    ph_token = resp.json()["access_token"]

    resp = client.post("/api/auth/register", json={
        "full_name": "Customer", "email": "cust_notif@example.com", "password": "StrongPass123", "role": "customer",
    })
    cust_token = resp.json()["access_token"]

    import io
    from PIL import Image
    buf = io.BytesIO()
    Image.new("RGB", (200, 100), color="white").save(buf, format="PNG")

    resp = client.post(
        "/api/prescriptions/upload",
        files={"file": ("rx.png", buf.getvalue(), "image/png")},
        headers={"Authorization": f"Bearer {cust_token}"},
    )
    prescription_id = resp.json()["prescription"]["id"]

    client.patch(
        f"/api/prescriptions/{prescription_id}/review",
        json={"status": "reviewed", "pharmacist_notes": "موافق عليها"},
        headers={"Authorization": f"Bearer {ph_token}"},
    )

    resp = client.get("/api/notifications/mine", headers={"Authorization": f"Bearer {cust_token}"})
    assert resp.status_code == 200
    notifications = resp.json()
    assert any("موافق عليها" in n["body"] for n in notifications)

    resp = client.get("/api/notifications/unread-count", headers={"Authorization": f"Bearer {cust_token}"})
    assert resp.json()["count"] >= 1
