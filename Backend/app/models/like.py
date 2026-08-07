from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.db import Base

if TYPE_CHECKING:
    from app.models import User, Media


class Like(Base):
    __tablename__ = "likes"

    __table_args__ = (
        UniqueConstraint("user_id", "media_id", name="uq_like_user_media"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    media_id: Mapped[int] = mapped_column(ForeignKey("media.id"), nullable=False)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    user: Mapped["User"] = relationship(back_populates="likes")
    media: Mapped["Media"] = relationship(back_populates="likes")

    def __repr__(self) -> str:
        return f"<Like user_id={self.user_id} media_id={self.media_id}>"