import hmac
from datetime import datetime, timedelta
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session

from app.core.db import get_db
from app.core.email import send_email
from app.core.otp import generate_otp, hash_otp
from app.core.security import get_password_hash, verify_password
from app.api.v1.auth import create_tokens_and_save_refresh
from app.dependencies.auth import get_current_user
from app.models.otp_codes import OTPCodes, OTPPurpose
from app.models.refresh_token import RefreshToken
from app.models.user import User
from app.schemas.verification import (
    ForgotPasswordRequest,
    GenericResponse,
    ResetPasswordConfirm,
    VerifyEmailConfirm,
    VerifyEmailResponse,
    ChangePasswordRequest
)
from app.services.rate_limiter import rate_limit_otp_request, rate_limit_otp_verify

router = APIRouter(prefix="/auth", tags=["auth"])


def constant_time_compare(a: str, b: str) -> bool:
    return hmac.compare_digest(a, b)


def create_otp_code(db: Session, user_id: int, purpose: OTPPurpose) -> tuple[OTPCodes, str]:
    otp = generate_otp()
    otp_hash = hash_otp(otp)
    expires_at = datetime.utcnow() + timedelta(minutes=10)

    otp_code = OTPCodes(
        user_id=user_id,
        otp_hash=otp_hash,
        purpose=purpose,
        expires_at=expires_at,
    )
    db.add(otp_code)
    db.commit()
    db.refresh(otp_code)

    return otp_code, otp


def verify_otp_code(
    db: Session, user_id: int, otp: str, purpose: OTPPurpose
) -> Optional[OTPCodes]:
    otp_hash = hash_otp(otp)

    # Find the valid OTP code
    otp_code = (
        db.query(OTPCodes)
        .filter(
            OTPCodes.user_id == user_id,
            OTPCodes.purpose == purpose,
            OTPCodes.expires_at > datetime.utcnow(),
        )
        .order_by(OTPCodes.created_at.desc())
        .first()
    )

    if not otp_code:
        return None

    if not constant_time_compare(otp_code.otp_hash, otp_hash):
        return None

    return otp_code


def revoke_all_refresh_tokens(db: Session, user_id: int) -> None:
    """Revoke all refresh tokens for a user"""
    db.query(RefreshToken).filter(
        RefreshToken.user_id == user_id,
        RefreshToken.revoked == False,
    ).update({RefreshToken.revoked: True})
    db.commit()


