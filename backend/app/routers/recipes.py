"""Recipes router - recipe generation and retrieval"""
from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID
from pydantic import BaseModel
from datetime import datetime

from app.db import get_db
from app.models import Subscription, RecipeCache
from app.services.usage_service import usage_service
from app.services.openai_service import openai_service
from app.schemas import RecipeGenerationResponse, Recipe, ErrorResponse
import json

router = APIRouter(prefix="/api/v1", tags=["Recipes"])


class Ingredient(BaseModel):
    """Ingredient model"""
    id: str
    name: str


class GenerateRecipesRequest(BaseModel):
    """Request model for recipe generation"""
    ingredients: List[Ingredient]
    language: str = "en"
    max_recipes: int = 3
    appAccountToken: Optional[UUID] = None


@router.post("/generate-recipes")
async def generate_recipes(
    request: GenerateRecipesRequest,
    db: Session = Depends(get_db)
):
    """
    Generate recipe suggestions based on ingredients.
    
    - **ingredients**: List of ingredient objects with id and name
    - **language**: Language code for recipe generation (default: en)
    - **max_recipes**: Maximum number of recipes to generate (default: 3)
    - **appAccountToken**: Optional UUID for usage tracking
    """
    # Validate inputs
    if not request.ingredients:
        raise HTTPException(
            status_code=400,
            detail="At least one ingredient is required",
            headers={"X-Error-Code": "NO_INGREDIENTS"}
        )
    
    if request.max_recipes < 1 or request.max_recipes > 10:
        raise HTTPException(
            status_code=400,
            detail="max_recipes must be between 1 and 10",
            headers={"X-Error-Code": "INVALID_MAX_RECIPES"}
        )
    
    # Check usage limits if appAccountToken provided
    if request.appAccountToken:
        try:
            # Check if premium
            subscription = (
                db.query(Subscription)
                .filter(Subscription.app_account_token == request.appAccountToken)
                .order_by(Subscription.created_at.desc())
                .first()
            )
            
            is_premium = False
            if subscription and subscription.status == "active":
                if subscription.expires_at is None or subscription.expires_at > datetime.now():
                    is_premium = subscription.product_id in ["premium", "premium_annual"]
            
            # Check limit
            allowed, message = usage_service.check_limit(
                db=db,
                app_account_token=str(request.appAccountToken),
                feature="recipe_generation",
                is_premium=is_premium
            )
            
            if not allowed:
                raise HTTPException(
                    status_code=403,
                    detail=message,
                    headers={"X-Error-Code": "DAILY_LIMIT_REACHED"}
                )
            
            # Increment usage
            usage_service.increment_usage(
                db=db,
                app_account_token=str(request.appAccountToken),
                feature="recipe_generation"
            )
        except ValueError:
            # Invalid UUID format - skip usage tracking
            pass
    
    # Call OpenAI GPT-4 for recipe generation
    try:
        result = await openai_service.generate_recipes(
            ingredients=request.ingredients,
            language=request.language,
            max_recipes=request.max_recipes
        )
        
        # Cache recipes in database for multi-language support
        for recipe in result["recipes"]:
            # Check if recipe already exists in this language
            existing = (
                db.query(RecipeCache)
                .filter(
                    RecipeCache.recipe_id == recipe["id"],
                    RecipeCache.language == request.language
                )
                .first()
            )
            
            if not existing:
                # Store recipe in database
                recipe_cache = RecipeCache(
                    recipe_id=recipe["id"],
                    language=request.language,
                    emoji=recipe.get("emoji", "🍽️"),
                    badge=recipe.get("badge", "fastLazy"),
                    title=recipe.get("title", ""),
                    steps=json.dumps(recipe.get("steps", [])),
                    ingredients=json.dumps(recipe.get("ingredients", [])) if recipe.get("ingredients") else None
                )
                db.add(recipe_cache)
        
        db.commit()
        
        return RecipeGenerationResponse(**result)
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate recipes: {str(e)}",
            headers={"X-Error-Code": "GENERATION_FAILED"}
        )


@router.get("/recipes/{recipe_id}")
async def get_recipe(
    recipe_id: str,
    language: str = Query("en", description="Language code for localized content"),
    db: Session = Depends(get_db)
):
    """
    Get a specific recipe by ID in the requested language.
    
    - **recipe_id**: Recipe identifier
    - **language**: Language code for localized content (default: en)
    
    If the recipe exists in a different language, it will be translated to the requested language.
    This enables language switching without re-generating recipes.
    """
    # Try to find recipe in requested language
    recipe_cache = (
        db.query(RecipeCache)
        .filter(
            RecipeCache.recipe_id == recipe_id,
            RecipeCache.language == language
        )
        .first()
    )
    
    if recipe_cache:
        # Recipe exists in requested language
        return Recipe(
            id=recipe_cache.recipe_id,
            emoji=recipe_cache.emoji,
            badge=recipe_cache.badge,
            title=recipe_cache.title,
            steps=json.loads(recipe_cache.steps),
            ingredients=json.loads(recipe_cache.ingredients) if recipe_cache.ingredients else None,
            created_at=recipe_cache.created_at
        )
    
    # Try to find recipe in any language (for translation)
    any_language_recipe = (
        db.query(RecipeCache)
        .filter(RecipeCache.recipe_id == recipe_id)
        .first()
    )
    
    if any_language_recipe:
        # Recipe exists but in different language - translate it
        try:
            original_recipe = {
                "id": any_language_recipe.recipe_id,
                "emoji": any_language_recipe.emoji,
                "badge": any_language_recipe.badge,
                "title": any_language_recipe.title,
                "steps": json.loads(any_language_recipe.steps),
                "ingredients": json.loads(any_language_recipe.ingredients) if any_language_recipe.ingredients else []
            }
            
            # Translate recipe to requested language
            translated = await openai_service.translate_recipe(
                recipe=original_recipe,
                target_language=language
            )
            
            # Cache the translated recipe
            translated_cache = RecipeCache(
                recipe_id=translated["id"],
                language=language,
                emoji=translated.get("emoji", original_recipe["emoji"]),
                badge=translated.get("badge", original_recipe["badge"]),
                title=translated.get("title", ""),
                steps=json.dumps(translated.get("steps", [])),
                ingredients=json.dumps(translated.get("ingredients", [])) if translated.get("ingredients") else None
            )
            db.add(translated_cache)
            db.commit()
            
            return Recipe(
                id=translated["id"],
                emoji=translated.get("emoji", original_recipe["emoji"]),
                badge=translated.get("badge", original_recipe["badge"]),
                title=translated.get("title", ""),
                steps=translated.get("steps", []),
                ingredients=translated.get("ingredients"),
                created_at=any_language_recipe.created_at
            )
            
        except Exception as e:
            db.rollback()
            raise HTTPException(
                status_code=500,
                detail=f"Failed to translate recipe: {str(e)}",
                headers={"X-Error-Code": "TRANSLATION_FAILED"}
            )
    
    # Recipe not found in database
    raise HTTPException(
        status_code=404,
        detail=f"Recipe not found: {recipe_id}",
        headers={"X-Error-Code": "RECIPE_NOT_FOUND"}
    )
