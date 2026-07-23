from typing import Dict, List

from app.schemas.media import (
    MediaBase, MovieDetails, SeriesDetails,
    CastMember, Season, Episode, MediaType
)


class TMDBMapper:

    @staticmethod
    def to_media_base(data: Dict) -> MediaBase:
        media_type = data.get("media_type", "movie")

        # Poster
        if data.get("poster_path"):
            poster_path = data["poster_path"]
        else:
            poster_path = None

        # Backdrop
        if data.get("backdrop_path"):
            backdrop_path = data["backdrop_path"]
        else:
            backdrop_path = None

        # Overview
        if data.get("overview"):
            overview = data["overview"]
        else:
            overview = None

        # Release year
        if data.get("release_date"):
            release_year = int(data["release_date"][:4])
        elif data.get("first_air_date"):
            release_year = int(data["first_air_date"][:4])
        else:
            release_year = None

        # Rating
        if data.get("vote_average") is not None:
            tmdb_rating = float(data["vote_average"])
        else:
            tmdb_rating = None

        # Language
        if data.get("original_language"):
            original_language = data["original_language"]
        else:
            original_language = None

        # Country
        if data.get("origin_country"):
            country = data["origin_country"][0]
        elif data.get("production_countries"):
            country = data["production_countries"][0]["iso_3166_1"]
        else:
            country = None

        return MediaBase(
            id=int(data["id"]),
            media_type=MediaType.movie if media_type == "movie" else MediaType.series,
            tmdb_id=str(data["id"]),
            title=data.get("title") or data.get("name"),
            original_title=data.get("original_title") or data.get("original_name"),
            poster_url=f"https://image.tmdb.org/t/p/w500{poster_path}" if poster_path else None,
            backdrop_url=f"https://image.tmdb.org/t/p/original{backdrop_path}" if backdrop_path else None,
            overview=overview,
            release_year=release_year,
            tmdb_rating=tmdb_rating,
            genres=[g["name"] for g in data.get("genres", [])],
            original_language=original_language,
            country=country,
            cast=TMDBMapper.map_cast(data.get("credits", {}).get("cast", [])[:10]),
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
            end_year=int(data.get("last_air_date", "")[:4]) if (data.get("last_air_date") and data.get("status") in ['Ended', 'Canceled']) else None,
            status=data.get("status", "Unknown")
        )

    @staticmethod
    def map_cast(cast_list: List[Dict], is_media: bool = False) -> List[CastMember | Dict]:
        if is_media:
            return [
                {
                    "id": str(person.get("id")),
                    "name": person.get("name"),
                    "role": person.get("character") or person.get("job", "Actor"),
                    "profile_image_url": f"https://image.tmdb.org/t/p/w200{person.get('profile_path')}"
                    if person.get("profile_path") else None
                }
                for person in cast_list[:10]
            ]

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
            if s.get("name") == "Specials":
                continue

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
                episodes=episodes,
                overview=s.get("overview"),
                release_date=s.get("air_date")
            ))
        return seasons