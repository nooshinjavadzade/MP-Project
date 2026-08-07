from __future__ import annotations

from enum import Enum
from typing import TYPE_CHECKING
from datetime import datetime

from sqlalchemy import DateTime, Enum as SQLEnum, Float, Integer, String, Text, func, UniqueConstraint, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import ARRAY, JSONB

from app.core.db import Base

if TYPE_CHECKING:
    from app.models import Media


class ReportStatus(Enum):
    pending = "Pending"
    resolved = "Resolved"
    dismissed = "Dismissed"


class ReportReason(Enum):
    inappropriate_content = "Inappropriate Content"
    spam = "Spam"
    copyright = "Copyright"
    incorrect_info = "Incorrect Information"
    other = "Other"


class Report(Base):
    __tablename__ = "reports"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    media_id: Mapped[int] = mapped_column(ForeignKey("media.id"), nullable=False)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    reason: Mapped[ReportReason] = mapped_column(SQLEnum(ReportReason), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[ReportStatus] = mapped_column(SQLEnum(ReportStatus), nullable=False, default=ReportStatus.pending)
    admin_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    resolved_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    resolved_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now(), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)