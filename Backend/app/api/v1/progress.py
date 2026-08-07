from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.dependencies.auth import get_current_user
from app.models import User, Media
from app.models.episode_watch_progress import EpisodeWatchProgress
from app.schemas.progress import (
    EpisodeProgressCreate, EpisodeProgressUpdate, EpisodeProgressUpdateResponse,
    MovieProgressCreate,
    MovieProgressResponse, SeriesProgressResponse
)
from app.services.progress import (
    update_episode_progress,
    get_series_progress,
    upsert_movie_progress,
    get_movie_progress
)

router = APIRouter(tags=["progress"])


@router.post("/movies/{tmdb_id}", response_model=MovieProgressResponse)
async def upsert_movie_progress_endpoint(
    tmdb_id: int,
    progress_in: MovieProgressCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Upsert movie watch progress (status + progress 0-100%)."""
    # Verify media exists and is a movie
    media = db.query(Media).filter(Media.tmdb_id == str(tmdb_id), Media.media_type == "movie").first()
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    if media.media_type.value != "movie":
        raise HTTPException(status_code=400, detail="Media must be a movie")

    wp = upsert_movie_progress(current_user.id, media.id, progress_in.status, progress_in.progress, db)
    return wp


@router.get("/movies/{tmdb_id}", response_model=MovieProgressResponse)
async def get_movie_progress_endpoint(
    tmdb_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get movie progress for current user."""
    wp = get_movie_progress(current_user.id, tmdb_id, "movie", db)
    if not wp:
        raise HTTPException(status_code=404, detail="Progress not found")
    return wp


@router.post(
    "/series/{tmdb_id}/episodes",
    response_model=EpisodeProgressUpdateResponse
)
async def upsert_episode_progress_endpoint(
    tmdb_id: int,
    progress_in: EpisodeProgressCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Upsert single episode progress."""
    # Verify media exists and is a series
    media = db.query(Media).filter(Media.tmdb_id == str(tmdb_id), Media.media_type == "series").first()
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    if media.media_type.value != "series":
        raise HTTPException(status_code=400, detail="Media must be a series")

    ep = update_episode_progress(
        current_user.id,
        media.id,
        progress_in.season_number,
        progress_in.episode_number,
        progress_in.status,
        db
    )
    
    return {"message": "Episode progress updated", "episode": ep}


@router.get("/series/{tmdb_id}", response_model=SeriesProgressResponse)
async def get_series_progress_endpoint(
    tmdb_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get aggregated series progress for current user."""
    progress = await get_series_progress(current_user.id, tmdb_id, db)
    if not progress:
        raise HTTPException(status_code=404, detail="Series not found or no progress")
    return progress


@router.patch("/series/{tmdb_id}/episodes/{season_number}/{episode_number}", response_model=EpisodeProgressUpdateResponse)
async def update_single_episode_progress(
    tmdb_id: int,
    season_number: int,
    episode_number: int,
    progress_in: EpisodeProgressUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update single episode progress."""
    media = db.query(Media).filter(Media.tmdb_id == str(tmdb_id), Media.media_type == "series").first()
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    if media.media_type.value != "series":
        raise HTTPException(status_code=400, detail="Media must be a series")

    if progress_in.status is None:
        raise HTTPException(status_code=400, detail="Status is required")

    ep = update_episode_progress(
        current_user.id,
        media.id,
        season_number,
        episode_number,
        progress_in.status,
        db
    )
    return {"message": "Episode progress updated", "episode": ep}


@router.get("/series/{tmdb_id}/episodes/{season_number}/{episode_number}", response_model=EpisodeProgressUpdateResponse)
async def update_single_episode_progress(
    tmdb_id: int,
    season_number: int,
    episode_number: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get single episode progress."""
    media = db.query(Media).filter(Media.tmdb_id == str(tmdb_id), Media.media_type == "series").first()
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    if media.media_type.value != "series":
        raise HTTPException(status_code=400, detail="Media must be a series")

    ep = db.query(EpisodeWatchProgress).filter(
        EpisodeWatchProgress.user_id == current_user.id,
        EpisodeWatchProgress.media_id == media.id,
        EpisodeWatchProgress.season_number == season_number,
        EpisodeWatchProgress.episode_number == episode_number
    ).first()
    
    if not ep:
        raise HTTPException(status_code=404, detail="Episode progress not found")
    
    return {"message": "Here is the details", "episode": ep}