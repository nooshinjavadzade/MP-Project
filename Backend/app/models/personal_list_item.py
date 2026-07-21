from sqlalchemy import Column, Integer, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from ..core.db import Base


class PersonalListItem(Base):
    __tablename__ = "personal_list_items"

    id = Column(Integer, primary_key=True, index=True)
    list_id = Column(Integer, ForeignKey("personal_lists.id"), nullable=False)
    media_id = Column(Integer, ForeignKey("media.id"), nullable=False)

    added_at = Column(DateTime(timezone=True), server_default=func.now())

    personal_list = relationship("PersonalList", back_populates="items")
    media = relationship("Media", back_populates="list_items")
