from pydantic import BaseModel
from datetime import datetime


class PersonalListCreate(BaseModel):
    name: str
    description: str | None


class PersonalListUpdate(BaseModel):
    name: str | None
    description: str | None


class PersonalListItemCreate(BaseModel):
    media_id: int


class PersonalListResponse(BaseModel):
    id: int
    name: str
    description: str | None
    created_at: datetime

    class Config:
        from_attributes = True
