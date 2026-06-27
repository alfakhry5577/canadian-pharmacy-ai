"""
Notification Service
---------------------
A small, provider-agnostic notification layer. Ships with safe, dependency-free
defaults (writes to the application log) so the rest of the app — reminders,
prescription decisions, low-stock alerts — can call `notify(...)` today without
needing real SMTP/SMS credentials. Swap in a real provider by implementing the
`NotificationProvider` interface and wiring it in `get_notification_service()`.

Real-provider examples (left as comments — no extra dependency is installed
by default to keep this project runnable with zero external accounts):

    # Email via SMTP (e.g. SendGrid, Mailgun, Amazon SES, or a plain SMTP relay)
    import smtplib
    from email.mime.text import MIMEText

    class SmtpEmailProvider(NotificationProvider):
        def send(self, to: str, subject: str, body: str) -> bool:
            msg = MIMEText(body)
            msg["Subject"], msg["From"], msg["To"] = subject, settings.SMTP_FROM, to
            with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
                server.starttls()
                server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                server.sendmail(settings.SMTP_FROM, [to], msg.as_string())
            return True

    # SMS via Twilio
    from twilio.rest import Client

    class TwilioSmsProvider(NotificationProvider):
        def send(self, to: str, subject: str, body: str) -> bool:
            client = Client(settings.TWILIO_SID, settings.TWILIO_AUTH_TOKEN)
            client.messages.create(to=to, from_=settings.TWILIO_FROM_NUMBER, body=body)
            return True
"""
import logging
from abc import ABC, abstractmethod
from enum import Enum

logger = logging.getLogger("notifications")


class NotificationChannel(str, Enum):
    email = "email"
    sms = "sms"
    in_app = "in_app"


class NotificationProvider(ABC):
    @abstractmethod
    def send(self, to: str, subject: str, body: str) -> bool:
        """Returns True on success. Must never raise — log and return False instead,
        so a notification failure never breaks the calling business operation
        (e.g. a prescription approval should still succeed even if the SMS fails)."""
        raise NotImplementedError


class ConsoleLogProvider(NotificationProvider):
    """Default provider for every channel — logs instead of sending. Safe for local dev/demo."""

    def __init__(self, channel: NotificationChannel):
        self.channel = channel

    def send(self, to: str, subject: str, body: str) -> bool:
        logger.info("[%s] to=%s | %s | %s", self.channel.value.upper(), to, subject, body)
        return True


class NotificationService:
    def __init__(self, providers: dict[NotificationChannel, NotificationProvider]):
        self._providers = providers

    def notify(self, channel: NotificationChannel, to: str, subject: str, body: str) -> bool:
        provider = self._providers.get(channel)
        if provider is None:
            logger.warning("No provider configured for channel %s", channel)
            return False
        try:
            return provider.send(to, subject, body)
        except Exception:  # noqa: BLE001 — a notification failure must never bubble up
            logger.exception("Notification send failed on channel %s", channel)
            return False

    def notify_email(self, to: str, subject: str, body: str) -> bool:
        return self.notify(NotificationChannel.email, to, subject, body)

    def notify_sms(self, to: str, body: str) -> bool:
        return self.notify(NotificationChannel.sms, to, "", body)

    def notify_in_app(self, user_id: int, subject: str, body: str) -> bool:
        return self.notify(NotificationChannel.in_app, str(user_id), subject, body)


_default_service = NotificationService({
    NotificationChannel.email: ConsoleLogProvider(NotificationChannel.email),
    NotificationChannel.sms: ConsoleLogProvider(NotificationChannel.sms),
    NotificationChannel.in_app: ConsoleLogProvider(NotificationChannel.in_app),
})


def get_notification_service() -> NotificationService:
    return _default_service


def create_in_app_notification(db, user_id: int, subject: str, body: str):
    """
    Persists a real, queryable in-app notification (see app.models.notification.Notification
    + GET /api/notifications/mine). This is the actual "In-App Notifications" feature;
    `NotificationService.notify_in_app` above only logs and models the provider pattern
    consistently with email/SMS — call both where relevant (see reminder_engine.py).
    """
    from app.models.notification import Notification  # local import avoids a circular import at module load time

    notification = Notification(user_id=user_id, subject=subject, body=body)
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification
