from sqlalchemy import func, select
from sqlalchemy.orm import Session
from typing import List, Optional

from app.models import User, Media, PersonalList, UserRating, Review, WatchProgress, Like, PersonalListItem
from app.models.media import MediaType, WatchStatus


def get_profile_stats(db: Session, user_id: int) -> dict:
    # Watched movies: WatchProgress where status=completed AND media.media_type=movie
    watched_movies = db.query(func.count(WatchProgress.id)).join(Media).filter(
        WatchProgress.user_id == user_id,
        WatchProgress.status == WatchStatus.completed,
        Media.media_type == MediaType.movie
    ).scalar() or 0

    # Watched series: WatchProgress where status=completed AND media.media_type=series
    watched_series = db.query(func.count(WatchProgress.id)).join(Media).filter(
        WatchProgress.user_id == user_id,
        WatchProgress.status == WatchStatus.completed,
        Media.media_type == MediaType.series
    ).scalar() or 0

    # Liked media count
    liked_count = db.query(func.count(Like.id)).filter(Like.user_id == user_id).scalar() or 0

    # Ratings count
    ratings_count = db.query(func.count(UserRating.id)).filter(UserRating.user_id == user_id).scalar() or 0

    # Reviews count
    reviews_count = db.query(func.count(Review.id)).filter(Review.user_id == user_id).scalar() or 0

    # Lists count (including default lists)
    lists_count = db.query(func.count(PersonalList.id)).filter(PersonalList.user_id == user_id).scalar() or 0

    return {
        "watched_movies_count": watched_movies,
        "watched_series_count": watched_series,
        "liked_media_count": liked_count,
        "ratings_count": ratings_count,
        "reviews_count": reviews_count,
        "lists_count": lists_count,
    }


def get_recent_liked_media(db: Session, user_id: int, limit: int = 20) -> List[Media]:
    # Get liked media through the Like model (direct likes)
    liked_media = db.query(Media).join(Like).filter(
        Like.user_id == user_id
    ).order_by(Like.created_at.desc()).limit(limit).all()

    return liked_media


def get_public_profile_stats(db: Session, user_id: int) -> dict:
    return get_profile_stats(db, user_id)