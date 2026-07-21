from pydantic import BaseModel

from user import UserResponse
from token import Token


class AuthResponse(BaseModel):
    tokens: Token
    user: UserResponse
