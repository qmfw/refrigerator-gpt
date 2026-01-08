"""Detection router - ingredient detection from images"""
from fastapi import APIRouter, File, UploadFile, Form, HTTPException, Depends
from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from app.config import settings
from app.db import get_db
from app.models import Subscription
from app.services.usage_service import usage_service
from app.services.openai_service import openai_service
from app.schemas import IngredientDetectionResponse, ErrorResponse
from datetime import datetime
import io

router = APIRouter(prefix="/api/v1", tags=["Detection"])


@router.post("/detect-ingredients")
async def detect_ingredients(
    images: List[UploadFile] = File(...),
    language: str = Form("en"),
    appAccountToken: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """
    Detect ingredients from uploaded images.
    
    - **images**: 1-3 image files (JPEG, PNG, WebP, max 10MB each)
    - **language**: Language code (default: en)
    - **appAccountToken**: Optional UUID for usage tracking
    """
    # Validate number of images
    if len(images) > 3:
        raise HTTPException(
            status_code=400,
            detail="Maximum 3 images allowed per request",
            headers={"X-Error-Code": "TOO_MANY_IMAGES"}
        )
    
    if len(images) == 0:
        raise HTTPException(
            status_code=400,
            detail="At least 1 image is required",
            headers={"X-Error-Code": "NO_IMAGES"}
        )
    
    # Validate and process images
    image_bytes_list = []
    for image in images:
        # Check file size
        contents = await image.read()
        if len(contents) > settings.max_upload_size:
            raise HTTPException(
                status_code=413,
                detail=f"Image {image.filename} exceeds maximum size of {settings.max_upload_size} bytes",
                headers={"X-Error-Code": "PAYLOAD_TOO_LARGE"}
            )
        
        # Validate image format
        if not image.content_type or not image.content_type.startswith('image/'):
            raise HTTPException(
                status_code=400,
                detail=f"Invalid file type: {image.filename}. Only images are allowed.",
                headers={"X-Error-Code": "INVALID_FILE_TYPE"}
            )
        
        # Validate specific formats
        allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
        if image.content_type.lower() not in allowed_types:
            raise HTTPException(
                status_code=400,
                detail=f"Unsupported image format: {image.content_type}. Allowed: JPEG, PNG, WebP",
                headers={"X-Error-Code": "UNSUPPORTED_IMAGE_FORMAT"}
            )
        
        image_bytes_list.append(contents)
        # Reset file pointer for potential reuse
        await image.seek(0)
    
    # Check usage limits if appAccountToken provided
    if appAccountToken:
        try:
            # Check if premium
            subscription = (
                db.query(Subscription)
                .filter(Subscription.app_account_token == UUID(appAccountToken))
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
                app_account_token=appAccountToken,
                feature="scan",
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
                app_account_token=appAccountToken,
                feature="scan"
            )
        except ValueError:
            # Invalid UUID format - skip usage tracking
            pass
    
    # Call OpenAI Vision API
    try:
        result = await openai_service.detect_ingredients(
            images=image_bytes_list,
            language=language
        )
        return IngredientDetectionResponse(**result)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to detect ingredients: {str(e)}",
            headers={"X-Error-Code": "DETECTION_FAILED"}
        )
