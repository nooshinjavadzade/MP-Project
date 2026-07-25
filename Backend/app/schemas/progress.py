from pydantic import BaseModel


class ProgressUpdate(BaseModel):
    media_id: int
    watched_episodes: int
