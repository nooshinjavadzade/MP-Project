import httpx
from typing import Dict, Any, Optional, List
from .config import settings

class TMDBClient:
    def __init__(self):
        self.base_url = "https://api.themoviedb.org/3"
        self.api_key = settings.TMDB_API_KEY
        self.headers = {
            "accept": "application/json",
            "Authorization": f"Bearer {settings.TMDB_ACCESS_TOKEN}" if hasattr(settings, 'TMDB_ACCESS_TOKEN') else None
        }

    async def _get(self, endpoint: str, params: Dict = None) -> Dict:
        async with httpx.AsyncClient() as client:
            url = f"{self.base_url}{endpoint}"
            params = params or {}
            params["api_key"] = self.api_key
            response = await client.get(url, params=params, headers=self.headers)
            response.raise_for_status()
            return response.json()

    # Search
    async def search_multi(self, query: str, page: int = 1) -> Dict:
        """Search movies and TV shows"""
        return await self._get("/search/multi", {"query": query, "page": page})

    async def search_movies(self, query: str, page: int = 1) -> Dict:
        return await self._get("/search/movie", {"query": query, "page": page})

    async def search_tv(self, query: str, page: int = 1) -> Dict:
        return await self._get("/search/tv", {"query": query, "page": page})

    # Details
    async def get_movie_details(self, movie_id: int) -> Dict:
        return await self._get(f"/movie/{movie_id}", {"append_to_response": "credits,images"})

    async def get_tv_details(self, tv_id: int) -> Dict:
        return await self._get(f"/tv/{tv_id}", {"append_to_response": "credits,images,seasons"})

    async def get_season_details(self, tv_id: int, season_number: int) -> Dict:
        return await self._get(f"/tv/{tv_id}/season/{season_number}")

    # Popular / Trending
    async def get_popular_movies(self, page: int = 1) -> Dict:
        return await self._get("/movie/popular", {"page": page})

    async def get_popular_tv(self, page: int = 1) -> Dict:
        return await self._get("/tv/popular", {"page": page})

    async def get_trending(self, media_type: str = "all", time_window: str = "week") -> Dict:
        return await self._get(f"/trending/{media_type}/{time_window}")