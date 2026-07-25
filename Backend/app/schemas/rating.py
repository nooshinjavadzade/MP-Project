from pydantic import BaseModel, Field
from datetime import datetime


class RatingCreate(BaseModel):
    rating: float = Field(ge=1, le=5)


class RatingResponse(BaseModel):
    id: int
    media_id: int
    user_id: int
    rating: float
    rated_at: datetime
    updated_at: datetime | None = None

    model_config = {"from_attributes": True}