def log_audit_event(
    db: Session,
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


@router.post("/verify-email/request", response_model=GenericResponse)
async def request_verify_email(
    http_request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Send OTP for email verification.
    Only for logged-in users who are not yet verified.
    User email is extracted from JWT token.
    """
    # Check if already verified
    if current_user.is_verified:
        return GenericResponse(message="Email is already verified")

    # Rate limiting (per user)
    client_ip = http_request.client.host if http_request.client else "unknown"
    await rate_limit_otp_request(db, current_user.email, client_ip, "verify_email")

    # Create OTP for email verification
    otp_code, otp = create_otp_code(db, current_user.id, OTPPurpose.verify_email)

    # Send email
    try:
        await send_email(
            to_email=current_user.email,
            subject="Verify your email address",
            template="verification.html",
            otp=otp,
        )
    except Exception:
        # Log but don't expose error
        pass

    log_audit_event(
        db,
        event_type="verify_email_request",
        user_id=current_user.id,
        email=current_user.email,
        ip=client_ip,
        user_agent=http_request.headers.get("user-agent"),
        success=True,
    )

    return GenericResponse(message="Verification code has been sent to your email")


@router.post("/verify-email/confirm", response_model=VerifyEmailResponse)
async def confirm_verify_email(
    request: VerifyEmailConfirm,
    http_request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Verify OTP code and mark user as verified.
    Returns tokens on success.
    User email is extracted from JWT token.
    """
    await rate_limit_otp_verify(db, current_user.email, "verify_email")

    otp_code = verify_otp_code(db, current_user.id, request.otp, OTPPurpose.verify_email)

    client_ip = http_request.client.host if http_request.client else "unknown"
    user_agent = http_request.headers.get("user-agent")

    if not otp_code:
        log_audit_event(
            db,
            event_type="verify_email_confirm",
            user_id=current_user.id,
            email=current_user.email,
            ip=client_ip,
            user_agent=user_agent,
            success=False,
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired verification code",
        )

    # Mark OTP as used (delete it)
    db.delete(otp_code)

    # Activate user
    current_user.is_verified = True
    db.commit()

    # Generate tokens
    tokens = create_tokens_and_save_refresh(db, current_user)

    db.refresh(current_user)

    log_audit_event(
        db,
        event_type="verify_email_confirm",
        user_id=current_user.id,
        email=current_user.email,
        ip=client_ip,
        user_agent=user_agent,
        success=True,
    )

    return VerifyEmailResponse(message="Email verified successfully", tokens=tokens)


@router.post("/password/reset/request", response_model=GenericResponse)
async def request_password_reset(
    request: ForgotPasswordRequest,
    http_request: Request,
    db: Session = Depends(get_db),
):
    """
    Send OTP for password reset.
    Only sends if user exists AND is_verified=True.
    Returns identical response regardless of user existence (prevents email enumeration).
    """
    client_ip = http_request.client.host if http_request.client else "unknown"
    await rate_limit_otp_request(db, request.email, client_ip, "reset_password")

    user = db.query(User).filter(User.email == request.email).first()

    # Always return generic message to prevent email enumeration
    generic_message = "If the email is registered and verified, a password reset code has been sent."

    if user and user.is_verified:
        # Create OTP for password reset
        otp_code, otp = create_otp_code(db, user.id, OTPPurpose.reset_password)

        # Send email
        try:
            await send_email(
                to_email=request.email,
                subject="Reset your password",
                template="password_reset.html",
                otp=otp,
            )
        except Exception:
            # Log but don't expose error
            pass

    log_audit_event(
        db,
        event_type="password_reset_request",
        email=request.email,
        ip=client_ip,
        user_agent=http_request.headers.get("user-agent"),
        success=True,
    )

    return GenericResponse(message=generic_message)


@router.post("/password/reset/confirm", response_model=VerifyEmailResponse)
async def confirm_password_reset(
    request: ResetPasswordConfirm,
    http_request: Request,
    db: Session = Depends(get_db),
):
    """
    Verify OTP and reset password.
    Revokes all refresh tokens and returns new tokens.
    """
    await rate_limit_otp_verify(db, request.email, "reset_password")

    user = db.query(User).filter(User.email == request.email).first()

    otp_code = verify_otp_code(db, user.id, request.otp, OTPPurpose.reset_password)

    client_ip = http_request.client.host if http_request.client else "unknown"
    user_agent = http_request.headers.get("user-agent")

    if not otp_code:
        log_audit_event(
            db,
            event_type="password_reset_confirm",
            email=request.email,
            ip=client_ip,
            user_agent=user_agent,
            success=False,
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired reset code",
        )

    # Delete used OTP
    db.delete(otp_code)

    # Update password
    user = db.query(User).filter(User.email == request.email).first()
    user.hashed_password = get_password_hash(request.new_password)
    db.commit()

    # Revoke all refresh tokens
    revoke_all_refresh_tokens(db, user.id)

    # Generate new tokens
    tokens = create_tokens_and_save_refresh(db, user)

    log_audit_event(
        db,
        event_type="password_reset_confirm",
        user_id=user.id,
        email=request.email,
        ip=client_ip,
        user_agent=user_agent,
        success=True,
    )

    return VerifyEmailResponse(message="Password reset successfully", tokens=tokens)


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

    # Verify current password
    if not verify_password(
        request.current_password,
        current_user.hashed_password,
    ):
        log_audit_event(
            db,
            event_type="password_change",
            user_id=current_user.id,
            email=current_user.email,
            ip=client_ip,
            user_agent=user_agent,
            success=False,
        )

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

    log_audit_event(
        db,
        event_type="password_change",
        user_id=current_user.id,
        email=current_user.email,
        ip=client_ip,
        user_agent=user_agent,
        success=True,
    )

    return VerifyEmailResponse(
        message="Password changed successfully",
        tokens=tokens,
    )
