from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, String, Text, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.db import Base

if TYPE_CHECKING:
    from app.models import User, PersonalListItem


class PersonalList(Base):
    __tablename__ = "personal_lists"

    __table_args__ = (
        UniqueConstraint("user_id", "name", name="uq_personal_list_user_name"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, index=True)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)

    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    is_default: Mapped[bool] = mapped_column(default=False, nullable=False)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), onupdate=func.now())

    user: Mapped["User"] = relationship(back_populates="personal_lists")
    items: Mapped[list["PersonalListItem"]] = relationship(back_populates="personal_list", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<PersonalList id={self.id} name='{self.name}'>"
