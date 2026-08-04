from pydantic import BaseModel


class ReportCreate(BaseModel):
    media_id: int
    reason: str
    description: str | None = None


class ReportResponse(BaseModel):
    id: int
    media_id: int
    reason: str
    description: str | None = None
    status: str
    created_at: str


class ReportAdminUpdate(BaseModel):
    status: str
    admin_note: str | None = None