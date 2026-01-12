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
    image_url: Optional[str] = None  # Foodish API image URL (free food images)


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


class HistoryEntry(BaseModel):
    """History entry with full recipe data - supports single or grouped recipes"""
    recipe_id: str  # Primary recipe ID (first recipe for grouped entries)
    emoji: str  # Primary emoji (first recipe for grouped entries)
    badge: str  # Primary badge (first recipe for grouped entries)
    title: str  # Combined title for grouped recipes (e.g., "Recipe 1, Recipe 2, and Recipe 3")
    steps: List[str]  # Steps from primary recipe (for backward compatibility)
    ingredients: Optional[List[str]] = None  # Ingredients from primary recipe (for backward compatibility)
    created_at: datetime
    recipes: Optional[List[Recipe]] = None  # All recipes in this batch (if grouped)


class HistoryResponse(BaseModel):
    """Response model for history"""
    history: List[HistoryEntry]
