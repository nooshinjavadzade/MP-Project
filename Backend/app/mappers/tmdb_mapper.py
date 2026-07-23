from typing import Dict, List

from app.schemas.media import (
    MediaBase, MovieDetails, SeriesDetails,
    CastMember, Season, Episode, MediaType
)


class TMDBMapper:

    @staticmethod
    def to_media_base(data: Dict) -> MediaBase:
        """Map TMDB data to MediaBase"""
        media_type = data.get("media_type", "movie")

        return MediaBase(
            id=int(data.get("id")),
            media_type=MediaType.movie if media_type == "movie" else MediaType.series,
            tmdb_id=str(data.get("id")),  # TMDB id as fallback
            title=data.get("title") or data.get("name"),
            original_title=data.get("original_title") or data.get("original_name"),
            poster_url=f"https://image.tmdb.org/t/p/w500{data.get('poster_path')}" if data.get("poster_path") else None,
            backdrop_url=f"https://image.tmdb.org/t/p/original{data.get('backdrop_path')}" if data.get(
                "backdrop_path") else None,
            overview=data.get("overview"),
            release_year=int(data.get("release_date", "").split('-')[0]) if data.get("release_date") else
            int(data.get("first_air_date", "").split('-')[0]) if data.get("first_air_date") else None,
            tmdb_rating=float(data.get("vote_average"))*2,
            genres=[genre.get("name") for genre in data.get("genres", [])],
            original_language=data.get("original_language"),
            country=data.get("origin_country")[0] if data.get("origin_country") else None,
            cast=TMDBMapper._map_cast(data.get("credits", {}).get("cast", [])[:10])
        )

    @staticmethod
    def to_movie_details(data: Dict) -> MovieDetails:
        base = TMDBMapper.to_media_base(data)
        return MovieDetails(
            **base.model_dump(),
            runtime=data.get("runtime")
        )

    @staticmethod
    def to_series_details(data: Dict) -> SeriesDetails:
        base = TMDBMapper.to_media_base(data)
        seasons = TMDBMapper._map_seasons(data.get("seasons", []))

        return SeriesDetails(
            **base.model_dump(),
            season_count=data.get("number_of_seasons"),
            episode_count=data.get("number_of_episodes"),
            seasons=seasons,
            end_year=int(data.get("last_air_date", "")[:4]) if data.get("last_air_date") else None,
            status=data.get("status", "Unknown")
        )

    @staticmethod
    def _map_cast(cast_list: List[Dict]) -> List[CastMember]:
        return [
            CastMember(
                id=str(person.get("id")),
                name=person.get("name"),
                role=person.get("character") or person.get("job", "Actor"),
                profile_image_url=f"https://image.tmdb.org/t/p/w200{person.get('profile_path')}"
                if person.get("profile_path") else None
            )
            for person in cast_list[:10]
        ]

    @staticmethod
    def _map_seasons(seasons_data: List[Dict]) -> List[Season]:
        seasons = []
        for s in seasons_data:
            episodes = [
                Episode(
                    episode_number=ep.get("episode_number"),
                    title=ep.get("name"),
                    overview=ep.get("overview"),
                    release_date=ep.get("air_date"),
                    runtime=ep.get("runtime")
                )
                for ep in s.get("episodes", [])
            ]
            seasons.append(Season(
                season_number=int(s.get("season_number")),
                title=s.get("name"),
                episodes=episodes
            ))
        return seasons