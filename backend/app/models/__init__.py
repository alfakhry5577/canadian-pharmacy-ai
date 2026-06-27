"""
Import every model here so that Base.metadata.create_all() picks up all tables
and so relationship() string references resolve correctly across modules.
"""
from app.models.user import User, UserRole, CustomerAllergy, ChronicCondition  # noqa: F401
from app.models.medication import (  # noqa: F401
    ActiveIngredient, Medication, DrugInteraction, RelatedProduct, InventoryItem,
    medication_substitutes, AlertSeverity,
)
from app.models.prescription import Prescription, PrescriptionItem, PrescriptionStatus  # noqa: F401
from app.models.alert import Alert, AlertType  # noqa: F401
from app.models.order import (  # noqa: F401
    Order, OrderItem, OrderStatus, Reminder, LoyaltyAccount, LoyaltyTransaction,
)
from app.models.chat import ChatSession, ChatMessage, ChatRole  # noqa: F401
from app.models.notification import Notification  # noqa: F401
