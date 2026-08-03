from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List

from app.core.db import get_db
from app.dependencies.auth import get_current_user
from app.models import User, UserRating, Review, Media, PersonalListItem, PersonalList, Like, WatchProgress
from app.schemas.review import ReviewUpdate, ReviewResponse
from app.schemas.rating import RatingResponse
from app.schemas.media import MediaBase
from app.schemas.user import UserResponse, UserUpdate, ProfileResponse, PublicProfileResponse
from app.services.profile import get_profile_stats, get_recent_liked_media, get_public_profile_stats

from .media import get_default_personal_list


router = APIRouter(tags=["profile"])


@router.get("/", response_model=ProfileResponse)
async def get_user_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get authenticated user's full profile with stats"""
    stats = get_profile_stats(db, current_user.id)
    liked_media = get_recent_liked_media(db, current_user.id, limit=20)
    
    # Build response
    response = ProfileResponse.model_validate(current_user)
    response.watched_movies_count = stats["watched_movies_count"]
    response.watched_series_count = stats["watched_series_count"]
    response.liked_media = liked_media
    response.ratings_count = stats["ratings_count"]
    response.reviews_count = stats["reviews_count"]
    response.lists_count = stats["lists_count"]
    
    return response


@router.get("/{user_id}", response_model=PublicProfileResponse)
async def get_public_profile(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get public profile of another user with stats"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if not user.is_active:
        raise HTTPException(status_code=404, detail="User not found")
    
    stats = get_public_profile_stats(db, user_id)
    liked_media = get_recent_liked_media(db, user_id, limit=20)
    
    # Build response (excludes email, is_admin, is_verified)
    response = PublicProfileResponse.model_validate(user)
    response.watched_movies_count = stats["watched_movies_count"]
    response.watched_series_count = stats["watched_series_count"]
    response.liked_media = liked_media
    response.ratings_count = stats["ratings_count"]
    response.reviews_count = stats["reviews_count"]
    response.lists_count = stats["lists_count"]
    
    return response


@router.patch("/", response_model=UserResponse)
async def update_user(
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Only allow updating bio, avatar_url, full_name
    # Email and username changes require separate verified flow
    if user_update.bio is not None:
        current_user.bio = user_update.bio
    if user_update.avatar_url is not None:
        # Validate avatar URL is HTTPS
        if user_update.avatar_url and not user_update.avatar_url.startswith("https://"):
            raise HTTPException(status_code=400, detail="Avatar URL must use HTTPS")
        if user_update.avatar_url and len(user_update.avatar_url) > 255:
            raise HTTPException(status_code=400, detail="Avatar URL too long (max 255 characters)")
        current_user.avatar_url = user_update.avatar_url
    if user_update.full_name is not None:
        current_user.full_name = user_update.full_name

    db.commit()
    db.refresh(current_user)
    return current_user


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
