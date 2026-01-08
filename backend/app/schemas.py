"""Pydantic schemas for API requests and responses"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID


class ErrorResponse(BaseModel):
    """Error response schema matching OpenAPI spec"""
    detail: str = Field(..., description="Error message")
    error_code: Optional[str] = Field(None, description="Error code (optional)")


class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    version: str
    timestamp: datetime


class Ingredient(BaseModel):
    """Ingredient model"""
    id: str
    name: str


class IngredientDetectionResponse(BaseModel):
    """Response for ingredient detection"""
    ingredients: List[Ingredient]
    detection_id: str
    confidence: float = Field(..., ge=0.0, le=1.0)


class Recipe(BaseModel):
    """Recipe model"""
    id: str
    emoji: str
    badge: str  # fastLazy, actuallyGood, shouldntWork
    title: str
    steps: List[str]
    ingredients: Optional[List[str]] = None
    created_at: Optional[datetime] = None


class RecipeGenerationResponse(BaseModel):
    """Response for recipe generation"""
    recipes: List[Recipe]
    generation_id: str


class SubscriptionStatus(BaseModel):
    """Subscription status response"""
    plan: str  # free, premium, premium_annual
    status: str  # active, expired, cancelled
    expires_at: Optional[datetime] = None
    started_at: Optional[datetime] = None


class UsageLimits(BaseModel):
    """Usage limits response"""
    scans_today: int
    scans_limit: int  # -1 for unlimited
    recipes_today: int
    recipes_limit: int  # -1 for unlimited
    is_premium: bool
