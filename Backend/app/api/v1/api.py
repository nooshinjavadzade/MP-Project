from fastapi import APIRouter
from . import auth

api_router = APIRouter(prefix="/api/v1")

# Include all version 1 routers
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])