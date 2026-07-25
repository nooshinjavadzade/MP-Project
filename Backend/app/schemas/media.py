from pydantic import BaseModel
from typing import List
from datetime import datetime
from enum import Enum


class MediaType(str, Enum):
    movie = "movie"
    series = "series"


class CastMember(BaseModel):
    id: str
    name: str
    role: str
    profile_image_url: str | None = None


class MediaBase(BaseModel):
    id: int
    media_type: MediaType
    tmdb_id: str
    title: str
    poster_url: str | None = None
    backdrop_url: str | None = None
    release_year: int | None = None
    tmdb_rating: float | None = None
    community_rating: float | None = None

    class Config:
        from_attributes = True


class MediaDetails(MediaBase):
    original_title: str | None = None
    overview: str | None = None
    original_language: str | None = None
    country: str | None = None
    cast: List[CastMember] = []
    genres: List[str] = []


class Pagination(BaseModel):
    page: int
    per_page: int = 20
    total_items: int
    total_pages: int
    has_next_page: bool
    has_previous_page: bool


class MediaSearchResult(BaseModel):
    items: List[MediaBase]
    pagination: Pagination


class MovieDetails(MediaDetails):
    runtime: int | None = None


class Episode(BaseModel):
    episode_number: int
    title: str
    overview: str | None = None
    release_date: datetime | None = None
    runtime: int | None = None
    tmdb_rating: float | None = None


class Season(BaseModel):
    season_number: int
    title: str | None = None
    overview: str | None = None
    release_date: datetime | None = None
    tmdb_rating: float | None = None
    episodes: List[Episode] = []


class SeriesDetails(MediaDetails):
    season_count: int | None = None
    episode_count: int | None = None
    seasons: List[Season] = []
    end_year: int | None = None
    status: str
