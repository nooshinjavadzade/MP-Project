from datetime import datetime, timedelta, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import func, or_
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.core.tmdb import TMDBClient
from app.dependencies.admin import get_current_admin
from app.models import (
    User,
    Review,
    Report,
    Media,
    UserRating,
    PersonalList,
    MediaType,
)
from app.models.report import ReportStatus
from app.schemas.admin import (
    AdminUserResponse,
    AdminUserUpdate,
    AdminUserListResponse,
    AdminReviewResponse,
    AdminReviewListResponse,
    AdminReportResponse,
    AdminReportUpdate,
    AdminReportListResponse,
    CachedMediaResponse,
    CachedMediaListResponse,
    AdminStats,
    AdminActionResponse,
)
from app.schemas.media import Pagination
from app.api.v1.media import _save_or_update_media


router = APIRouter(tags=["admin"])

tmdb_client = TMDBClient()

STALE_AFTER = timedelta(days=1)


# ---------------------------------------------------------------------------
# Audit helper (extend the one you already have in verification.py)
# ---------------------------------------------------------------------------
def log_admin_action(
    db: Session,
    admin: User,
    action: str,
    target_type: str,
    target_id: int | str | None = None,
    details: str | None = None,
    ip: str | None = None,
):
    import logging
    logger = logging.getLogger("admin_audit")
    logger.info(
        f"ADMIN_ACTION admin_id={admin.id} admin={admin.username} "
        f"action={action} target_type={target_type} target_id={target_id} "
        f"details={details} ip={ip}"
    )
    # TODO: persist to an AdminAuditLog table when you add one


# ---------------------------------------------------------------------------
# USER MANAGEMENT
# ---------------------------------------------------------------------------

@router.get("/users", response_model=AdminUserListResponse)
async def list_users(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    is_active: Optional[bool] = Query(None),
    is_admin: Optional[bool] = Query(None),
    search: Optional[str] = Query(None, min_length=1),
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    q = db.query(User)

    if is_active is not None:
        q = q.filter(User.is_active == is_active)
    if is_admin is not None:
        q = q.filter(User.is_admin == is_admin)
    if search:
        term = f"%{search}%"
        q = q.filter(or_(User.username.ilike(term), User.email.ilike(term)))

    total = q.count()
    users = (
        q.order_by(User.created_at.desc())
        .offset((page - 1) * per_page)
        .limit(per_page)
        .all()
    )

    return AdminUserListResponse(
        items=[AdminUserResponse.model_validate(u) for u in users],
        pagination=Pagination(
            page=page,
            per_page=per_page,
            total_items=total,
            total_pages=(total + per_page - 1) // per_page if total else 0,
            has_next_page=page * per_page < total,
            has_previous_page=page > 1,
        ),
    )


@router.patch("/users/{user_id}", response_model=AdminUserResponse)
async def update_user(
    user_id: int,
    body: AdminUserUpdate,
    request: Request,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    # Prevent admin from demoting/deactivating themselves
    if user.id == admin.id:
        if body.is_admin is False:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You cannot remove your own admin privileges",
            )
        if body.is_active is False:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You cannot deactivate your own account",
            )

    changes = []
    if body.is_active is not None and body.is_active != user.is_active:
        user.is_active = body.is_active
        changes.append(f"is_active={body.is_active}")
    if body.is_admin is not None and body.is_admin != user.is_admin:
        user.is_admin = body.is_admin
        changes.append(f"is_admin={body.is_admin}")

    if not changes:
        return AdminUserResponse.model_validate(user)

    db.commit()
    db.refresh(user)

    log_admin_action(
        db,
        admin,
        action="update_user",
        target_type="user",
        target_id=user_id,
        details=", ".join(changes),
        ip=request.client.host if request.client else None,
    )
    return AdminUserResponse.model_validate(user)


