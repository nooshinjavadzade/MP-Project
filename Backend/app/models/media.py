from sqlalchemy import Column, Integer, String, Float, Text, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from ..core.db import Base


class MediaType(enum.Enum):
    movie = "movie"
    series = "series"


class WatchStatus(enum.Enum):
    plan_to_watch = "plan_to_watch"
    watching = "watching"
    completed = "completed"
    on_hold = "on_hold"
    dropped = "dropped"
    loved = "loved"


class Media(Base):
    __tablename__ = "media"

    id = Column(Integer, primary_key=True, index=True)
    tmdb_id = Column(String(20), unique=True, nullable=False, index=True)
    media_type = Column(SQLEnum(MediaType), nullable=False)

    title = Column(String(255), nullable=False)
    original_title = Column(String(255), nullable=True)
    poster_url = Column(String(500), nullable=True)
    backdrop_url = Column(String(500), nullable=True)
    overview = Column(Text, nullable=True)
    release_year = Column(Integer, nullable=True)
    tmdb_rating = Column(Float, nullable=True)

    # Movie specific
    runtime = Column(Integer, nullable=True)  # minutes
    watch_status = Column(SQLEnum(WatchStatus), nullable=True)

    # Series specific
    season_count = Column(Integer, nullable=True)
    episode_count = Column(Integer, nullable=True)
    end_year = Column(Integer, nullable=True)
    status = Column(String(50), nullable=True)  # "Returning Series", "Ended", etc.

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    reviews = relationship("Review", back_populates="media", cascade="all, delete-orphan")
    ratings = relationship("UserRating", back_populates="media", cascade="all, delete-orphan")
    watch_progress = relationship("WatchProgress", back_populates="media", cascade="all, delete-orphan")
    list_items = relationship("PersonalListItem", back_populates="media", cascade="all, delete-orphan")
