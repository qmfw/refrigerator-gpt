"""Recipes router - recipe generation and retrieval"""
from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from app.db import get_db
from app.models import Subscription, RecipeCache, History
from app.services.usage_service import usage_service
from app.services.openai_service import openai_service
from app.services.foodish_service import foodish_service
from app.schemas import RecipeGenerationResponse, Recipe, ErrorResponse, HistoryResponse, HistoryEntry
import json
import asyncio

router = APIRouter(prefix="/api/v1", tags=["Recipes"])


class Ingredient(BaseModel):
    """Ingredient model"""
    id: str
    name: str


class DietPreferencesRequest(BaseModel):
    """Diet preferences model (sent from client)"""
    avoid_ingredients: List[str] = []
    diet_style: List[str] = []
    cooking_preferences: List[str] = []
    religious: List[str] = []


class GenerateRecipesRequest(BaseModel):
    """Request model for recipe generation"""
    ingredients: List[Ingredient]
    language: str = "en"
    max_recipes: int = 3
    appAccountToken: Optional[str] = None  # Changed to str for SQLite compatibility
    diet_preferences: Optional[DietPreferencesRequest] = None  # Sent from Flutter


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
    
    # Determine user tier server-side (NOT from request - security)
    user_tier = "free"  # Default to free
    diet_preferences = None
    
    if request.appAccountToken:
        try:
            # Check if premium - backend is source of truth
            subscription = (
                db.query(Subscription)
                .filter(Subscription.app_account_token == str(request.appAccountToken))
                .order_by(Subscription.created_at.desc())
                .first()
            )
            
            is_premium = False
            if subscription and subscription.status == "active":
                if subscription.expires_at is None or subscription.expires_at > datetime.now():
                    is_premium = subscription.product_id in ["premium", "premium_annual"]
            
            # Set tier based on subscription status (server-side only)
            if is_premium:
                user_tier = "premium"
                
                # Use diet preferences from request (sent from Flutter local storage)
                if request.diet_preferences:
                    diet_preferences = {
                        "avoid_ingredients": request.diet_preferences.avoid_ingredients,
                        "diet_style": request.diet_preferences.diet_style,
                        "cooking_preferences": request.diet_preferences.cooking_preferences,
                        "religious": request.diet_preferences.religious,
                    }
            # Free users cannot have diet preferences - ignore any sent from client
            
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
            max_recipes=request.max_recipes,
            user_tier=user_tier,
            diet_preferences=diet_preferences
        )
        
        # Generate batch ID for grouping recipes generated together
        import uuid as uuid_module
        batch_id = str(uuid_module.uuid4()) if request.appAccountToken else None
        
        # Cache recipes in database for multi-language support
        # Fetch images from Foodish API in parallel (fast and free)
        image_tasks = []
        for recipe in result["recipes"]:
            # Fetch image from Foodish API (non-blocking, fast)
            recipe_ingredients = recipe.get("ingredients", [])
            image_task = foodish_service.get_food_image(
                recipe_title=recipe.get("title", ""),
                ingredients=recipe_ingredients
            )
            image_tasks.append(image_task)
        
        # Fetch all images in parallel
        image_urls = await asyncio.gather(*image_tasks, return_exceptions=True)
        
        # Add image URLs to recipes in the response BEFORE caching
        # This ensures frontend receives images immediately in the response
        for idx, recipe in enumerate(result["recipes"]):
            # Get image URL (handle exceptions)
            image_url = None
            if idx < len(image_urls) and not isinstance(image_urls[idx], Exception):
                image_url = image_urls[idx]
            
            # Add image_url to recipe response so frontend gets it immediately
            recipe["image_url"] = image_url
            
            # Debug: Log image URL assignment (can be removed in production)
            if image_url:
                print(f"✅ Added image_url to recipe {recipe.get('id', 'unknown')}: {image_url[:50]}...")
            else:
                print(f"⚠️  No image_url for recipe {recipe.get('id', 'unknown')} (will use emoji fallback)")
        
        # Cache recipes in database with image URLs
        for idx, recipe in enumerate(result["recipes"]):
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
                # Get image URL (already fetched above)
                image_url = recipe.get("image_url")
                
                # Store recipe in database
                recipe_cache = RecipeCache(
                    recipe_id=recipe["id"],
                    language=request.language,
                    emoji=recipe.get("emoji", "🍽️"),
                    badge=recipe.get("badge", "fastLazy"),
                    title=recipe.get("title", ""),
                    steps=json.dumps(recipe.get("steps", [])),
                    ingredients=json.dumps(recipe.get("ingredients", [])) if recipe.get("ingredients") else None,
                    image_url=image_url  # Store Foodish image URL
                )
                db.add(recipe_cache)
            
            # Save all recipes to history (if appAccountToken provided)
            if request.appAccountToken:
                # Check if history entry already exists (avoid duplicates)
                existing_history = (
                    db.query(History)
                    .filter(
                        History.app_account_token == str(request.appAccountToken),
                        History.recipe_id == recipe["id"]
                    )
                    .first()
                )
                
                if not existing_history:
                    history_entry = History(
                        app_account_token=str(request.appAccountToken),
                        recipe_id=recipe["id"],
                        generation_batch_id=batch_id
                    )
                    db.add(history_entry)
        
        db.commit()
        
        # Debug: Verify image_urls are in recipes before returning
        for recipe in result["recipes"]:
            if recipe.get("image_url"):
                print(f"✅ Recipe {recipe.get('id')} has image_url: {recipe.get('image_url')[:50]}...")
            else:
                print(f"⚠️  Recipe {recipe.get('id')} missing image_url (will use emoji)")
        
        response = RecipeGenerationResponse(**result)
        
        # Debug: Verify response includes image_urls
        for recipe in response.recipes:
            if recipe.image_url:
                print(f"✅ Response recipe {recipe.id} has image_url: {recipe.image_url[:50]}...")
            else:
                print(f"⚠️  Response recipe {recipe.id} missing image_url")
        
        return response
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
            created_at=recipe_cache.created_at,
            image_url=recipe_cache.image_url  # Foodish API image URL
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
                ingredients=json.dumps(translated.get("ingredients", [])) if translated.get("ingredients") else None,
                image_url=any_language_recipe.image_url  # Use same image for translated recipe
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
                created_at=any_language_recipe.created_at,
                image_url=any_language_recipe.image_url  # Use same image for translated recipe
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


