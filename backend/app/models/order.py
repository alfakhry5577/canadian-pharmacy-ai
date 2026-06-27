import enum
from datetime import datetime

from sqlalchemy import (
    Column, Integer, String, Boolean, DateTime, Date, Text, ForeignKey, Numeric, Enum as SAEnum
)
from sqlalchemy.orm import relationship

from app.core.database import Base


class OrderStatus(str, enum.Enum):
    pending = "pending"
    confirmed = "confirmed"
    completed = "completed"
    cancelled = "cancelled"


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    pharmacist_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    prescription_id = Column(Integer, ForeignKey("prescriptions.id"), nullable=True)
    status = Column(SAEnum(OrderStatus), default=OrderStatus.pending)
    total_amount = Column(Numeric(10, 2), default=0)
    created_at = Column(DateTime, default=datetime.utcnow)

    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    medication_id = Column(Integer, ForeignKey("medications.id"), nullable=True)
    related_product_id = Column(Integer, ForeignKey("related_products.id"), nullable=True)
    quantity = Column(Integer, default=1)
    unit_price = Column(Numeric(10, 2), default=0)

    order = relationship("Order", back_populates="items")
    medication = relationship("Medication")


class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    medication_id = Column(Integer, ForeignKey("medications.id"), nullable=False)
    frequency_days = Column(Integer, default=30)
    next_reminder_date = Column(Date, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    medication = relationship("Medication")


class LoyaltyAccount(Base):
    __tablename__ = "loyalty_accounts"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    points = Column(Integer, default=0)
    tier = Column(String(30), default="bronze")

    transactions = relationship("LoyaltyTransaction", back_populates="account", cascade="all, delete-orphan")

    def recompute_tier(self):
        if self.points >= 2000:
            self.tier = "gold"
        elif self.points >= 500:
            self.tier = "silver"
        else:
            self.tier = "bronze"


class LoyaltyTransaction(Base):
    __tablename__ = "loyalty_transactions"

    id = Column(Integer, primary_key=True, index=True)
    loyalty_account_id = Column(Integer, ForeignKey("loyalty_accounts.id"), nullable=False)
    points_change = Column(Integer, nullable=False)
    reason = Column(String(200))
    created_at = Column(DateTime, default=datetime.utcnow)

    account = relationship("LoyaltyAccount", back_populates="transactions")
