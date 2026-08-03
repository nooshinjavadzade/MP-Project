from pydantic import BaseModel, EmailStr, ConfigDict, Field
from datetime import datetime
from typing import List, Optional

from app.schemas.media import MediaBase


class UserBase(BaseModel):
    username: str
    email: EmailStr
    full_name: str | None = None


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    username: str | None = None
    email: EmailStr | None = None
    full_name: str | None = None
    bio: str | None = None
    avatar_url: str | None = None


class PasswordChange(BaseModel):
    old_password: str
    new_password: str
    confirm_password: str


class PublicUser(BaseModel):
    id: int
    username: str
    full_name: str | None = None
    avatar_url: str | None = None
    bio: str | None = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class UserResponse(UserBase):
    id: int
    avatar_url: str | None = None
    bio: str | None = None
    is_admin: bool = False
    is_verified: bool = False
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ProfileStats(BaseModel):
    watched_movies_count: int = 0
    watched_series_count: int = 0
    liked_media_count: int = 0
    ratings_count: int = 0
    reviews_count: int = 0
    lists_count: int = 0


class ProfileResponse(PublicUser):
    watched_movies_count: int = 0
    watched_series_count: int = 0
    liked_media: List[MediaBase] = Field(default_factory=list)
    ratings_count: int = 0
    reviews_count: int = 0
    lists_count: int = 0

    model_config = ConfigDict(from_attributes=True)


class PublicProfileResponse(PublicUser):
    watched_movies_count: int = 0
    watched_series_count: int = 0
    liked_media: List[MediaBase] = Field(default_factory=list)
    ratings_count: int = 0
    reviews_count: int = 0
    lists_count: int = 0

    model_config = ConfigDict(from_attributes=True)


class UserLogin(BaseModel):
    email: EmailStr
    password: str
