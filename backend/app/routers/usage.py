"""Usage router - usage limits and tracking"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db import get_db
from app.models import Subscription
from app.services.usage_service import usage_service
from app.schemas import UsageLimits
from datetime import datetime

router = APIRouter(prefix="/api/v1/usage", tags=["Usage"])


@router.get("/limits")
async def get_usage_limits(
    appAccountToken: str = Query(..., description="Unique app account token"),
    db: Session = Depends(get_db)
):
    """
    Get usage limits and today's usage count for a given appAccountToken.
    """
    # Check if user has premium subscription
    subscription = (
        db.query(Subscription)
        .filter(Subscription.app_account_token == appAccountToken)
        .order_by(Subscription.created_at.desc())
        .first()
    )
    
    is_premium = False
    if subscription:
        # Check if subscription is active and not expired
        if subscription.status == "active":
            if subscription.expires_at is None or subscription.expires_at > datetime.now():
                is_premium = subscription.product_id in ["premium", "premium_annual"]
    
    # Get usage limits
    limits = usage_service.get_usage_limits(
        db=db,
        app_account_token=appAccountToken,
        is_premium=is_premium
    )
    
    return UsageLimits(**limits)
