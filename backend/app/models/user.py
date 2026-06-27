import enum
from datetime import datetime, date

from sqlalchemy import Column, Integer, String, Boolean, DateTime, Date, Enum as SAEnum, ForeignKey
from sqlalchemy.orm import relationship

from app.core.database import Base


class UserRole(str, enum.Enum):
    admin = "admin"
    pharmacist = "pharmacist"
    customer = "customer"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(150), nullable=False)
    email = Column(String(150), unique=True, nullable=False, index=True)
    phone = Column(String(30), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    role = Column(SAEnum(UserRole), nullable=False, default=UserRole.customer)
    date_of_birth = Column(Date, nullable=True)
    is_pregnant = Column(Boolean, default=False)  # only used to surface safety warnings
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    allergies = relationship("CustomerAllergy", back_populates="customer", cascade="all, delete-orphan")
    chronic_conditions = relationship("ChronicCondition", back_populates="customer", cascade="all, delete-orphan")

    def age(self) -> int | None:
        if not self.date_of_birth:
            return None
        today = date.today()
        return today.year - self.date_of_birth.year - (
            (today.month, today.day) < (self.date_of_birth.month, self.date_of_birth.day)
        )


class CustomerAllergy(Base):
    __tablename__ = "customer_allergies"

    id = Column(Integer, primary_key=True, index=True)
    substance_name = Column(String(150), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    customer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    customer = relationship("User", back_populates="allergies")


class ChronicCondition(Base):
    __tablename__ = "customer_chronic_conditions"

    id = Column(Integer, primary_key=True, index=True)
    condition_name = Column(String(150), nullable=False)
    notes = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    customer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    customer = relationship("User", back_populates="chronic_conditions")
