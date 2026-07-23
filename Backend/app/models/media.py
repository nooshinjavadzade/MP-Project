from __future__ import annotations

from enum import Enum
from typing import TYPE_CHECKING
from datetime import datetime

from sqlalchemy import DateTime, Enum as SQLEnum, Float, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import ARRAY, JSONB

from ..core.db import Base

if TYPE_CHECKING:
    from . import Review, UserRating, WatchProgress, PersonalListItem, Season


class MediaType(Enum):
    movie = "movie"
    series = "series"


class WatchStatus(Enum):
    plan_to_watch = "plan_to_watch"
    watching = "watching"
    completed = "completed"
    on_hold = "on_hold"
    dropped = "dropped"
    loved = "loved"


class Media(Base):
    __tablename__ = "media"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    tmdb_id: Mapped[str] = mapped_column(String(20), unique=True, nullable=False, index=True)
    media_type: Mapped[MediaType] = mapped_column(SQLEnum(MediaType), nullable=False)

    title: Mapped[str] = mapped_column(String(255), nullable=False)
    original_title: Mapped[str | None] = mapped_column(String(255), nullable=True)
    poster_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    backdrop_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    overview: Mapped[str | None] = mapped_column(Text, nullable=True)
    release_year: Mapped[int | None] = mapped_column(Integer, nullable=True)
    tmdb_rating: Mapped[float | None] = mapped_column(Float, nullable=True)
    country: Mapped[str | None] = mapped_column(String(255), nullable=True)
    original_language: Mapped[str | None] = mapped_column(String(255), nullable=True)
    community_rating: Mapped[float | None] = mapped_column(Float, nullable=True)
    genres: Mapped[list[str]] = mapped_column(ARRAY(String), nullable=False, default=list)
    cast: Mapped[list[dict]] = mapped_column(JSONB, nullable=False, default=list)

    # Movie
    runtime: Mapped[int | None] = mapped_column(Integer, nullable=True)

    # Series
    season_count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    episode_count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    end_year: Mapped[int | None] = mapped_column(Integer, nullable=True)
    status: Mapped[str | None] = mapped_column(String(50), nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    last_fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=True)

    reviews: Mapped[list["Review"]] = relationship(back_populates="media", cascade="all, delete-orphan")
    ratings: Mapped[list["UserRating"]] = relationship(back_populates="media", cascade="all, delete-orphan")
    watch_progress: Mapped[list["WatchProgress"]] = relationship(back_populates="media", cascade="all, delete-orphan")
    list_items: Mapped[list["PersonalListItem"]] = relationship(back_populates="media", cascade="all, delete-orphan")
    seasons: Mapped[list["Season"]] = relationship(back_populates="media", cascade="all, delete-orphan")


    def __repr__(self) -> str:
        return f"<Media {self.media_type.value}: {self.title}>"
