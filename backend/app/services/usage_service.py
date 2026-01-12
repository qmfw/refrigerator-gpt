"""Usage tracking service"""
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from datetime import date
from app.models import UsageLog
from typing import Dict, Any


class UsageService:
    """Service for tracking and checking usage limits"""
    
    # Free tier limits
    FREE_LIMITS = {
        "scan": 10,  # 10 scans per day
        "recipe_generation": 30,  # 30 recipes per day (3 per scan * 10 scans)
    }
    
    # Premium tier limits (unlimited = -1)
    PREMIUM_LIMITS = {
        "scan": -1,  # Unlimited
        "recipe_generation": -1,  # Unlimited
    }
    
    def get_usage_limits(
        self,
        db: Session,
        app_account_token: str,
        is_premium: bool = False
    ) -> Dict[str, Any]:
        """
        Get usage limits and today's usage for an app instance
        
        Args:
            db: Database session
            app_account_token: App account token (UUID)
            is_premium: Whether user has premium subscription
            
        Returns:
            Dict with usage limits and today's counts
        """
        limits = self.PREMIUM_LIMITS if is_premium else self.FREE_LIMITS
        today = date.today()
        
        # Get today's usage
        usage_today = (
            db.query(UsageLog.feature, func.sum(UsageLog.count).label('total'))
            .filter(
                and_(
                    UsageLog.app_account_token == str(app_account_token),
                    UsageLog.date == today
                )
            )
            .group_by(UsageLog.feature)
            .all()
        )
        
        # Convert to dict
        usage_dict = {row.feature: row.total for row in usage_today}
        
        return {
            "scans_today": usage_dict.get("scan", 0),
            "scans_limit": limits["scan"],
            "recipes_today": usage_dict.get("recipe_generation", 0),
            "recipes_limit": limits["recipe_generation"],
            "is_premium": is_premium,
        }
    
    def increment_usage(
        self,
        db: Session,
        app_account_token: str,
        feature: str
    ) -> None:
        """
        Increment usage count for a feature
        
        Args:
            db: Database session
            app_account_token: App account token (UUID)
            feature: Feature name ('scan' or 'recipe_generation')
        """
        today = date.today()
        token_str = str(app_account_token)
        
        # Try to get existing record
        usage = (
            db.query(UsageLog)
            .filter(
                and_(
                    UsageLog.app_account_token == token_str,
                    UsageLog.feature == feature,
                    UsageLog.date == today
                )
            )
            .first()
        )
        
        if usage:
            # Increment existing count
            usage.count += 1
        else:
            # Create new record
            usage = UsageLog(
                app_account_token=token_str,
                feature=feature,
                date=today,
                count=1
            )
            db.add(usage)
        
        db.commit()
    
    def check_limit(
        self,
        db: Session,
        app_account_token: str,
        feature: str,
        is_premium: bool = False
    ) -> tuple[bool, str]:
        """
        Check if usage limit has been reached
        
        Args:
            db: Database session
            app_account_token: App account token (UUID)
            feature: Feature name ('scan' or 'recipe_generation')
            is_premium: Whether user has premium subscription
            
        Returns:
            Tuple of (allowed: bool, message: str)
        """
        limits = self.PREMIUM_LIMITS if is_premium else self.FREE_LIMITS
        limit = limits.get(feature, 0)
        
        # Premium users with unlimited access
        if limit == -1:
            return True, "Unlimited access"
        
        # Get today's usage
        today = date.today()
        token_str = str(app_account_token)
        
        total = (
            db.query(func.sum(UsageLog.count))
            .filter(
                and_(
                    UsageLog.app_account_token == token_str,
                    UsageLog.feature == feature,
                    UsageLog.date == today
                )
            )
            .scalar() or 0
        )
        
        if total >= limit:
            return False, f"Daily limit reached: {limit} {feature}(s) per day"
        
        return True, f"{limit - total} {feature}(s) remaining today"


usage_service = UsageService()

