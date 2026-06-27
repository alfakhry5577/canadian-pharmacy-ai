from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_pharmacist
from app.models.medication import InventoryItem, Medication
from app.models.user import User
from app.schemas.medication import InventoryItemOut, InventoryUpdate

router = APIRouter(prefix="/api/inventory", tags=["inventory"])


@router.get("", response_model=list[InventoryItemOut])
def list_inventory(db: Session = Depends(get_db), _: User = Depends(require_pharmacist)):
    return db.query(InventoryItem).all()


@router.get("/low-stock", response_model=list[InventoryItemOut])
def low_stock(db: Session = Depends(get_db), _: User = Depends(require_pharmacist)):
    items = db.query(InventoryItem).all()
    return [i for i in items if i.is_low_stock]


@router.post("/{medication_id}", response_model=InventoryItemOut, status_code=201)
def add_stock_batch(
    medication_id: int,
    payload: InventoryUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_pharmacist),
):
    if not db.query(Medication).filter(Medication.id == medication_id).first():
        raise HTTPException(status_code=404, detail="الدواء غير موجود")
    item = InventoryItem(
        medication_id=medication_id,
        quantity=payload.quantity or 0,
        reorder_threshold=payload.reorder_threshold if payload.reorder_threshold is not None else 10,
        batch_no=payload.batch_no,
        expiry_date=payload.expiry_date,
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.patch("/{item_id}", response_model=InventoryItemOut)
def update_stock(
    item_id: int,
    payload: InventoryUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_pharmacist),
):
    item = db.query(InventoryItem).filter(InventoryItem.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="عنصر المخزون غير موجود")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(item, field, value)
    db.commit()
    db.refresh(item)
    return item
