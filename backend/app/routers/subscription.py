"""Subscription router - receipt verification and status"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime

from app.db import get_db
from app.models import Subscription
from app.services.receipt_service import receipt_service
from app.services.usage_service import usage_service
from app.schemas import SubscriptionStatus, ErrorResponse

router = APIRouter(prefix="/api/v1/subscription", tags=["Subscription"])


class VerifyReceiptRequest(BaseModel):
    """Request model for receipt verification"""
    receipt_data: str = Field(..., description="Base64-encoded receipt from App Store or Play Store")
    app_account_token: UUID = Field(..., description="Unique app account token (UUID generated locally)")
    platform: str = Field(..., description="Platform: 'ios' or 'android'", pattern="^(ios|android)$")
    product_id: Optional[str] = Field(None, description="Product ID (subscription ID) - required for Android, optional for iOS (extracted from receipt)")


@router.post("/verify-receipt")
async def verify_receipt(
    request: VerifyReceiptRequest,
    db: Session = Depends(get_db)
):
    """
    Verify App Store/Play Store receipt and cache subscription status.
    
    Returns subscription status after verification.
    """
    try:
        # Verify receipt based on platform
        if request.platform == "ios":
            result = await receipt_service.verify_apple_receipt(
                receipt_data=request.receipt_data,
                app_account_token=str(request.app_account_token)
            )
            # Product ID is extracted from Apple receipt
            if not result.get("product_id") and request.product_id:
                # Fallback to provided product_id if receipt doesn't have it
                result["product_id"] = request.product_id
        elif request.platform == "android":
            # For Android, product_id is required to verify the receipt
            if not request.product_id:
                raise HTTPException(
                    status_code=400,
                    detail="product_id is required for Android receipt verification",
                    headers={"X-Error-Code": "MISSING_PRODUCT_ID"}
                )
            result = await receipt_service.verify_google_receipt(
                purchase_token=request.receipt_data,  # For Android, receipt_data is purchase_token
                product_id=request.product_id,
                app_account_token=str(request.app_account_token)
            )
            # Ensure product_id is in result (it's the subscriptionId we passed)
            if not result.get("product_id"):
                result["product_id"] = request.product_id
        else:
            raise HTTPException(
                status_code=400,
                detail="Invalid platform. Must be 'ios' or 'android'",
                headers={"X-Error-Code": "INVALID_PLATFORM"}
            )
        
        if not result.get("valid"):
            raise HTTPException(
                status_code=401,
                detail=f"Receipt verification failed: {result.get('error', 'Unknown error')}"
            )
        
        # Parse expiration date
        expires_at = None
        if result.get("expires_at"):
            try:
                expires_at = datetime.fromisoformat(result["expires_at"].replace("Z", "+00:00"))
            except (ValueError, AttributeError):
                pass
        
        # Store or update subscription in database
        subscription = (
            db.query(Subscription)
            .filter(
                Subscription.app_account_token == request.app_account_token,
                Subscription.platform == request.platform
            )
            .first()
        )
        
        if subscription:
            # Update existing subscription
            subscription.product_id = result.get("product_id", "premium")
            subscription.status = result.get("status", "active")
            subscription.expires_at = expires_at
            subscription.original_transaction_id = result.get("original_transaction_id") if request.platform == "ios" else None
            subscription.purchase_token = result.get("purchase_token") if request.platform == "android" else None
        else:
            # Create new subscription
            subscription = Subscription(
                platform=request.platform,
                app_account_token=request.app_account_token,
                original_transaction_id=result.get("original_transaction_id") if request.platform == "ios" else None,
                purchase_token=result.get("purchase_token") if request.platform == "android" else None,
                product_id=result.get("product_id", "premium"),
                status=result.get("status", "active"),
                expires_at=expires_at
            )
            db.add(subscription)
        
        db.commit()
        db.refresh(subscription)
        
        # Determine plan from product_id
        plan = "free"
        if subscription.product_id in ["premium", "premium_annual"]:
            plan = subscription.product_id
        
        return SubscriptionStatus(
            plan=plan,
            status=subscription.status,
            expires_at=subscription.expires_at,
            started_at=subscription.created_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Internal server error: {str(e)}",
            headers={"X-Error-Code": "INTERNAL_ERROR"}
        )


@router.get("/status")
async def get_subscription_status(
    appAccountToken: UUID = Query(..., description="Unique app account token"),
    db: Session = Depends(get_db)
):
    """
    Get subscription status for a given appAccountToken.
    
    Returns 'free' plan if no subscription found.
    """
    subscription = (
        db.query(Subscription)
        .filter(Subscription.app_account_token == appAccountToken)
        .order_by(Subscription.created_at.desc())
        .first()
    )
    
    if not subscription:
        # No subscription found - return free plan
        return SubscriptionStatus(
            plan="free",
            status="active",
            expires_at=None,
            started_at=None
        )
    
    # Check if subscription is expired
    current_status = subscription.status
    if subscription.expires_at and subscription.expires_at < datetime.now():
        current_status = "expired"
        # Update database
        subscription.status = "expired"
        db.commit()
    
    # Determine plan from product_id
    plan = "free"
    if subscription.product_id in ["premium", "premium_annual"]:
        plan = subscription.product_id
    
    return SubscriptionStatus(
        plan=plan,
        status=current_status,
        expires_at=subscription.expires_at,
        started_at=subscription.created_at
    )
