from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List

from app.core.db import get_db
from app.dependencies.auth import get_current_user
from app.models import User, UserRating, Review, Media, PersonalListItem
from app.schemas.review import ReviewUpdate, ReviewResponse
from app.schemas.rating import RatingResponse
from app.schemas.media import MediaBase

from .media import get_default_personal_list


router = APIRouter(tags=["profile"])


@router.get("/likes", response_model=List[MediaBase])
async def get_user_likes(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get authenticated user's liked media (paginated)."""
    offset = (page - 1) * per_page

    liked_list = get_default_personal_list(
        db,
        current_user.id,
        "Liked",
    )

    if not liked_list:
        return []

    list_items = (
        db.query(PersonalListItem)
        .filter(PersonalListItem.list_id == liked_list.id)
        .order_by(PersonalListItem.added_at.desc())
        .offset(offset)
        .limit(per_page)
        .all()
    )

    media_ids = [item.media_id for item in list_items]
    if not media_ids:
        return []

    media_items = db.query(Media).filter(Media.id.in_(media_ids)).all()

    # Preserve order
    media_map = {media.id: media for media in media_items}
    return [media_map[mid] for mid in media_ids if mid in media_map]


@router.get("/ratings", response_model=List[RatingResponse])
async def get_user_ratings(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get authenticated user's ratings (paginated)"""
    offset = (page - 1) * per_page
    ratings = db.query(UserRating).filter(UserRating.user_id == current_user.id).order_by(
        UserRating.rated_at.desc()
    ).offset(offset).limit(per_page).all()

    return ratings


@router.get("/reviews", response_model=List[ReviewResponse])
async def get_user_reviews(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get authenticated user's reviews (paginated)"""
    offset = (page - 1) * per_page
    reviews = db.query(Review).filter(Review.user_id == current_user.id).order_by(
        Review.created_at.desc()
    ).offset(offset).limit(per_page).all()

    return reviews


@router.patch("/reviews/{review_id}", response_model=ReviewResponse)
async def update_review(
    review_id: int,
    review_update: ReviewUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update own review"""
    review = db.query(Review).filter(Review.id == review_id).first()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")

    if review.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to update this review")

    if review_update.review is not None:
        review.review = review_update.review
    if review_update.contains_spoiler is not None:
        review.contains_spoiler = review_update.contains_spoiler

    db.commit()
    db.refresh(review)
    return review


@router.delete("/reviews/{review_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_review(
    review_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete own review"""
    review = db.query(Review).filter(Review.id == review_id).first()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")

    if review.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this review")

    db.delete(review)
    db.commit()
