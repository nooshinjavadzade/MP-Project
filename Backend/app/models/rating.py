from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, Float, ForeignKey, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.db import Base

if TYPE_CHECKING:
    from app.models import User, Media


class UserRating(Base):
    __tablename__ = "user_ratings"

    __table_args__ = (
        UniqueConstraint("user_id", "media_id", name="uq_rating_user_media"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    media_id: Mapped[int] = mapped_column(ForeignKey("media.id"), nullable=False)

    rating: Mapped[float] = mapped_column(Float, nullable=False)

    rated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), onupdate=func.now())

    user: Mapped["User"] = relationship(back_populates="ratings")
    media: Mapped["Media"] = relationship(back_populates="ratings")

    def __repr__(self) -> str:
        return f"<UserRating user_id={self.user_id} media_id={self.media_id} rating={self.rating}>"
