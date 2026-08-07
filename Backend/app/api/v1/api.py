from fastapi import APIRouter
from app.api.v1 import auth, media, verification, interactions, profile, admin, progress

api_router = APIRouter(prefix="/api/v1")

# Include all version 1 routers
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(verification.router, prefix="/auth", tags=["auth"])
api_router.include_router(profile.router, prefix="/profile", tags=["profile"])
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])
api_router.include_router(media.router, prefix="/media", tags=["media"])
api_router.include_router(interactions.router, prefix="/interactions", tags=["interactions"])
api_router.include_router(progress.router, prefix="/progress", tags=["progress"])
