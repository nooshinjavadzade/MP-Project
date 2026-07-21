from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from enum import Enum


class MediaType(str, Enum):
    movie = "movie"
    series = "series"


class CastMember(BaseModel):
    id: str
    name: str
    role: str
    profile_image_url: Optional[str] = None


class MediaBase(BaseModel):
    id: int
    media_type: MediaType
    tmdb_id: str
    title: str
    original_title: Optional[str] = None
    poster_url: Optional[str] = None
    backdrop_url: Optional[str] = None
    overview: Optional[str] = None
    release_year: Optional[int] = None
    tmdb_rating: Optional[float] = None
    community_rating: Optional[float] = None
    original_language: Optional[str] = None
    country: Optional[str] = None
    cast: List[CastMember] = []
    genres: List[str] = []

    class Config:
        from_attributes = True


class MovieDetails(MediaBase):
    runtime: Optional[int] = None


class Episode(BaseModel):
    episode_number: int
    title: str
    overview: Optional[str] = None
    release_date: Optional[datetime] = None
    runtime: Optional[int] = None


class Season(BaseModel):
    season_number: int
    title: Optional[str] = None
    overview: Optional[str] = None
    release_date: Optional[datetime] = None
    episodes: List[Episode] = []


class SeriesDetails(MediaBase):
    season_count: Optional[int] = None
    episode_count: Optional[int] = None
    seasons: List[Season] = []
    end_year: Optional[int] = None
    status: str
