from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    APP_NAME: str = "Movie Tracker API"
    APP_VERSION: str = "1.0.0"
    APP_DESCRIPTION: str = "Backend API for movie and series tracking application"

    # Required settings
    DATABASE_URL: str
    SECRET_KEY: str

    # Optional with defaults
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # API
    TMDB_API_BASE_URL: str = "https://api.themoviedb.org/3"
    TMDB_API_KEY: str | None = None
    TMDB_ACCESS_TOKEN: str | None = None

    # CORS
    DEBUG: bool = True
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8080"]

    # Redis for cache
    REDIS_URL: str = "redis://localhost:6379/0"

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
