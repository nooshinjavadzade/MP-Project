from fastapi import APIRouter
from . import auth, media, verification

api_router = APIRouter(prefix="/api/v1")

# Include all version 1 routers
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(media.router, prefix="/media", tags=["media"])
api_router.include_router(verification.router, tags=["auth"])