@router.delete("/users/{user_id}", response_model=AdminActionResponse)
async def delete_user(
    user_id: int,
    hard_delete: bool = Query(False, description="If true, permanently delete. Default is soft-delete."),
    request: Request = None,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    if user.id == admin.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot delete your own account via the admin panel",
        )

    if hard_delete:
        db.delete(user)
        action = "hard_delete_user"
        msg = "User permanently deleted"
    else:
        user.is_active = False
        action = "soft_delete_user"
        msg = "User deactivated (soft delete)"

    db.commit()

    log_admin_action(
        db,
        admin,
        action=action,
        target_type="user",
        target_id=user_id,
        ip=request.client.host if request.client else None,
    )
    return AdminActionResponse(message=msg)


# ---------------------------------------------------------------------------
# REVIEW MODERATION
# ---------------------------------------------------------------------------

@router.get("/reviews", response_model=AdminReviewListResponse)
async def list_reviews(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    contains_spoiler: Optional[bool] = Query(None),
    media_id: Optional[int] = Query(None),
    user_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    q = db.query(Review)

    if contains_spoiler is not None:
        q = q.filter(Review.contains_spoiler == contains_spoiler)
    if media_id is not None:
        q = q.filter(Review.media_id == media_id)
    if user_id is not None:
        q = q.filter(Review.user_id == user_id)

    total = q.count()
    reviews = (
        q.order_by(Review.created_at.desc())
        .offset((page - 1) * per_page)
        .limit(per_page)
        .all()
    )

    return AdminReviewListResponse(
        items=[AdminReviewResponse.model_validate(r) for r in reviews],
        pagination=Pagination(
            page=page,
            per_page=per_page,
            total_items=total,
            total_pages=(total + per_page - 1) // per_page if total else 0,
            has_next_page=page * per_page < total,
            has_previous_page=page > 1,
        ),
    )


@router.delete("/reviews/{review_id}", response_model=AdminActionResponse)
async def delete_review(
    review_id: int,
    request: Request,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    review = db.query(Review).filter(Review.id == review_id).first()
    if not review:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Review not found")

    db.delete(review)
    db.commit()

    log_admin_action(
        db,
        admin,
        action="delete_review",
        target_type="review",
        target_id=review_id,
        ip=request.client.host if request.client else None,
    )
    return AdminActionResponse(message="Review deleted")


# ---------------------------------------------------------------------------
# REPORTS
# ---------------------------------------------------------------------------

@router.get("/reports", response_model=AdminReportListResponse)
async def list_reports(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    status_filter: Optional[ReportStatus] = Query(None, alias="status"),
    media_id: Optional[int] = Query(None),
    reporter_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    q = db.query(Report)

    if status_filter is not None:
        q = q.filter(Report.status == status_filter)
    if media_id is not None:
        q = q.filter(Report.media_id == media_id)
    if reporter_id is not None:
        q = q.filter(Report.user_id == reporter_id)

    total = q.count()
    reports = (
        q.order_by(Report.created_at.desc())
        .offset((page - 1) * per_page)
        .limit(per_page)
        .all()
    )

    return AdminReportListResponse(
        items=[AdminReportResponse.model_validate(r) for r in reports],
        pagination=Pagination(
            page=page,
            per_page=per_page,
            total_items=total,
            total_pages=(total + per_page - 1) // per_page if total else 0,
            has_next_page=page * per_page < total,
            has_previous_page=page > 1,
        ),
    )


@router.patch("/reports/{report_id}", response_model=AdminReportResponse)
async def update_report(
    report_id: int,
    body: AdminReportUpdate,
    request: Request,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    report = db.query(Report).filter(Report.id == report_id).first()
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Report not found")

    report.status = body.status
    if body.admin_note is not None:
        report.admin_note = body.admin_note

    if body.status in (ReportStatus.resolved, ReportStatus.dismissed):
        report.resolved_by = admin.id
        report.resolved_at = datetime.now(timezone.utc)

    db.commit()
    db.refresh(report)

    log_admin_action(
        db,
        admin,
        action="update_report",
        target_type="report",
        target_id=report_id,
        details=f"status={body.status.value}",
        ip=request.client.host if request.client else None,
    )
    return AdminReportResponse.model_validate(report)


# ---------------------------------------------------------------------------
# MEDIA CACHE MANAGEMENT
# ---------------------------------------------------------------------------

@router.get("/media", response_model=CachedMediaListResponse)
async def list_cached_media(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    stale_only: bool = Query(False),
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    now = datetime.now(timezone.utc)
    stale_cutoff = now - STALE_AFTER

    q = db.query(Media)

    if stale_only:
        q = q.filter(
            or_(
                Media.last_fetched_at.is_(None),
                Media.last_fetched_at < stale_cutoff,
            )
        )

    total = q.count()
    media_items = (
        q.order_by(Media.last_fetched_at.asc().nullsfirst())
        .offset((page - 1) * per_page)
        .limit(per_page)
        .all()
    )

    items = []
    for m in media_items:
        is_stale = (
            m.last_fetched_at is None
            or m.last_fetched_at < stale_cutoff
        )
        items.append(
            CachedMediaResponse(
                id=m.id,
                tmdb_id=m.tmdb_id,
                media_type=m.media_type.value,
                title=m.title,
                last_fetched_at=m.last_fetched_at,
                stale=is_stale,
            )
        )

    return CachedMediaListResponse(
        items=items,
        pagination=Pagination(
            page=page,
            per_page=per_page,
            total_items=total,
            total_pages=(total + per_page - 1) // per_page if total else 0,
            has_next_page=page * per_page < total,
            has_previous_page=page > 1,
        ),
    )


@router.post("/media/{media_id}/refresh", response_model=AdminActionResponse)
async def refresh_media(
    media_id: int,
    request: Request,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    media = db.query(Media).filter(Media.id == media_id).first()
    if not media:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Media not found")

    tmdb_type = "tv" if media.media_type == MediaType.series else "movie"
    tmdb_data = await tmdb_client.get_media_details(int(media.tmdb_id), media_type=tmdb_type)
    tmdb_data["media_type"] = media.media_type.value

    await _save_or_update_media(db, tmdb_data, is_full_fetch=True)

    log_admin_action(
        db,
        admin,
        action="refresh_media",
        target_type="media",
        target_id=media_id,
        ip=request.client.host if request.client else None,
    )
    return AdminActionResponse(message=f"Media '{media.title}' refreshed from TMDB")


@router.delete("/media/{media_id}", response_model=AdminActionResponse)
async def delete_cached_media(
    media_id: int,
    request: Request,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    media = db.query(Media).filter(Media.id == media_id).first()
    if not media:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Media not found")

    title = media.title
    db.delete(media)  # cascades to seasons/episodes/reviews/ratings/list_items via model
    db.commit()

    log_admin_action(
        db,
        admin,
        action="delete_media",
        target_type="media",
        target_id=media_id,
        details=f"title={title}",
        ip=request.client.host if request.client else None,
    )
    return AdminActionResponse(message=f"Cached media '{title}' deleted")


# ---------------------------------------------------------------------------
# SYSTEM STATS
# ---------------------------------------------------------------------------

@router.get("/stats", response_model=AdminStats)
async def get_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    if not admin.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )

    now = datetime.now(timezone.utc)
    thirty_days_ago = now - timedelta(days=30)

    total_users = db.query(func.count(User.id)).scalar() or 0
    active_users_30d = (
        db.query(func.count(User.id))
        .filter(User.is_active == True, User.updated_at >= thirty_days_ago)
        .scalar()
        or 0
    )
    # Fallback if updated_at is rarely set: use created_at for very new users
    # Better approximation if you track last_login later.

    total_media = db.query(func.count(Media.id)).scalar() or 0
    total_reviews = db.query(func.count(Review.id)).scalar() or 0
    total_ratings = db.query(func.count(UserRating.id)).scalar() or 0
    total_lists = db.query(func.count(PersonalList.id)).scalar() or 0
    reports_pending = (
        db.query(func.count(Report.id))
        .filter(Report.status == ReportStatus.pending)
        .scalar()
        or 0
    )

    return AdminStats(
        total_users=total_users,
        active_users_30d=active_users_30d,
        total_media_cached=total_media,
        total_reviews=total_reviews,
        total_ratings=total_ratings,
        total_lists=total_lists,
        reports_pending=reports_pending,
        tmdb_calls=None,  # wire this if you add a counter in TMDBClient
    )