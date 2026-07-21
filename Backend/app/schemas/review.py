from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class ReviewCreate(BaseModel):
    media_id: int
    review: str
    contains_spoiler: bool = False


class ReviewUpdate(BaseModel):
    review: Optional[str] = None
    contains_spoiler: Optional[bool] = None


class ReviewResponse(BaseModel):
    id: int
    media_id: int
    review: str
    contains_spoiler: bool
    created_at: datetime
    updated_at: datetime