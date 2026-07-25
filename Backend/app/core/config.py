from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_NAME: str = "Movie Tracker API"
    APP_VERSION: str = "1.0.0"
    APP_DESCRIPTION: str = "Backend API for movie and series tracking application"

    DATABASE_URL: str
    SECRET_KEY: str

    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    TMDB_API_BASE_URL: str = "https://api.themoviedb.org/3"
    TMDB_API_KEY: str | None = None
    TMDB_ACCESS_TOKEN: str | None = None

    DEBUG: bool = True
    ALLOWED_ORIGINS: list[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
    ]

    REDIS_URL: str = "redis://localhost:6379/0"

    SMTP_HOST: str
    SMTP_PORT: int
    SMTP_USER: str
    SMTP_PASS: str

    EMAIL_FROM: str
    EMAIL_FROM_NAME: str

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )


settings = Settings()