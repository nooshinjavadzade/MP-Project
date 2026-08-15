import httpx
from fastapi import APIRouter, HTTPException, Depends, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import or_
from datetime import datetime, timedelta, timezone
from typing import List, Dict, Optional

from app.dependencies.auth import get_current_user
from app.models import (
    User, MediaType, UserRating, Review, Media,
    Season, Episode, PersonalListItem, PersonalList
)
from app.core.db import get_db
from app.core.tmdb import TMDBClient
from app.mappers.tmdb_mapper import TMDBMapper
from app.schemas.review import ReviewCreate, ReviewResponse
from app.schemas.rating import RatingCreate, RatingResponse
from app.schemas.interactions import LikeToggleResponse
from app.schemas.media import (
    MediaBase, MovieDetails, SeriesDetails, MediaSearchResult,
    Pagination, Season as SeasonSchema, Episode as EpisodeSchema
)
from app.schemas.report import ReportResponse, ReportCreate
from app.models import Report, ReportReason, ReportStatus

router = APIRouter(tags=["media"])

tmdb_client = TMDBClient()


@router.get("/search", response_model=MediaSearchResult)
async def search_media(
        query: str = Query(..., min_length=1),
        page: int = Query(1, ge=1),
        db: Session = Depends(get_db)
):
    """Search media via TMDB with fallback to cached database on failure."""
    try:
        tmdb_data = await tmdb_client.search_multi(query, page)

        results = []
        for item in tmdb_data.get("results", []):
            media_type = item.get("media_type")

            # Skip people (actors, directors, etc.)
            if media_type not in ["movie", "tv"]:
                continue

            # Normalize media_type for our system
            item["media_type"] = "series" if media_type == "tv" else "movie"

            await _save_or_update_media(db, item, is_full_fetch=False)
            results.append(TMDBMapper.to_media_base(item))

        return MediaSearchResult(
            items=results,
            pagination=Pagination(
                page=page,
                per_page=20,
                total_items=tmdb_data.get("total_results", 0),
                total_pages=tmdb_data.get("total_pages", 1),
                has_next_page=page < tmdb_data.get("total_pages", 1),
                has_previous_page=page > 1
            )
        )
    except Exception as e:
        # Fall back to cached database search for any TMDB error
        # (5xx, 401, 403, connection errors, timeouts, etc.)
        if _should_fallback_on_tmdb_error(e):
            return await _search_cached_db(db, query, page)

        # For other errors (like 400 Bad Request), re-raise
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/popular/movies", response_model=List[MediaBase])
async def get_popular_movies(page: int = 1, db: Session = Depends(get_db)):
    try:
        tmdb_data = await tmdb_client.get_popular_movies(page)
        results = []
        for item in tmdb_data.get("results", []):
            item["media_type"] = "movie"
            await _save_or_update_media(db, item)
            results.append(TMDBMapper.to_media_base(item))

        return results
    except Exception as e:
        if _should_fallback_on_tmdb_error(e):
            cached_media = await _fetch_cached_popular(db, "movie", page)
            return [TMDBMapper.to_media_base_from_orm(m) for m in cached_media]
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/popular/series", response_model=List[MediaBase])
async def get_popular_series(page: int = 1, db: Session = Depends(get_db)):
    try:
        tmdb_data = await tmdb_client.get_popular_tv(page)
        results = []
        for item in tmdb_data.get("results", []):
            item["media_type"] = "series"
            await _save_or_update_media(db, item)
            results.append(TMDBMapper.to_media_base(item))

        return results
    except Exception as e:
        if _should_fallback_on_tmdb_error(e):
            cached_media = await _fetch_cached_popular(db, "series", page)
            return [TMDBMapper.to_media_base_from_orm(m) for m in cached_media]
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/trending", response_model=List[MediaBase])
async def get_trending(media_type: str = "all", time_window: str = "week", db: Session = Depends(get_db)):
    try:
        tmdb_data = await tmdb_client.get_trending(media_type, time_window)
        results = []
        for item in tmdb_data.get("results", []):
            await _save_or_update_media(db, item)
            results.append(TMDBMapper.to_media_base(item))

        return results
    except Exception as e:
        if _should_fallback_on_tmdb_error(e):
            cached_media = await _fetch_cached_trending(db, media_type)
            return [TMDBMapper.to_media_base_from_orm(m) for m in cached_media]
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/movies/top", response_model=List[MediaBase])
async def get_top_movies(page: int = 1, db: Session = Depends(get_db)):
    try:
        tmdb_data = await tmdb_client.get_top_movies(page)
        results = []
        for item in tmdb_data.get("results", []):
            item["media_type"] = "movie"
            await _save_or_update_media(db, item)
            results.append(TMDBMapper.to_media_base(item))

        return results
    except Exception as e:
        if _should_fallback_on_tmdb_error(e):
            cached_media = await _fetch_cached_top_rated(db, "movie", page)
            return [TMDBMapper.to_media_base_from_orm(m) for m in cached_media]
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/series/top", response_model=List[MediaBase])
async def get_top_series(page: int = 1, db: Session = Depends(get_db)):
    try:
        tmdb_data = await tmdb_client.get_top_tv(page)
        results = []
        for item in tmdb_data.get("results", []):
            item["media_type"] = "series"
            await _save_or_update_media(db, item)
            results.append(TMDBMapper.to_media_base(item))

        return results
    except Exception as e:
        if _should_fallback_on_tmdb_error(e):
            cached_media = await _fetch_cached_top_rated(db, "series", page)
            return [TMDBMapper.to_media_base_from_orm(m) for m in cached_media]
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/movies/{tmdb_id}", response_model=MovieDetails)
async def get_movie_details(tmdb_id: int, db: Session = Depends(get_db)):
    """Details with 24h cache"""
    media = _get_media_by_tmdb_id_and_type(db, str(tmdb_id), "movie")

    STALE_AFTER = timedelta(days=1)
    needs_refresh = (
            media is None
            or media.last_fetched_at is None
            or media.last_fetched_at < datetime.now(timezone.utc) - STALE_AFTER
    )

    if needs_refresh:
        # Fetch from TMDB
        try:
            tmdb_data = await tmdb_client.get_media_details(tmdb_id, media_type="movie")
            tmdb_data["media_type"] = "movie"
            await _save_or_update_media(db, tmdb_data, is_full_fetch=True)
            media = _get_media_by_tmdb_id_and_type(db, str(tmdb_id), "movie")
        except Exception as e:
            # If TMDB fails and we have cached data, return it
            if _should_fallback_on_tmdb_error(e) and media:
                pass  # Use existing cached media
            elif media is None:
                # No cached data and TMDB failed
                raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                                  detail="Service temporarily unavailable. Media not in cache.")

    if media is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Movie not found")

    return MovieDetails.model_validate(media)


