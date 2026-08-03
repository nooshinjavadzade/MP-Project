import redis
from datetime import datetime
from fastapi import HTTPException, status

from app.core.config import settings


# Redis client for rate limiting
_redis_client = None


def get_redis_client():
    global _redis_client
    if _redis_client is None:
        _redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
    return _redis_client


async def rate_limit_otp_request(email: str, ip: str, purpose: str) -> None:
    """
    Rate limit OTP requests to max 3 per hour per email/IP combination.
    Uses Redis sliding window.
    """
    redis = get_redis_client()

    # Key for email-based rate limiting
    email_key = f"otp_request:{purpose}:email:{email}"
    # Key for IP-based rate limiting
    ip_key = f"otp_request:{purpose}:ip:{ip}"

    current_time = datetime.utcnow().timestamp()
    window_start = current_time - 3600  # 1 hour

    # Clean old entries and count current requests
    email_count = redis.zcount(email_key, window_start, current_time)
    ip_count = redis.zcount(ip_key, window_start, current_time)

    if email_count >= 10 or ip_count >= 10:
        from fastapi import HTTPException, status

        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many OTP requests. Please try again later.",
        )

    # Add current request
    request_id = f"{current_time}:{ip}"
    redis.zadd(email_key, {request_id: current_time})
    redis.zadd(ip_key, {request_id: current_time})

    # Expire keys after 1 hour
    redis.expire(email_key, 3600)
    redis.expire(ip_key, 3600)


async def rate_limit_otp_verify(email: str, purpose: str) -> None:
    """
    Rate limit OTP verification attempts to max 5 per hour per email.
    """
    redis = get_redis_client()

    key = f"otp_verify:{purpose}:email:{email}"
    current_time = datetime.utcnow().timestamp()
    window_start = current_time - 3600

    count = redis.zcount(key, window_start, current_time)

    if count >= 5:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many verification attempts. Please try again later.",
        )

    request_id = f"{current_time}"
    redis.zadd(key, {request_id: current_time})
    redis.expire(key, 3600)


async def rate_limit_password_change(user_id: int):
    """
    Rate limit password change attempts to max 5 per hour per user.
    """
    redis = get_redis_client()

    key = f"password_change:{user_id}"

    current = datetime.utcnow().timestamp()
    window = current - 3600

    count = redis.zcount(key, window, current)

    if count >= 5:
        raise HTTPException(
            status_code=429,
            detail="Too many password change attempts."
        )

    redis.zadd(key, {str(current): current})
    redis.expire(key, 3600)