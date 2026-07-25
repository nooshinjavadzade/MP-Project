from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.v1.api import api_router


app = FastAPI(
    title=settings.APP_NAME,
    description=settings.APP_DESCRIPTION,
    version=settings.APP_VERSION,
    openapi_url="/api/v1/openapi.json",
)

# CORS middleware - adjust origins for production
allow_origins = ["*"] if settings.DEBUG else settings.ALLOWED_ORIGINS
app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": settings.APP_NAME,
    }

@app.get("/config")
async def config():
    return {
        "database": settings.DATABASE_URL,
        "redis": settings.REDIS_URL,
        "debug": settings.DEBUG,
        "allowed_origins": settings.ALLOWED_ORIGINS,
        "app_name": settings.APP_NAME,
        "app_description": settings.APP_DESCRIPTION,
        "app_version": settings.APP_VERSION
    }

@app.get("/")
async def root():
    return {
        "message": f"Welcome to {settings.APP_NAME}",
        "docs": "/docs",
        "version": settings.APP_VERSION
    }

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
    )
