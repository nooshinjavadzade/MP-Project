from pydantic import BaseModel
from datetime import datetime


class RatingCreate(BaseModel):
    media_id: int
    rating: float


class RatingResponse(BaseModel):
    id: int
    media_id: int
    rating: float
    created_at: datetime

    class Config:
        from_attributes = True