@router.get("/series/{tmdb_id}", response_model=SeriesDetails)
async def get_series_details(tmdb_id: int, db: Session = Depends(get_db)):
    media = _get_media_by_tmdb_id_and_type(db, str(tmdb_id), "series")

    STALE_AFTER = timedelta(days=1)
    needs_refresh = (
            media is None
            or media.last_fetched_at is None
            or media.last_fetched_at < datetime.now(timezone.utc) - STALE_AFTER
    )

    if needs_refresh:
        try:
            tmdb_data = await tmdb_client.get_media_details(tmdb_id, media_type="tv")
            print("=== RAW TMDB DATA KEYS ===", list(tmdb_data.keys()))
            print("=== seasons in raw tmdb_data ===", tmdb_data.get("seasons"))
            print("=== genres in raw tmdb_data ===", tmdb_data.get("genres"))
            tmdb_data["media_type"] = "series"
            media = await _save_or_update_media(db, tmdb_data, is_full_fetch=True)

            # فصل‌ها رو هم (بدون قسمت‌ها، چون قسمت‌ها لِیزی از endpoint جدا میان) seed کن
            for season_summary in tmdb_data.get("seasons", []):
                if season_summary.get("name") == "Specials":
                    continue
                existing_season = (
                    db.query(Season)
                    .filter(
                        Season.media_id == media.id,
                        Season.season_number == season_summary["season_number"],
                    )
                    .first()
                )
                if not existing_season:
                    poster_url = (
                        f"https://image.tmdb.org/t/p/w500{season_summary['poster_path']}"
                        if season_summary.get("poster_path")
                        else None
                    )
                    release_date = (
                        datetime.strptime(season_summary["air_date"], "%Y-%m-%d").date()
                        if season_summary.get("air_date")
                        else None
                    )
                    db.add(Season(
                        media_id=media.id,
                        season_number=season_summary["season_number"],
                        title=season_summary.get("name"),
                        overview=season_summary.get("overview"),
                        release_date=release_date,
                        tmdb_rating=season_summary.get("vote_average"),
                    ))
            db.commit()

            media = _get_media_by_tmdb_id_and_type(db, str(tmdb_id), "series")
        except Exception as e:
            if _should_fallback_on_tmdb_error(e) and media:
                pass
            elif media is None:
                raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                                  detail="Service temporarily unavailable. Media not in cache.")

    if media is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Series not found")

    return SeriesDetails.model_validate(media)


