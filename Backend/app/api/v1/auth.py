from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import timedelta, datetime

from app.core.db import get_db
from app.schemas.user import UserCreate, UserResponse, UserLogin
from app.schemas.auth import AuthResponse
from app.schemas.token import Token
from app.models.user import User
from app.models.refresh_token import RefreshToken
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    hash_refresh_token   # ← Add this
)


router = APIRouter(tags=["auth"])


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


def create_tokens_and_save_refresh(db: Session, user: User) -> Token:
    access_token = create_access_token(data={"sub": user.id})
    refresh_token_str = create_refresh_token(data={"sub": user.id})

    # Hash the refresh token before saving
    token_hash = hash_refresh_token(refresh_token_str)

    refresh_token_obj = RefreshToken(
        user_id=user.id,
        token_hash=token_hash,           # ← Use token_hash
        expires_at=datetime.utcnow() + timedelta(days=30),
        revoked=False
    )
    db.add(refresh_token_obj)
    db.commit()

    return Token(
        access_token=access_token,
        refresh_token=refresh_token_str
    )