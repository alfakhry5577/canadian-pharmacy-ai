from fastapi import APIRouter

from app.api.routes import (
    auth, medications, prescriptions, inventory, alerts, chat, reports, customer, notifications,
)

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(medications.router)
api_router.include_router(prescriptions.router)
api_router.include_router(inventory.router)
api_router.include_router(alerts.router)
api_router.include_router(chat.router)
api_router.include_router(reports.router)
api_router.include_router(customer.router)
api_router.include_router(notifications.router)
