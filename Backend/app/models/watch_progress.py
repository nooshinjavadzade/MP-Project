from sqlalchemy import Column, Integer, ForeignKey, Float, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from ..core.db import Base
from media import WatchStatus


class WatchProgress(Base):
    __tablename__ = "watch_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    media_id = Column(Integer, ForeignKey("media.id"), nullable=False)

    status = Column(SQLEnum(WatchStatus), nullable=True)
    progress = Column(Float, default=0.0)  # 0.0 to 100.0
    watched_episodes = Column(Integer, default=0)

    last_watched_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", backref="watch_progress")
    media = relationship("Media", back_populates="watch_progress")
