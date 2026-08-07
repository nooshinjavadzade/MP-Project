from fastapi import HTTPException
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime

from app.api.v1.media import _save_or_update_media, _save_or_update_season
from app.api.v1.media import _save_or_update_season
from app.core.tmdb import TMDBClient
from app.models import Media, WatchProgress, EpisodeWatchProgress, Episode
from app.schemas.progress import (
    SeriesProgressResponse
)
from app.models.media import WatchStatus


def update_episode_progress(
    user_id: int,
    media_id: int,
    season_number: int,
    episode_number: int,
    status: WatchStatus,
    db: Session
) -> EpisodeWatchProgress:
    """Update episode progress and recompute series-level WatchProgress."""

    # Verify media exists and is a series
    media = db.query(Media).filter(Media.id == media_id).first()
    if not media:
        raise ValueError("Media not found")
    if media.media_type != Media.__table__.c.media_type.type.enum_class.series:
        raise ValueError("Media must be a series for episode progress")

    # Get or create episode progress
    ep_progress = db.query(EpisodeWatchProgress).filter(
        EpisodeWatchProgress.user_id == user_id,
        EpisodeWatchProgress.media_id == media_id,
        EpisodeWatchProgress.season_number == season_number,
        EpisodeWatchProgress.episode_number == episode_number
    ).first()

    if ep_progress:
        ep_progress.status = status
        if status == WatchStatus.completed:
            ep_progress.watched_at = datetime.utcnow()
        ep_progress.updated_at = datetime.utcnow()
    else:
        ep_progress = EpisodeWatchProgress(
            user_id=user_id,
            media_id=media_id,
            season_number=season_number,
            episode_number=episode_number,
            status=status,
            watched_at=datetime.utcnow() if status == WatchStatus.completed else None
        )
        db.add(ep_progress)

    db.commit()
    db.refresh(ep_progress)

    # Recompute series-level WatchProgress
    recompute_series_progress(user_id, media_id, db)

    return ep_progress


def recompute_series_progress(user_id: int, media_id: int, db: Session) -> Optional[WatchProgress]:
    """Recompute series-level WatchProgress from episode progress."""

    # Count total episodes from media cache
    media = db.query(Media).filter(Media.id == media_id).first()
    if not media or media.media_type != Media.__table__.c.media_type.type.enum_class.series:
        return None

    total_episodes = media.episode_count or 0

    # Count completed episodes for this user/series
    watched_episodes = db.query(EpisodeWatchProgress).filter(
        EpisodeWatchProgress.user_id == user_id,
        EpisodeWatchProgress.media_id == media_id,
        EpisodeWatchProgress.status == WatchStatus.completed
    ).count()

    # Determine overall status
    if total_episodes > 0 and watched_episodes == total_episodes:
        overall_status = WatchStatus.completed
    elif watched_episodes > 0:
        overall_status = WatchStatus.watching
    else:
        overall_status = WatchStatus.plan_to_watch

    progress_pct = (watched_episodes / total_episodes * 100) if total_episodes > 0 else 0.0

    # Get or create WatchProgress for this series
    watch_progress = db.query(WatchProgress).filter(
        WatchProgress.user_id == user_id,
        WatchProgress.media_id == media_id
    ).first()

    if watch_progress:
        watch_progress.status = overall_status
        watch_progress.progress = progress_pct
        watch_progress.watched_episodes = watched_episodes
        if overall_status == WatchStatus.completed:
            watch_progress.last_watched_at = datetime.utcnow()
        watch_progress.updated_at = datetime.utcnow()
    else:
        watch_progress = WatchProgress(
            user_id=user_id,
            media_id=media_id,
            status=overall_status,
            progress=progress_pct,
            watched_episodes=watched_episodes,
            last_watched_at=datetime.utcnow() if overall_status == WatchStatus.completed else None
        )
        db.add(watch_progress)

    db.commit()
    db.refresh(watch_progress)

    return watch_progress


