from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class PersonalListCreate(BaseModel):
    name: str
    description: Optional[str]


class PersonalListUpdate(BaseModel):
    name: Optional[str]
    description: Optional[str]


class PersonalListItemCreate(BaseModel):
    media_id: int


class PersonalListResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
