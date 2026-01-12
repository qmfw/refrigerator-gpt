"""Database models"""
from sqlalchemy import Column, String, DateTime, Integer, Date, Index, UniqueConstraint
from sqlalchemy.sql import func
from app.db import Base
import uuid


class Subscription(Base):
    """Subscription model - caches verified App Store/Play Store receipts"""
    __tablename__ = "subscriptions"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))  # Use String for SQLite compatibility
    platform = Column(String(10), nullable=False)  # 'ios' or 'android'
    app_account_token = Column(String(36), nullable=False, index=True)  # Use String for SQLite compatibility
    original_transaction_id = Column(String(255))  # iOS: original transaction ID
    purchase_token = Column(String(500))  # Android: purchase token
    product_id = Column(String(255), nullable=False)  # 'premium' or 'premium_annual'
    status = Column(String(50), nullable=False)  # 'active', 'expired', 'cancelled'
    expires_at = Column(DateTime(timezone=True))  # Subscription expiration
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    __table_args__ = (
        UniqueConstraint('app_account_token', 'platform', name='uq_subscriptions_token_platform'),
        Index('idx_subscriptions_token', 'app_account_token'),
        Index('idx_subscriptions_status', 'status', 'expires_at'),
    )


class UsageLog(Base):
    """Usage tracking model - tracks daily usage limits per app instance"""
    __tablename__ = "usage_logs"
    
    app_account_token = Column(String(36), primary_key=True, nullable=False)  # Use String for SQLite compatibility
    feature = Column(String(100), primary_key=True, nullable=False)  # 'scan', 'recipe_generation'
    date = Column(Date, primary_key=True, nullable=False)
    count = Column(Integer, default=1, nullable=False)
    
    __table_args__ = (
        Index('idx_usage_token_date', 'app_account_token', 'date'),
    )


class RecipeCache(Base):
    """Recipe cache model - stores generated recipes for multi-language support"""
    __tablename__ = "recipe_cache"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))  # Use String for SQLite compatibility
    recipe_id = Column(String(255), nullable=False, index=True)  # Original recipe ID from generation
    language = Column(String(10), nullable=False, index=True)  # Language code (en, es, ja, etc.)
    emoji = Column(String(10), nullable=False)
    badge = Column(String(50), nullable=False)  # fastLazy, actuallyGood, shouldntWork
    title = Column(String(500), nullable=False)
    steps = Column(String, nullable=False)  # JSON array of steps
    ingredients = Column(String, nullable=True)  # JSON array of ingredients
    image_url = Column(String(500), nullable=True)  # Foodish API image URL (free food images)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    __table_args__ = (
        UniqueConstraint('recipe_id', 'language', name='uq_recipe_language'),
        Index('idx_recipe_id', 'recipe_id'),
        Index('idx_recipe_language', 'recipe_id', 'language'),
    )


class History(Base):
    """History model - stores user's recipe history"""
    __tablename__ = "history"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))  # Use String for SQLite compatibility
    app_account_token = Column(String(36), nullable=False, index=True)  # User identifier
    recipe_id = Column(String(255), nullable=False, index=True)  # Recipe identifier
    generation_batch_id = Column(String(36), nullable=True, index=True)  # Groups recipes generated together
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    __table_args__ = (
        Index('idx_history_token', 'app_account_token'),
        Index('idx_history_token_created', 'app_account_token', 'created_at'),
        Index('idx_history_batch', 'generation_batch_id'),
    )