async def get_series_progress(user_id: int, media_id: int, db: Session) -> Optional[SeriesProgressResponse]:
    """Get aggregated series progress for a user."""

    media = db.query(Media).filter(Media.tmdb_id == str(media_id), Media.media_type == "series").first()
    if not media:
        return None
    
    await _ensure_series_episodes_cached(media, db)
    
    media = db.query(Media).filter(Media.id == media.id).first()  # Refresh media after potential update

    # Get all episode progress for this user/series
    ep_progress_list = db.query(EpisodeWatchProgress).filter(
        EpisodeWatchProgress.user_id == user_id,
        EpisodeWatchProgress.media_id == media.id
    ).all()

    watched_episodes = sum(1 for ep in ep_progress_list if ep.status in [WatchStatus.completed, WatchStatus.watching, WatchStatus.loved])
    total_episodes = media.episode_count or 0
    completion_pct = (watched_episodes / total_episodes * 100) if total_episodes > 0 else 0.0

    # Determine overall status (reuse from WatchProgress or compute)
    watch_progress = db.query(WatchProgress).filter(
        WatchProgress.user_id == user_id,
        WatchProgress.media_id == media_id
    ).first()

    if watch_progress:
        status = watch_progress.status
    elif completion_pct == 100:
        status = WatchStatus.completed
    elif watched_episodes > 0:
        status = WatchStatus.watching
    else:
        status = WatchStatus.plan_to_watch

    # Find next episode to watch
    next_episode = None
    if watched_episodes < total_episodes:
        # Get all episodes from DB
        episodes = db.query(Episode).filter(Episode.media_id == media.id).order_by(
            Episode.season_number, Episode.episode_number
        ).all()
        
        watched_set = {(ep.season_number, ep.episode_number) for ep in ep_progress_list if ep.status == WatchStatus.completed}

        for ep in episodes:
            if (ep.season_number, ep.episode_number) not in watched_set:
                next_episode = {
                    "season_number": ep.season_number,
                    "episode_number": ep.episode_number,
                    "title": ep.title
                }
                break

    return SeriesProgressResponse(
        media_id=media_id,
        title=media.title,
        total_episodes=total_episodes,
        watched_episodes=watched_episodes,
        completion_pct=completion_pct,
        status=status,
        next_episode=next_episode
    )


def upsert_movie_progress(user_id: int, media_id: int, status: WatchStatus, progress: float, db: Session) -> WatchProgress:
    """Upsert movie watch progress."""

    media = db.query(Media).filter(Media.id == media_id).first()
    if not media:
        raise ValueError("Media not found")
    if media.media_type != Media.__table__.c.media_type.type.enum_class.movie:
        raise ValueError("Media must be a movie for movie progress")

    watch_progress = db.query(WatchProgress).filter(
        WatchProgress.user_id == user_id,
        WatchProgress.media_id == media_id
    ).first()

    if watch_progress:
        watch_progress.status = status
        watch_progress.progress = progress
        if status == WatchStatus.completed:
            watch_progress.last_watched_at = datetime.utcnow()
        watch_progress.updated_at = datetime.utcnow()
    else:
        watch_progress = WatchProgress(
            user_id=user_id,
            media_id=media_id,
            status=status,
            progress=progress,
            watched_episodes=0,
            last_watched_at=datetime.utcnow() if status == WatchStatus.completed else None
        )
        db.add(watch_progress)

    db.commit()
    db.refresh(watch_progress)

    return watch_progress


def get_movie_progress(user_id: int, media_id: int, media_type: str, db: Session) -> Optional[WatchProgress]:
    """Get movie progress for a user."""
    media = db.query(Media).filter(
        Media.tmdb_id == str(media_id),
        Media.media_type == media_type
    ).first()
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    
    return db.query(WatchProgress).filter(
        WatchProgress.user_id == user_id,
        WatchProgress.media_id == media.id
    ).first()
    
    
async def _ensure_series_episodes_cached(
    media: Media,
    db: Session
):
    """
    Ensure all seasons and episodes of a series exist in DB.
    """
    tmdb_client = TMDBClient()
    
    if not media.season_count or not media.episode_count:
        # Get latest series info from TMDB
        tmdb_data = await tmdb_client.get_media_details(
            media.tmdb_id,
            media_type="tv"
        )
        tmdb_data["media_type"] = "series"
        await _save_or_update_media(db, tmdb_data, is_full_fetch=True)

    media = db.query(Media).filter(Media.id == media.id).first()  # Refresh media after potential update
    total_seasons = media.season_count

    cached_seasons = {
        s.season_number
        for s in media.seasons
    }
    

    # Fetch missing seasons
    for season_number in range(1, total_seasons + 1):
        print(season_number)
        if season_number not in cached_seasons:
            tmdb_season = await tmdb_client.get_season_details(
                media.tmdb_id,
                season_number
            )

            await _save_or_update_season(
                db,
                media,
                tmdb_season
            )

    db.refresh(media)