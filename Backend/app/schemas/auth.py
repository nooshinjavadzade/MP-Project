from pydantic import BaseModel

from app.schemas.user import UserResponse
from app.schemas.token import Token
from app.schemas.verification import PasswordChangeBase


class AuthResponse(BaseModel):
    tokens: Token
    user: UserResponse


class LogoutRequest(BaseModel):
    refresh_token: str


class VerifyEmailResponse(BaseModel):
    message: str
    tokens: "Token"

    class Config:
        from_attributes = True


class ChangePasswordRequest(PasswordChangeBase):
    current_password: str