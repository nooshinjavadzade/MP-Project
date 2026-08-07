from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, Enum as SQLEnum, ForeignKey, Integer, PrimaryKeyConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.db import Base
from app.models.media import WatchStatus

if TYPE_CHECKING:
    from app.models import User, Media


class EpisodeWatchProgress(Base):
    __tablename__ = "episode_watch_progress"

    __table_args__ = (
        PrimaryKeyConstraint(
            "user_id",
            "media_id",
            "season_number",
            "episode_number",
            name="pk_episode_watch_progress",
        ),
    )

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    media_id: Mapped[int] = mapped_column(ForeignKey("media.id", ondelete="CASCADE"), nullable=False)
    season_number: Mapped[int] = mapped_column(Integer, nullable=False)
    episode_number: Mapped[int] = mapped_column(Integer, nullable=False)

    status: Mapped[WatchStatus] = mapped_column(
        SQLEnum(WatchStatus, name="watchstatus", create_type=False),
        nullable=False,
        default=WatchStatus.plan_to_watch
    )
    watched_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), onupdate=func.now())

    user: Mapped["User"] = relationship(back_populates="episode_watch_progress")
    media: Mapped["Media"] = relationship(back_populates="episode_watch_progress")

    def __repr__(self) -> str:
        return (
            f"<EpisodeWatchProgress user_id={self.user_id} "
            f"media_id={self.media_id} "
            f"s{self.season_number}e{self.episode_number} "
            f"status={self.status.value}>"
        )