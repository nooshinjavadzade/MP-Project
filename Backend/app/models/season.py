from __future__ import annotations

from typing import TYPE_CHECKING
from datetime import date

from sqlalchemy import ForeignKeyConstraint, PrimaryKeyConstraint, String, Text, Date, Float
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.db import Base

if TYPE_CHECKING:
    from app.models import Media, Episode


class Season(Base):
    __tablename__ = "seasons"

    media_id: Mapped[int] = mapped_column(nullable=False)
    season_number: Mapped[int] = mapped_column(nullable=False)

    title: Mapped[str | None] = mapped_column(String(255), nullable=True)
    overview: Mapped[str | None] = mapped_column(Text, nullable=True)
    release_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    tmdb_rating: Mapped[float | None] = mapped_column(Float, nullable=True)

    __table_args__ = (
        PrimaryKeyConstraint("media_id", "season_number"),
        ForeignKeyConstraint(
            ["media_id"],
            ["media.id"],
            ondelete="CASCADE",
        ),
    )

    media: Mapped["Media"] = relationship(back_populates="seasons")
    episodes: Mapped[list["Episode"]] = relationship(
        back_populates="season",
        cascade="all, delete-orphan",
    )