from pydantic import BaseModel

from app.schemas.user import UserResponse
from app.schemas.token import Token


class AuthResponse(BaseModel):
    tokens: Token
    user: UserResponse
