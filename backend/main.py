"""
FridgeGPT Backend API
FastAPI application for ingredient detection and recipe generation
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.db import engine, Base

# Import routers
from app.routers import subscription, usage, detection, recipes

# Initialize FastAPI app
app = FastAPI(
    title="FridgeGPT API",
    description="Backend API for FridgeGPT mobile application",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS configuration
cors_origins = settings.cors_origins.split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(subscription.router)
app.include_router(usage.router)
app.include_router(detection.router)
app.include_router(recipes.router)


@app.get("/api/v1/health")
async def health_check():
    """Health check endpoint"""
    from datetime import datetime
    from app.schemas import HealthResponse
    return HealthResponse(
        status="healthy",
        version="1.0.0",
        timestamp=datetime.utcnow(),
    )


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host=settings.api_host,
        port=settings.api_port,
        reload=settings.debug,
    )

