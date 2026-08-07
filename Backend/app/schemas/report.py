from pydantic import BaseModel
from datetime import datetime

from app.schemas.media import Pagination
from app.models import ReportReason, ReportStatus


class ReportCreate(BaseModel):
    reason: str
    description: str | None = None


class ReportResponseBase(BaseModel):
    id: int
    media_id: int
    reason: ReportReason
    description: str | None = None
    status: ReportStatus
    created_at: datetime

    model_config = {
        "from_attributes": True
    }


class ReportResponse(BaseModel):
    message: str
    report: ReportResponseBase

    model_config = {
        "from_attributes": True
    }


class ReportAdminUpdate(BaseModel):
    status: str
    admin_note: str | None = None


class ReportListResponse(BaseModel):
    items: list[ReportResponseBase]
    pagination: Pagination