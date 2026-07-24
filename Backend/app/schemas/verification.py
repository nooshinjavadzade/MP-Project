from pydantic import BaseModel, EmailStr, Field, field_validator

from app.schemas.token import Token


class VerifyEmailConfirm(BaseModel):
    otp: str = Field(min_length=6, max_length=6, pattern=r"^\d{6}$")


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class PasswordChangeBase(BaseModel):
    new_password: str = Field(min_length=8)
    confirm_password: str

    @field_validator("new_password")
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        """Enforce password strength: min 8 chars, 1 upper, 1 lower, 1 digit, 1 special"""
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not any(c.islower() for c in v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain at least one digit")
        if not any(not c.isalnum() for c in v):
            raise ValueError("Password must contain at least one special character")
        return v

    @field_validator("confirm_password")
    @classmethod
    def passwords_match(cls, v: str, info) -> str:
        if "new_password" in info.data and v != info.data["new_password"]:
            raise ValueError("Passwords do not match")
        return v


class ResetPasswordConfirm(PasswordChangeBase):
    email: EmailStr
    otp: str = Field(min_length=6, max_length=6, pattern=r"^\d{6}$")


class ChangePasswordRequest(PasswordChangeBase):
    current_password: str


class GenericResponse(BaseModel):
    message: str


class VerifyEmailResponse(BaseModel):
    message: str
    tokens: "Token"

    class Config:
        from_attributes = True
