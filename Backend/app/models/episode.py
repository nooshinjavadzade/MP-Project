from __future__ import annotations

from datetime import date
from typing import TYPE_CHECKING

from sqlalchemy import ForeignKeyConstraint, PrimaryKeyConstraint, Date, Integer, String, Text, Float
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.db import Base

if TYPE_CHECKING:
    from app.models import Season


class Episode(Base):
    __tablename__ = "episodes"

    media_id: Mapped[int] = mapped_column(nullable=False)
    season_number: Mapped[int] = mapped_column(nullable=False)
    episode_number: Mapped[int] = mapped_column(nullable=False)

    title: Mapped[str] = mapped_column(String(255), nullable=False)
    overview: Mapped[str | None] = mapped_column(Text, nullable=True)
    release_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    runtime: Mapped[int | None] = mapped_column(Integer, nullable=True)
    tmdb_rating: Mapped[float | None] = mapped_column(Float, nullable=True)

    __table_args__ = (
        PrimaryKeyConstraint(
            "media_id",
            "season_number",
            "episode_number",
        ),
        ForeignKeyConstraint(
            ["media_id", "season_number"],
            ["seasons.media_id", "seasons.season_number"],
            ondelete="CASCADE",
        ),
    )

    season: Mapped["Season"] = relationship(back_populates="episodes")