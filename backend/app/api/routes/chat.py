from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.chat import ChatSession, ChatMessage, ChatRole
from app.schemas.chat import ChatMessageIn, ChatReply, ChatMessageOut
from app.services import ai_service

router = APIRouter(prefix="/api/chat", tags=["chat"])


@router.post("/send", response_model=ChatReply)
def send_message(
    payload: ChatMessageIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if payload.session_id:
        session = db.query(ChatSession).filter(
            ChatSession.id == payload.session_id, ChatSession.user_id == current_user.id
        ).first()
        if not session:
            raise HTTPException(status_code=404, detail="جلسة المحادثة غير موجودة")
    else:
        session = ChatSession(user_id=current_user.id)
        db.add(session)
        db.commit()
        db.refresh(session)

    db.add(ChatMessage(session_id=session.id, role=ChatRole.user, content=payload.message))
    db.commit()

    history = [
        {"role": m.role.value, "content": m.content}
        for m in db.query(ChatMessage).filter(ChatMessage.session_id == session.id).order_by(ChatMessage.id).all()
        if m.role != ChatRole.system
    ][:-1]  # exclude the message we just added; it's passed separately below

    user_context = {
        "allergies": [a.substance_name for a in current_user.allergies],
        "chronic_conditions": [c.condition_name for c in current_user.chronic_conditions],
        "is_pregnant": current_user.is_pregnant,
        "age": current_user.age(),
    }

    reply_text, escalate = ai_service.chat_reply(history, payload.message, user_context)

    reply_msg = ChatMessage(session_id=session.id, role=ChatRole.assistant, content=reply_text)
    db.add(reply_msg)
    db.commit()
    db.refresh(reply_msg)

    return ChatReply(
        session_id=session.id,
        reply=ChatMessageOut.model_validate(reply_msg),
        escalate_to_pharmacist=escalate,
    )


@router.get("/{session_id}/history", response_model=list[ChatMessageOut])
def get_history(session_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    session = db.query(ChatSession).filter(
        ChatSession.id == session_id, ChatSession.user_id == current_user.id
    ).first()
    if not session:
        raise HTTPException(status_code=404, detail="جلسة المحادثة غير موجودة")
    return db.query(ChatMessage).filter(ChatMessage.session_id == session_id).order_by(ChatMessage.id).all()
