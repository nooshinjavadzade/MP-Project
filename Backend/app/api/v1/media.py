from fastapi import APIRouter, HTTPException, Depends, Query, status
from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone
from typing import List, Dict

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


router = APIRouter(tags=["media"])

tmdb_client = TMDBClient()


@router.get("/search", response_model=MediaSearchResult)
async def search_media(
        query: str = Query(..., min_length=1),
        page: int = Query(1, ge=1),
        db: Session = Depends(get_db)
):
    """Search + Save to DB"""
    try:
        tmdb_data = await tmdb_client.search_multi(query, page)
    except Exception as e:
        return {"error": str(e)}

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


@router.get("/popular/movies", response_model=List[MediaBase])
async def get_popular_movies(page: int = 1, db: Session = Depends(get_db)):
    tmdb_data = await tmdb_client.get_popular_movies(page)
    results = []
    for item in tmdb_data.get("results", []):
        item["media_type"] = "movie"
        await _save_or_update_media(db, item)
        results.append(TMDBMapper.to_media_base(item))

    return results


@router.get("/popular/series", response_model=List[MediaBase])
async def get_popular_series(page: int = 1, db: Session = Depends(get_db)):
    tmdb_data = await tmdb_client.get_popular_tv(page)
    results = []
    for item in tmdb_data.get("results", []):
        item["media_type"] = "series"
        await _save_or_update_media(db, item)
        results.append(TMDBMapper.to_media_base(item))

    return results


@router.get("/trending", response_model=List[MediaBase])
async def get_trending(media_type: str = "all", time_window: str = "week", db: Session = Depends(get_db)):
    tmdb_data = await tmdb_client.get_trending(media_type, time_window)
    results = []
    for item in tmdb_data.get("results", []):
        await _save_or_update_media(db, item)
        results.append(TMDBMapper.to_media_base(item))

    return results


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
        tmdb_data = await tmdb_client.get_media_details(tmdb_id, media_type="movie")
        tmdb_data["media_type"] = "movie"
        await _save_or_update_media(db, tmdb_data, is_full_fetch=True)

        return TMDBMapper.to_movie_details(tmdb_data)

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
        tmdb_data = await tmdb_client.get_media_details(tmdb_id, media_type="tv")
        print('hi')
        tmdb_data["media_type"] = "series"
        await _save_or_update_media(db, tmdb_data, is_full_fetch=True)

        return TMDBMapper.to_series_details(tmdb_data)

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
        tmdb_media = await tmdb_client.get_media_details(tmdb_id, "tv")
        media = await _save_or_update_media(db, tmdb_media, is_full_fetch=True)

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

    tmdb_season = await tmdb_client.get_season_details(tmdb_id, season_number)

    season = await _save_or_update_season(db, media, tmdb_season)

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
        tmdb_media = await tmdb_client.get_media_details(tmdb_id, "tv")
        media = await _save_or_update_media(db, tmdb_media, is_full_fetch=True)

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

    tmdb_season = await tmdb_client.get_season_details(tmdb_id, season_number)
    season = await _save_or_update_season(db, media, tmdb_season)

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

    return episode



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
        media.overview = media_obj.overview
        media.poster_url = media_obj.poster_url
        media.backdrop_url = media_obj.backdrop_url
        media.tmdb_rating = media_obj.tmdb_rating
        media.release_year = media_obj.release_year
        media.genres = media_obj.genres
        media.original_language = media_obj.original_language
        media.country = media_obj.country \
            if media_obj.country else tmdb_data.get("origin_country")[0] \
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
            original_title=media_obj.original_title,
            poster_url=media_obj.poster_url,
            backdrop_url=media_obj.backdrop_url,
            overview=media_obj.overview,
            release_year=media_obj.release_year,
            tmdb_rating=media_obj.tmdb_rating,
            genres=media_obj.genres,
            original_language=media_obj.original_language,
            country=media_obj.country \
                if media_obj.country else tmdb_data.get("origin_country")[0] \
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