from datetime import datetime
from typing import List
from pydantic import BaseModel, ConfigDict

from app.models.report import ReportStatus, ReportReason
from app.schemas.media import Pagination


# ---------- Users ----------

class AdminUserResponse(BaseModel):
    id: int
    username: str
    email: str
    full_name: str | None = None
    avatar_url: str | None = None
    bio: str | None = None
    is_admin: bool
    is_active: bool
    is_verified: bool
    created_at: datetime
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class AdminUserUpdate(BaseModel):
    is_active: bool | None = None
    is_admin: bool | None = None


class AdminUserListResponse(BaseModel):
    items: List[AdminUserResponse]
    pagination: Pagination


class AdminUserDeleteRequest(BaseModel):
    hard_delete: bool = False  # default soft-delete


# ---------- Reviews ----------

class AdminReviewResponse(BaseModel):
    id: int
    user_id: int
    media_id: int
    review: str
    contains_spoiler: bool
    created_at: datetime
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class AdminReviewListResponse(BaseModel):
    items: List[AdminReviewResponse]
    pagination: Pagination


# ---------- Reports ----------

class AdminReportResponse(BaseModel):
    id: int
    media_id: int
    user_id: int  # reporter
    reason: ReportReason
    description: str | None = None
    status: ReportStatus
    admin_note: str | None = None
    resolved_by: int | None = None
    resolved_at: datetime | None = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class AdminReportUpdate(BaseModel):
    status: ReportStatus
    admin_note: str | None = None


class AdminReportListResponse(BaseModel):
    items: List[AdminReportResponse]
    pagination: Pagination


# ---------- Media cache ----------

class CachedMediaResponse(BaseModel):
    id: int
    tmdb_id: str
    media_type: str
    title: str
    last_fetched_at: datetime | None = None
    stale: bool

    model_config = ConfigDict(from_attributes=True)


class CachedMediaListResponse(BaseModel):
    items: List[CachedMediaResponse]
    pagination: Pagination


# ---------- Stats ----------

class AdminStats(BaseModel):
    total_users: int
    active_users_30d: int
    total_media_cached: int
    total_reviews: int
    total_ratings: int
    total_lists: int
    reports_pending: int
    tmdb_calls: int | None = None  # only if you track it


# ---------- Generic ----------

class AdminActionResponse(BaseModel):
    message: str