@router.get("/history")
async def get_history(
    appAccountToken: str = Query(..., description="Unique app account token (UUID generated locally)"),
    language: str = Query("en", description="Language code for localized content"),
    db: Session = Depends(get_db)
):
    """
    Get user's recipe history with full recipe data in requested language.
    
    Returns all recipes the user has generated, ordered by creation date (newest first).
    Only requires language parameter - recipe IDs are determined from history table.
    
    - **appAccountToken**: Unique app account token (UUID generated locally)
    - **language**: Language code for localized content (default: en)
    """
    try:
        # Get all history entries for this user, ordered by creation date (newest first)
        history_entries = (
            db.query(History)
            .filter(History.app_account_token == appAccountToken)
            .order_by(History.created_at.desc())
            .all()
        )
        
        if not history_entries:
            return HistoryResponse(history=[])
        
        # Get all recipe IDs
        recipe_ids = [entry.recipe_id for entry in history_entries]
        
        # Bulk fetch recipes from cache in requested language
        cached_recipes = (
            db.query(RecipeCache)
            .filter(
                RecipeCache.recipe_id.in_(recipe_ids),
                RecipeCache.language == language
            )
            .all()
        )
        
        # Create a map of recipe_id -> recipe for quick lookup
        recipe_map = {recipe.recipe_id: recipe for recipe in cached_recipes}
        
        # Helper function to get or translate recipe
        async def get_or_translate_recipe(recipe_id: str, entry_created_at: datetime) -> Optional[Recipe]:
            """Get recipe in requested language, translate if needed"""
            # Check if recipe exists in requested language
            recipe = recipe_map.get(recipe_id)
            if recipe:
                return Recipe(
                    id=recipe.recipe_id,
                    emoji=recipe.emoji,
                    badge=recipe.badge,
                    title=recipe.title,
                    steps=json.loads(recipe.steps),
                    ingredients=json.loads(recipe.ingredients) if recipe.ingredients else None,
                    created_at=entry_created_at,
                    image_url=recipe.image_url  # Foodish API image URL
                )
            
            # Recipe not found in requested language - find in any language and translate
            any_language_recipe = (
                db.query(RecipeCache)
                .filter(RecipeCache.recipe_id == recipe_id)
                .first()
            )
            
            if any_language_recipe:
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
                        ingredients=json.dumps(translated.get("ingredients", [])) if translated.get("ingredients") else None,
                        image_url=any_language_recipe.image_url  # Use same image for translated recipe
                    )
                    db.add(translated_cache)
                    db.commit()
                    
                    # Update recipe_map for future lookups in this request
                    recipe_map[recipe_id] = translated_cache
                    
                    return Recipe(
                        id=translated["id"],
                        emoji=translated.get("emoji", original_recipe["emoji"]),
                        badge=translated.get("badge", original_recipe["badge"]),
                        title=translated.get("title", ""),
                        steps=translated.get("steps", []),
                        ingredients=translated.get("ingredients"),
                        created_at=entry_created_at,
                        image_url=any_language_recipe.image_url  # Use same image for translated recipe
                    )
                except Exception as e:
                    # Translation failed - return None (skip this recipe)
                    return None
            
            return None
        
        # Group entries by batch_id (None means single recipe)
        from collections import defaultdict
        batch_groups = defaultdict(list)
        single_entries = []
        
        for entry in history_entries:
            if entry.generation_batch_id:
                batch_groups[entry.generation_batch_id].append(entry)
            else:
                single_entries.append(entry)
        
        # Build history response with grouped recipes
        history_list = []
        
        # Process batch groups (multiple recipes generated together)
        for batch_id, entries in batch_groups.items():
            # Get all recipes in this batch
            batch_recipes = []
            batch_created_at = None
            
            for entry in entries:
                recipe = await get_or_translate_recipe(entry.recipe_id, entry.created_at)
                if recipe:
                    batch_recipes.append(recipe)
                    if batch_created_at is None or entry.created_at < batch_created_at:
                        batch_created_at = entry.created_at
            
            if batch_recipes:
                # Create combined title (comma-separated, no "and")
                titles = [r.title for r in batch_recipes]
                combined_title = ', '.join(titles)
                
                # Use first recipe as primary
                primary = batch_recipes[0]
                
                history_list.append(HistoryEntry(
                    recipe_id=primary.id,
                    emoji=primary.emoji,
                    badge=primary.badge,
                    title=combined_title,
                    steps=primary.steps,
                    ingredients=primary.ingredients,
                    created_at=batch_created_at,
                    recipes=batch_recipes if len(batch_recipes) > 1 else None
                ))
        
        # Process single entries (no batch_id or old entries)
        for entry in single_entries:
            recipe = await get_or_translate_recipe(entry.recipe_id, entry.created_at)
            if recipe:
                history_list.append(HistoryEntry(
                    recipe_id=recipe.id,
                    emoji=recipe.emoji,
                    badge=recipe.badge,
                    title=recipe.title,
                    steps=recipe.steps,
                    ingredients=recipe.ingredients,
                    created_at=entry.created_at,
                    recipes=None
                ))
        
        # Sort by created_at descending (newest first)
        history_list.sort(key=lambda x: x.created_at, reverse=True)
        
        return HistoryResponse(history=history_list)
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get history: {str(e)}",
            headers={"X-Error-Code": "HISTORY_FETCH_FAILED"}
        )


