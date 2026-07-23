from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone
from typing import List, Dict

from app.core.db import get_db
from app.core.tmdb import TMDBClient
from app.mappers.tmdb_mapper import TMDBMapper
from app.schemas.media import (
    MediaBase, MovieDetails, SeriesDetails, MediaSearchResult, Pagination
)
from app.models.media import Media

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


@router.get("/movies/{tmdb_id}", response_model=MovieDetails)
async def get_movie_details(tmdb_id: int, db: Session = Depends(get_db)):
    """Details with 24h cache"""
    media = db.query(Media).filter(Media.tmdb_id == str(tmdb_id)).first()

    if media and media.last_fetched_at and media.last_fetched_at > datetime.now(timezone.utc) - timedelta(hours=24):
        return MovieDetails.model_validate(media)

    # Fetch from TMDB
    tmdb_data = await tmdb_client.get_movie_details(tmdb_id)
    tmdb_data["media_type"] = "movie"
    await _save_or_update_media(db, tmdb_data, is_full_fetch=True)

    return TMDBMapper.to_movie_details(tmdb_data)


@router.get("/series/{tmdb_id}", response_model=SeriesDetails)
async def get_series_details(tmdb_id: int, db: Session = Depends(get_db)):
    media = db.query(Media).filter(Media.tmdb_id == str(tmdb_id)).first()

    if media and media.last_fetched_at and media.last_fetched_at > datetime.now(timezone.utc) - timedelta(hours=24):
        return SeriesDetails.model_validate(media)

    tmdb_data = await tmdb_client.get_tv_details(tmdb_id)
    tmdb_data["media_type"] = "series"
    await _save_or_update_media(db, tmdb_data, is_full_fetch=True)

    return TMDBMapper.to_series_details(tmdb_data)


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


# ==================== Helper ====================
async def _save_or_update_media(db: Session, tmdb_data: Dict, is_full_fetch: bool = False) -> Media:
    """Save or update media using TMDBMapper"""
    tmdb_id = str(tmdb_data.get("id"))
    media_obj = TMDBMapper.to_media_base(tmdb_data)

    # Check if exists
    media = db.query(Media).filter(Media.tmdb_id == tmdb_id).first()

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