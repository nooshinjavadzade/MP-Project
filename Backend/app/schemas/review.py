from pydantic import BaseModel
from datetime import datetime


class ReviewCreate(BaseModel):
    media_id: int
    review: str
    contains_spoiler: bool = False


class ReviewUpdate(BaseModel):
    review: str | None = None
    contains_spoiler: bool | None = None


class ReviewResponse(BaseModel):
    id: int
    media_id: int
    review: str
    contains_spoiler: bool
    created_at: datetime
    updated_at: datetime