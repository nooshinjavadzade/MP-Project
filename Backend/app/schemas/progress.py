from pydantic import BaseModel, ConfigDict, Field
from datetime import datetime
from app.models.media import WatchStatus


class EpisodeProgressCreate(BaseModel):
    season_number: int
    episode_number: int
    status: WatchStatus


class EpisodeProgressUpdate(BaseModel):
    status: WatchStatus | None = None


class EpisodeProgressResponse(BaseModel):
    user_id: int
    media_id: int
    season_number: int
    episode_number: int
    status: WatchStatus
    watched_at: datetime | None = None
    created_at: datetime
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class MovieProgressCreate(BaseModel):
    status: WatchStatus
    progress: float = Field(ge=0, le=100, default=0.0)


class MovieProgressUpdate(BaseModel):
    status: WatchStatus | None = None
    progress: float | None = Field(ge=0, le=100, default=None)


class MovieProgressResponse(BaseModel):
    id: int
    user_id: int
    media_id: int
    status: WatchStatus | None = None
    progress: float
    watched_episodes: int
    last_watched_at: datetime | None = None
    created_at: datetime
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class SeriesProgressResponse(BaseModel):
    media_id: int
    title: str
    total_episodes: int
    watched_episodes: int
    completion_pct: float
    status: WatchStatus
    next_episode: dict | None = None

    model_config = ConfigDict(from_attributes=True)
    

class EpisodeProgressUpdateResponse(BaseModel):
    message: str
    episode: EpisodeProgressResponse