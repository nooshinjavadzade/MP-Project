from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.db import Base

if TYPE_CHECKING:
    from app.models import Media, PersonalList


class PersonalListItem(Base):
    __tablename__ = "personal_list_items"

    __table_args__ = (
        UniqueConstraint("list_id", "media_id", name="uq_personal_list_item"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    list_id: Mapped[int] = mapped_column(ForeignKey("personal_lists.id"), nullable=False)
    media_id: Mapped[int] = mapped_column(ForeignKey("media.id"), nullable=False)

    added_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    personal_list: Mapped["PersonalList"] = relationship(back_populates="items")
    media: Mapped["Media"] = relationship(back_populates="list_items")

    def __repr__(self) -> str:
        return f"<PersonalListItem list_id={self.list_id} media_id={self.media_id}>"
