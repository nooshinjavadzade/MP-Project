from pydantic import BaseModel, Field
from datetime import datetime


class ReviewCreate(BaseModel):
    review: str = Field(min_length=1, max_length=5000)
    contains_spoiler: bool = False


class ReviewUpdate(BaseModel):
    review: str | None = Field(default=None, min_length=1, max_length=5000)
    contains_spoiler: bool | None = None


class ReviewResponse(BaseModel):
    id: int
    media_id: int
    user_id: int
    review: str
    contains_spoiler: bool
    created_at: datetime
    updated_at: datetime | None = None

    model_config = {"from_attributes": True}