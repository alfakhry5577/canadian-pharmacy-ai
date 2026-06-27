from datetime import date, datetime
from pydantic import BaseModel, EmailStr, Field

from app.models.user import UserRole


class UserCreate(BaseModel):
    full_name: str = Field(min_length=2, max_length=150)
    email: EmailStr
    phone: str | None = None
    password: str = Field(min_length=8)
    role: UserRole = UserRole.customer
    date_of_birth: date | None = None
    is_pregnant: bool = False


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    id: int
    full_name: str
    email: EmailStr
    phone: str | None
    role: UserRole
    date_of_birth: date | None
    is_pregnant: bool
    created_at: datetime

    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class AllergyCreate(BaseModel):
    substance_name: str


class ChronicConditionCreate(BaseModel):
    condition_name: str
    notes: str | None = None