@router.post("/{media_type}/{tmdb_id}/like", response_model=LikeToggleResponse)
async def toggle_like(
    tmdb_id: str,
    media_type: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Toggle like on a media item."""
    media = _get_media_by_tmdb_id_and_type(db, tmdb_id, media_type, is_needed=True)

    liked_list = get_default_personal_list(
        db,
        current_user.id,
        "Liked",
    )

    if not liked_list:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Liked list not found."
        )

    existing_item = (
        db.query(PersonalListItem)
        .filter(
            PersonalListItem.list_id == liked_list.id,
            PersonalListItem.media_id == media.id,
        )
        .first()
    )

    if existing_item:
        db.delete(existing_item)
        db.commit()
        return LikeToggleResponse(liked=False)

    new_item = PersonalListItem(
        list_id=liked_list.id,
        media_id=media.id,
    )
    db.add(new_item)
    db.commit()

    return LikeToggleResponse(liked=True)


@router.post("/{media_type}/{tmdb_id}/rating", response_model=RatingResponse)
async def upsert_rating_media(
    tmdb_id: str,
    media_type: str,
    rating_in: RatingCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create or update a rating for a media item."""
    media = _get_media_by_tmdb_id_and_type(db, tmdb_id, media_type, is_needed=True)

    current_average = media.community_rating or 0.0
    current_count = media.community_ratings_count or 0

    existing_rating = (
        db.query(UserRating)
        .filter(
            UserRating.user_id == current_user.id,
            UserRating.media_id == media.id,
        )
        .first()
    )

    if existing_rating:
        old_rating = existing_rating.rating

        media.community_rating = round(
            (current_average * current_count - old_rating + rating_in.rating)
            / current_count,
            2
        )

        existing_rating.rating = rating_in.rating

        db.commit()
        db.refresh(existing_rating)
        return existing_rating

    new_rating = UserRating(
        user_id=current_user.id,
        media_id=media.id,
        rating=rating_in.rating,
    )

    media.community_rating = round(
        (current_average * current_count + rating_in.rating)
        / (current_count + 1),
        2
    )
    media.community_ratings_count = current_count + 1

    db.add(new_rating)
    db.commit()
    db.refresh(new_rating)

    return new_rating

@router.post("/{media_type}/{tmdb_id}/reviews", response_model=ReviewResponse)
async def create_review_movie(
    tmdb_id: str,
    media_type: str,
    review_in: ReviewCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a review for a movie"""
    media = _get_media_by_tmdb_id_and_type(db, tmdb_id, media_type, is_needed=True)

    existing_review = db.query(Review).filter(
        Review.user_id == current_user.id,
        Review.media_id == media.id
    ).first()

    if existing_review:
        existing_review.review = review_in.review
        existing_review.contains_spoiler = review_in.contains_spoiler

        db.commit()
        db.refresh(existing_review)
        return existing_review

    new_review = Review(
        user_id=current_user.id,
        media_id=media.id,
        review=review_in.review,
        contains_spoiler=review_in.contains_spoiler
    )
    db.add(new_review)
    db.commit()
    db.refresh(new_review)
    return new_review


@router.get("/{media_type}/{tmdb_id}/reviews", response_model=List[ReviewResponse])
async def get_movie_reviews(
    tmdb_id: str,
    media_type: str,
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    """Get public reviews for a movie (paginated)"""
    media = _get_media_by_tmdb_id_and_type(db, tmdb_id, media_type, is_needed=True)

    offset = (page - 1) * per_page
    reviews = db.query(Review).filter(Review.media_id == media.id).order_by(
        Review.created_at.desc()
    ).offset(offset).limit(per_page).all()

    return reviews


@router.get("/series/{tmdb_id}/season/{season_number}", response_model=SeasonSchema)
async def get_season_details(tmdb_id: int, season_number: int, db: Session = Depends(get_db)):
    media = db.query(Media).filter(Media.tmdb_id == str(tmdb_id)).first()

    STALE_AFTER = timedelta(days=1)
    needs_refresh = (
            media is None
            or media.last_fetched_at is None
            or media.last_fetched_at < datetime.now(timezone.utc) - STALE_AFTER
    )

    if needs_refresh:
        try:
            tmdb_media = await tmdb_client.get_media_details(tmdb_id, "tv")
            media = await _save_or_update_media(db, tmdb_media, is_full_fetch=True)
        except Exception as e:
            if _should_fallback_on_tmdb_error(e) and media is None:
                raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                                  detail="Service temporarily unavailable. Media not in cache.")

    if media is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Series not found")

    season = (
        db.query(Season)
        .filter(
            Season.media_id == media.id,
            Season.season_number == season_number,
        )
        .first()
    )

    if season:
        return season

    try:
        tmdb_season = await tmdb_client.get_season_details(tmdb_id, season_number)
        season = await _save_or_update_season(db, media, tmdb_season)
    except Exception as e:
        if _should_fallback_on_tmdb_error(e):
            raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                              detail="Season not available offline.")

    return season


@router.get(
    "/series/{tmdb_id}/season/{season_number}/episode/{episode_number}",
    response_model=EpisodeSchema,
)
async def get_episode_details(tmdb_id: int, season_number: int, episode_number: int, db: Session = Depends(get_db)):
    media = db.query(Media).filter(Media.tmdb_id == str(tmdb_id)).first()

    STALE_AFTER = timedelta(days=1)
    needs_refresh = (
            media is None
            or media.last_fetched_at is None
            or media.last_fetched_at < datetime.now(timezone.utc) - STALE_AFTER
    )

    if needs_refresh:
        try:
            tmdb_media = await tmdb_client.get_media_details(tmdb_id, "tv")
            media = await _save_or_update_media(db, tmdb_media, is_full_fetch=True)
        except Exception as e:
            if _should_fallback_on_tmdb_error(e) and media is None:
                raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                                  detail="Service temporarily unavailable. Media not in cache.")

    if media is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Series not found")

    episode = (
        db.query(Episode)
        .filter(
            Episode.media_id == media.id,
            Episode.season_number == season_number,
            Episode.episode_number == episode_number,
        )
        .first()
    )

    if episode:
        return episode

    try:
        tmdb_season = await tmdb_client.get_season_details(tmdb_id, season_number)
        await _save_or_update_season(db, media, tmdb_season)

        episode = (
            db.query(Episode)
            .filter(
                Episode.media_id == media.id,
                Episode.season_number == season_number,
                Episode.episode_number == episode_number,
            )
            .first()
        )
    except Exception as e:
        if _should_fallback_on_tmdb_error(e):
            raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                              detail="Episode not available offline.")

    if episode:
        return episode

    try:
        tmdb_episode = await tmdb_client.get_episode_details(
            tmdb_id,
            season_number,
            episode_number,
        )

        episode = await _save_or_update_episode(
            db,
            media,
            season_number,
            tmdb_episode,
        )
    except Exception as e:
        if _should_fallback_on_tmdb_error(e):
            raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                              detail="Episode not available offline.")

    return episode


@router.post(
    "/{media_type}/{tmdb_id}/report",
    response_model=ReportResponse,
    status_code=status.HTTP_200_OK
)
async def report_media(
    report: ReportCreate,
    media_type: str,
    tmdb_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    # Check if the media exists
    media = (
        db.query(Media)
        .filter(
            Media.tmdb_id == tmdb_id,
            Media.media_type == media_type,
        )
        .first()
    )
    if not media:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Media not found"
        )

    # Check if the user has already reported this media
    existing_report = (
        db.query(Report)
        .filter(Report.media_id == media.id, Report.user_id == user.id)
        .first()
    )
    if existing_report:
        db.delete(existing_report)
        db.commit()
        return {
            "message": "Report removed successfully.",
            "report": existing_report
        }

    # Create the report
    new_report = Report(
        media_id=media.id,
        user_id=user.id,
        reason=ReportReason(report.reason),
        description=report.description,
        status=ReportStatus.pending,
    )
    db.add(new_report)
    db.commit()
    db.refresh(new_report)

    return {
        "message": "Report created successfully.",
        "report": new_report
    }



# ==================== Helper ====================
def _get_media_by_tmdb_id_and_type(db: Session, tmdb_id: str, media_type: str, is_needed: bool = False) -> Media | None:
    """Get media by tmdb_id AND media_type to prevent cross-type confusion."""
    try :
        media = db.query(Media).filter(
            Media.tmdb_id == tmdb_id,
            Media.media_type == MediaType(media_type)
        ).first()
        if not media:
            if is_needed:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Media with type: {media_type} and tmdb_id {tmdb_id} not found.",
                )
            return None

        return media
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid media type: {media_type}. Must be 'movie' or 'series'."
        )


def get_default_personal_list(
    db: Session,
    user_id: int,
    name: str,
) -> PersonalList:
    personal_list = (
        db.query(PersonalList)
        .filter(
            PersonalList.user_id == user_id,
            PersonalList.is_default == True,
            PersonalList.name == name,
        )
        .first()
    )

    if not personal_list:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Default list '{name}' not found.",
        )

    return personal_list


async def _save_or_update_media(db: Session, tmdb_data: Dict, is_full_fetch: bool = False) -> Media:
    """Save or update media using TMDBMapper"""
    tmdb_id = str(tmdb_data.get("id"))
    media_type = tmdb_data.get("media_type")

    media_obj = TMDBMapper.to_media_base(tmdb_data)

    # Check if exists
    media = db.query(Media).filter(
        Media.tmdb_id == tmdb_id,
        Media.media_type == media_type
    ).first()

    if media:
        # Update existing record
        media.title = media_obj.title
        media.overview = tmdb_data.get("overview"),
        media.poster_url = media_obj.poster_url
        media.backdrop_url = media_obj.backdrop_url
        media.tmdb_rating = media_obj.tmdb_rating
        media.release_year = media_obj.release_year
        media.genres = [g["name"] for g in tmdb_data.get("genres", [])]
        media.original_language = tmdb_data.get("original_language")
        media.country = tmdb_data.get("origin_country")[0] \
            if tmdb_data.get("origin_country") else None

        media.runtime = tmdb_data.get("runtime")
        media.season_count = tmdb_data.get("number_of_seasons")
        media.episode_count = tmdb_data.get("number_of_episodes")
        media.cast = TMDBMapper.map_cast(tmdb_data.get("credits", {}).get("cast", []), is_media=True)
        media.status = tmdb_data.get("status", "Unknown")
        media.end_year = int(tmdb_data.get("last_air_date", "")[:4]) \
            if (tmdb_data.get("last_air_date") and tmdb_data.get("status") in ['Ended', 'Canceled']) else None,

        if is_full_fetch:
            media.last_fetched_at = datetime.now(timezone.utc)
    else:
        media = Media(
            tmdb_id=tmdb_id,
            media_type=media_obj.media_type,
            title=media_obj.title,
            original_title=tmdb_data.get("original_title") or tmdb_data.get("original_name"),
            poster_url=media_obj.poster_url,
            backdrop_url=media_obj.backdrop_url,
            overview=tmdb_data.get("overview"),
            release_year=media_obj.release_year,
            tmdb_rating=media_obj.tmdb_rating,
            genres=[g["name"] for g in tmdb_data.get("genres", [])],
            original_language=tmdb_data.get("original_language"),
            country=tmdb_data.get("origin_country")[0] \
                if tmdb_data.get("origin_country") else None,

            runtime=tmdb_data.get("runtime"),
            season_count=tmdb_data.get("number_of_seasons"),
            episode_count=tmdb_data.get("number_of_episodes"),
            cast=TMDBMapper.map_cast(tmdb_data.get("credits", {}).get("cast", []), is_media=True),
            status=tmdb_data.get("status", "Unknown"),
            end_year=int(tmdb_data.get("last_air_date", "")[:4]) \
                if (tmdb_data.get("last_air_date") and tmdb_data.get("status") in ['Ended', 'Canceled']) else None,

            last_fetched_at=datetime.now(timezone.utc) if is_full_fetch else None
        )
        db.add(media)

    db.commit()
    db.refresh(media)
    return media


async def _save_or_update_season(
    db: Session,
    media: Media,
    tmdb_data: Dict,
) -> Season:
    """Create or update a season from TMDB data."""

    season_number = tmdb_data["season_number"]

    season = (
        db.query(Season)
        .filter(
            Season.media_id == media.id,
            Season.season_number == season_number,
        )
        .first()
    )

    poster_url = (
        f"https://image.tmdb.org/t/p/w500{tmdb_data['poster_path']}"
        if tmdb_data.get("poster_path")
        else None
    )

    release_date = (
        datetime.strptime(tmdb_data["air_date"], "%Y-%m-%d").date()
        if tmdb_data.get("air_date")
        else None
    )

    if season:
        season.title = tmdb_data.get("name")
        season.overview = tmdb_data.get("overview")
        season.release_date = release_date
        season.tmdb_rating = tmdb_data.get("vote_average")
    else:
        season = Season(
            media_id=media.id,
            season_number=season_number,
            title=tmdb_data.get("name"),
            overview=tmdb_data.get("overview"),
            release_date=release_date,
            tmdb_rating=tmdb_data.get("vote_average"),
        )

        db.add(season)

    db.flush()

    for episode_data in tmdb_data.get("episodes", []):
        await _save_or_update_episode(
            db,
            media,
            season_number,
            episode_data,
            commit=False,
        )

    db.commit()
    db.refresh(season)

    return season


async def _save_or_update_episode(
    db: Session,
    media: Media,
    season_number: int,
    tmdb_data: Dict,
    commit: bool = True,
) -> Episode:
    """Create or update an episode from TMDB data."""

    episode_number = tmdb_data["episode_number"]

    episode = (
        db.query(Episode)
        .filter(
            Episode.media_id == media.id,
            Episode.season_number == season_number,
            Episode.episode_number == episode_number,
        )
        .first()
    )

    still_url = (
        f"https://image.tmdb.org/t/p/w500{tmdb_data['still_path']}"
        if tmdb_data.get("still_path")
        else None
    )

    air_date = (
        datetime.strptime(tmdb_data["air_date"], "%Y-%m-%d").date()
        if tmdb_data.get("air_date")
        else None
    )

    if episode:
        episode.title = tmdb_data.get("name")
        episode.overview = tmdb_data.get("overview")
        episode.runtime = tmdb_data.get("runtime")
        episode.release_date = air_date
        episode.tmdb_rating = tmdb_data.get("vote_average")
    else:
        episode = Episode(
            media_id=media.id,
            season_number=season_number,
            episode_number=episode_number,
            title=tmdb_data.get("name"),
            overview=tmdb_data.get("overview"),
            runtime=tmdb_data.get("runtime"),
            release_date=air_date,
            tmdb_rating=tmdb_data.get("vote_average"),
        )

        db.add(episode)

    if commit:
        db.commit()
        db.refresh(episode)

    return episode


async def _search_cached_db(db: Session, query: str, page: int = 1, per_page: int = 20) -> MediaSearchResult:
    """Search cached media in local database as fallback when TMDB is unavailable."""
    search_term = f"%{query}%"

    # Query local database for matching media
    db_query = db.query(Media).filter(
        or_(
            Media.title.ilike(search_term),
            Media.original_title.ilike(search_term)
        )
    ).order_by(Media.tmdb_rating.desc().nullslast())

    total_items = db_query.count()
    total_pages = (total_items + per_page - 1) // per_page if total_items > 0 else 1

    offset = (page - 1) * per_page
    media_items = db_query.offset(offset).limit(per_page).all()

    results = [TMDBMapper.to_media_base_from_orm(media) for media in media_items]

    return MediaSearchResult(
        items=results,
        pagination=Pagination(
            page=page,
            per_page=per_page,
            total_items=total_items,
            total_pages=total_pages,
            has_next_page=page < total_pages,
            has_previous_page=page > 1
        )
    )


def _should_fallback_on_tmdb_error(e: Exception) -> bool:
    """
    Determine if a TMDB error should trigger fallback to cached database.

    Fallback occurs for:
    - 5xx server errors
    - 401 Unauthorized (invalid API key)
    - 403 Forbidden (access denied)
    - Connection errors, timeouts, network issues
    """
    if isinstance(e, httpx.HTTPStatusError):
        status_code = e.response.status_code
        return status_code >= 500 or status_code in (401, 403)
    elif isinstance(e, httpx.RequestError):
        # Connection errors, timeouts, DNS failures, etc.
        return True
    return False


async def _fetch_cached_media(db: Session, tmdb_id: str, media_type: str) -> Optional[Media]:
    """Fetch media from local cache by TMDB ID and type."""
    return _get_media_by_tmdb_id_and_type(db, tmdb_id, media_type)


async def _fetch_cached_top_rated(db: Session, media_type: str, page: int = 1, per_page: int = 20) -> List[Media]:
    """Fetch cached top-rated media from local database."""
    offset = (page - 1) * per_page
    return db.query(Media).filter(
        Media.media_type == MediaType(media_type)
    ).order_by(Media.tmdb_rating.desc().nullslast()).offset(offset).limit(per_page).all()


async def _fetch_cached_popular(db: Session, media_type: str, page: int = 1, per_page: int = 20) -> List[Media]:
    """Fetch cached popular media from local database."""
    offset = (page - 1) * per_page
    return db.query(Media).filter(
        Media.media_type == MediaType(media_type)
    ).order_by(Media.tmdb_rating.desc().nullslast()).offset(offset).limit(per_page).all()


async def _fetch_cached_trending(db: Session, media_type: str = "all", per_page: int = 20) -> List[Media]:
    """Fetch cached trending media from local database."""
    query = db.query(Media).order_by(Media.tmdb_rating.desc().nullslast())

    if media_type != "all":
        query = query.filter(Media.media_type == MediaType(media_type))

    return query.limit(per_page).all()