@router.delete("/history")
async def clear_history(
    appAccountToken: str = Query(..., description="Unique app account token (UUID generated locally)"),
    db: Session = Depends(get_db)
):
    """
    Clear all history for a user.
    
    - **appAccountToken**: Unique app account token (UUID generated locally)
    """
    try:
        deleted_count = (
            db.query(History)
            .filter(History.app_account_token == appAccountToken)
            .delete()
        )
        db.commit()
        
        return {"message": "History cleared successfully", "deleted_count": deleted_count}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to clear history: {str(e)}",
            headers={"X-Error-Code": "HISTORY_CLEAR_FAILED"}
        )


@router.delete("/history/{recipe_id}")
async def delete_history_entry(
    recipe_id: str,
    appAccountToken: str = Query(..., description="Unique app account token (UUID generated locally)"),
    db: Session = Depends(get_db)
):
    """
    Delete a recipe from user's history.
    
    - **recipe_id**: Recipe identifier to delete
    - **appAccountToken**: Unique app account token (UUID generated locally)
    """
    try:
        history_entry = (
            db.query(History)
            .filter(
                History.app_account_token == appAccountToken,
                History.recipe_id == recipe_id
            )
            .first()
        )
        
        if not history_entry:
            raise HTTPException(
                status_code=404,
                detail="History entry not found",
                headers={"X-Error-Code": "HISTORY_ENTRY_NOT_FOUND"}
            )
        
        db.delete(history_entry)
        db.commit()
        
        return {"message": "History entry deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete history entry: {str(e)}",
            headers={"X-Error-Code": "HISTORY_DELETE_FAILED"}
        )
