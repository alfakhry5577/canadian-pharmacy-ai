from datetime import datetime
from pydantic import BaseModel


class ChatMessageIn(BaseModel):
    session_id: int | None = None  # omit to start a new session
    message: str


class ChatMessageOut(BaseModel):
    id: int
    role: str
    content: str
    created_at: datetime

    class Config:
        from_attributes = True


class ChatReply(BaseModel):
    session_id: int
    reply: ChatMessageOut
    escalate_to_pharmacist: bool = False
