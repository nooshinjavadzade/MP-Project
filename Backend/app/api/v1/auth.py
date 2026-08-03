from fastapi import APIRouter, Depends, HTTPException, status, Response, Request
from sqlalchemy.orm import Session
from datetime import datetime
from pydantic import BaseModel

from app.services.auth_service import revoke_all_refresh_tokens, create_tokens_and_save_refresh
from app.core.db import get_db
from app.schemas.user import UserCreate, UserResponse, UserLogin
from app.schemas.auth import AuthResponse, LogoutRequest, VerifyEmailResponse, ChangePasswordRequest
from app.schemas.token import Token
from app.models.user import User
from app.models.refresh_token import RefreshToken
from app.models.personal_list import PersonalList
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    hash_refresh_token,
    decode_token
)
from app.dependencies.auth import get_current_user
from app.services.rate_limiter import rate_limit_password_change

router = APIRouter(tags=["auth"])


class RefreshRequest(BaseModel):
    refresh_token: str


@router.post("/register", response_model=AuthResponse)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    if db.query(User).filter(User.email == user_in.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    if db.query(User).filter(User.username == user_in.username).first():
        raise HTTPException(status_code=400, detail="Username already taken")

    # Create user
    hashed_password = get_password_hash(user_in.password)
    user = User(
        username=user_in.username,
        email=user_in.email,
        full_name=user_in.full_name,
        hashed_password=hashed_password
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # Create default lists
    liked_list = PersonalList(
        user_id=user.id,
        name="Liked",
        description="Media you've liked",
        is_default=True
    )
    watchlist = PersonalList(
        user_id=user.id,
        name="Watchlist",
        description="Media you plan to watch",
        is_default=True
    )
    db.add(liked_list)
    db.add(watchlist)
    db.commit()

    tokens = create_tokens_and_save_refresh(db, user)

    return AuthResponse(
        tokens=tokens,
        user=UserResponse.model_validate(user)
    )


@router.post("/login", response_model=AuthResponse)
def login(user_in: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == user_in.email).first()
    if not user or not verify_password(user_in.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    tokens = create_tokens_and_save_refresh(db, user)

    return AuthResponse(
        tokens=tokens,
        user=UserResponse.model_validate(user)
    )


@router.post("/refresh", response_model=Token)
def refresh_token(request: RefreshRequest, db: Session = Depends(get_db)):
    refresh_token_str = request.refresh_token

    payload = decode_token(refresh_token_str)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    # Verify refresh token in database
    token_hash = hash_refresh_token(refresh_token_str)
    refresh_token_obj = db.query(RefreshToken).filter(
        RefreshToken.token_hash == token_hash,
        RefreshToken.user_id == user_id,
        RefreshToken.revoked == False,
        RefreshToken.expires_at > datetime.utcnow()
    ).first()

    if not refresh_token_obj:
        raise HTTPException(status_code=401, detail="Refresh token expired or revoked")

    # Get user
    user = db.query(User).filter(User.id == user_id).first()
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="User not found or inactive")

    # Create new access token
    new_access_token = create_access_token(data={"sub": str(user.id)})

    return Token(
        access_token=new_access_token,
        refresh_token=refresh_token_str
    )


@router.post("/password/change", response_model=VerifyEmailResponse)
async def change_password(
    request: ChangePasswordRequest,
    http_request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Change password for an authenticated user.
    Requires the current password.
    Revokes all refresh tokens and returns new tokens.
    """
    client_ip = http_request.client.host if http_request.client else "unknown"
    user_agent = http_request.headers.get("user-agent")
    await rate_limit_password_change(current_user.id)

    # Verify current password
    if not verify_password(
        request.current_password,
        current_user.hashed_password,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect",
        )

    # Prevent reusing the current password
    if verify_password(
        request.new_password,
        current_user.hashed_password,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="New password must be different from the current password",
        )

    # Update password
    current_user.hashed_password = get_password_hash(
        request.new_password
    )
    db.commit()
    db.refresh(current_user)

    # Revoke all refresh tokens
    revoke_all_refresh_tokens(db, current_user.id)

    # Generate new tokens
    tokens = create_tokens_and_save_refresh(
        db,
        current_user,
    )

    return VerifyEmailResponse(
        message="Password changed successfully",
        tokens=tokens,
    )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(
    request: LogoutRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    token_hash = hash_refresh_token(request.refresh_token)

    refresh = (
        db.query(RefreshToken)
        .filter(
            RefreshToken.user_id == current_user.id,
            RefreshToken.token_hash == token_hash,
            RefreshToken.revoked == False,
        )
        .first()
    )

    if refresh:
        refresh.revoked = True
        db.commit()

    return Response(status_code=204)


@router.post("/logout/all", status_code=status.HTTP_204_NO_CONTENT)
def logout_all(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    revoke_all_refresh_tokens(db, current_user.id)

    return Response(status_code=204)