from typing import Optional
from sqlalchemy.orm import Session
from datetime import timedelta, datetime

from app.schemas.token import Token
from app.models.user import User
from app.models.refresh_token import RefreshToken
from app.core.security import (
    create_access_token,
    create_refresh_token,
    hash_refresh_token
)


def create_tokens_and_save_refresh(db: Session, user: User) -> Token:
    access_token = create_access_token(data={"sub": str(user.id)})
    refresh_token_str = create_refresh_token(data={"sub": str(user.id)})

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


def revoke_all_refresh_tokens(db: Session, user_id: int) -> None:
    """Revoke all refresh tokens for a user"""
    db.query(RefreshToken).filter(
        RefreshToken.user_id == user_id,
        RefreshToken.revoked == False,
    ).update({RefreshToken.revoked: True})
    db.commit()


def log_audit_event(
    event_type: str,
    user_id: Optional[int] = None,
    email: Optional[str] = None,
    ip: Optional[str] = None,
    user_agent: Optional[str] = None,
    success: bool = True,
):
    # TODO: Implement audit logging - for now just log to console
    import logging

    logger = logging.getLogger("audit")
    logger.info(
        f"AUDIT: type={event_type} user_id={user_id} email={email} "
        f"ip={ip} user_agent={user_agent} success={success}"
    )