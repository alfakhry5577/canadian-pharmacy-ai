from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import hash_password, verify_password, create_access_token
from app.core.deps import get_current_user
from app.models.user import User, CustomerAllergy, ChronicCondition, UserRole
from app.models.order import LoyaltyAccount
from app.schemas.user import (
    UserCreate, UserLogin, UserOut, Token, AllergyCreate, ChronicConditionCreate,
)

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
def register(payload: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == payload.email).first():
        raise HTTPException(status_code=400, detail="هذا البريد الإلكتروني مسجل مسبقًا")

    user = User(
        full_name=payload.full_name,
        email=payload.email,
        phone=payload.phone,
        password_hash=hash_password(payload.password),
        role=payload.role,
        date_of_birth=payload.date_of_birth,
        is_pregnant=payload.is_pregnant,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # Every customer automatically gets a loyalty account.
    if user.role == UserRole.customer:
        db.add(LoyaltyAccount(customer_id=user.id))
        db.commit()

    token = create_access_token({"user_id": user.id, "role": user.role.value})
    return Token(access_token=token, user=UserOut.model_validate(user))


@router.post("/login", response_model=Token)
def login(payload: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="البريد الإلكتروني أو كلمة المرور غير صحيحة")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="هذا الحساب معطل، يرجى التواصل مع الإدارة")

    token = create_access_token({"user_id": user.id, "role": user.role.value})
    return Token(access_token=token, user=UserOut.model_validate(user))


@router.get("/me", response_model=UserOut)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.post("/me/allergies", response_model=UserOut)
def add_allergy(
    payload: AllergyCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    db.add(CustomerAllergy(customer_id=current_user.id, substance_name=payload.substance_name))
    db.commit()
    db.refresh(current_user)
    return current_user


@router.post("/me/chronic-conditions", response_model=UserOut)
def add_chronic_condition(
    payload: ChronicConditionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    db.add(ChronicCondition(
        customer_id=current_user.id,
        condition_name=payload.condition_name,
        notes=payload.notes,
    ))
    db.commit()
    db.refresh(current_user)
    return current_user
