from pydantic import BaseModel, Field, ConfigDict
from typing import List
from datetime import datetime


from app.schemas.media import MediaBase


class LikeToggleResponse(BaseModel):
    liked: bool


class PersonalListCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    description: str | None = None


class PersonalListUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    description: str | None = None


class PersonalListItemAdd(BaseModel):
    media_id: int


class PersonalListResponse(BaseModel):
    id: int
    user_id: int
    name: str
    description: str | None = None
    is_default: bool = False
    created_at: datetime
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class PersonalListItemResponse(BaseModel):
    id: int
    list_id: int
    media_id: int
    media: MediaBase
    added_at: datetime

    model_config = ConfigDict(from_attributes=True)


class PersonalListWithItems(PersonalListResponse):
    items: List[PersonalListItemResponse] = []
    item_count: int = 0