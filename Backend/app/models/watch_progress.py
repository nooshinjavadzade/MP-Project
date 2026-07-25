from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, Enum as SQLEnum, Float, ForeignKey, Integer, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..core.db import Base
from .media import WatchStatus

if TYPE_CHECKING:
    from . import User, Media


class WatchProgress(Base):
    __tablename__ = "watch_progress"

    __table_args__ = (
        UniqueConstraint("user_id", "media_id", name="uq_watch_progress_user_media"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    media_id: Mapped[int] = mapped_column(ForeignKey("media.id"), nullable=False)

    status: Mapped[WatchStatus | None] = mapped_column(SQLEnum(WatchStatus), nullable=True)
    progress: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    watched_episodes: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    last_watched_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), onupdate=func.now())

    user: Mapped["User"] = relationship(back_populates="watch_progress")
    media: Mapped["Media"] = relationship(back_populates="watch_progress")

    def __repr__(self) -> str:
        return (
            f"<WatchProgress user_id={self.user_id} "
            f"media_id={self.media_id} progress={self.progress}>"
        )