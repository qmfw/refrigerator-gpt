"""Add recipe_cache table for multi-language support

Revision ID: cd6e98d4e2be
Revises: 
Create Date: 2026-01-03 21:40:44.066429

This migration creates the initial database schema including:
- subscriptions table (for premium features)
- usage_logs table (for usage tracking)
- recipe_cache table (for multi-language recipe support)
- history table (for storing user's recipe history)

Note: This is the initial migration. All tables are created together.
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import sqlite

# revision identifiers, used by Alembic.
revision = 'cd6e98d4e2be'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create subscriptions table (for premium features)
    op.create_table('subscriptions',
    sa.Column('id', sa.String(length=36), nullable=False),  # Use String for SQLite compatibility
    sa.Column('platform', sa.String(length=10), nullable=False),
    sa.Column('app_account_token', sa.String(length=36), nullable=False),  # Use String for SQLite
    sa.Column('original_transaction_id', sa.String(length=255), nullable=True),
    sa.Column('purchase_token', sa.String(length=500), nullable=True),
    sa.Column('product_id', sa.String(length=255), nullable=False),
    sa.Column('status', sa.String(length=50), nullable=False),
    sa.Column('expires_at', sa.DateTime(timezone=True), nullable=True),
    sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=True),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('app_account_token', 'platform', name='uq_subscriptions_token_platform')
    )
    op.create_index('idx_subscriptions_status', 'subscriptions', ['status', 'expires_at'], unique=False)
    op.create_index('idx_subscriptions_token', 'subscriptions', ['app_account_token'], unique=False)
    
    # Create usage_logs table (for usage tracking)
    op.create_table('usage_logs',
    sa.Column('app_account_token', sa.String(length=36), nullable=False),  # Use String for SQLite
    sa.Column('feature', sa.String(length=100), nullable=False),
    sa.Column('date', sa.Date(), nullable=False),
    sa.Column('count', sa.Integer(), nullable=False),
    sa.PrimaryKeyConstraint('app_account_token', 'feature', 'date')
    )
    op.create_index('idx_usage_token_date', 'usage_logs', ['app_account_token', 'date'], unique=False)
    
    # Create recipe_cache table (for multi-language recipe support)
    op.create_table('recipe_cache',
    sa.Column('id', sa.String(length=36), nullable=False),
    sa.Column('recipe_id', sa.String(length=255), nullable=False),
    sa.Column('language', sa.String(length=10), nullable=False),
    sa.Column('emoji', sa.String(length=10), nullable=False),
    sa.Column('badge', sa.String(length=50), nullable=False),
    sa.Column('title', sa.String(length=500), nullable=False),
    sa.Column('steps', sa.String(), nullable=False),
    sa.Column('ingredients', sa.String(), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=True),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('recipe_id', 'language', name='uq_recipe_language')
    )
    op.create_index('idx_recipe_id', 'recipe_cache', ['recipe_id'], unique=False)
    op.create_index('idx_recipe_language', 'recipe_cache', ['recipe_id', 'language'], unique=False)
    
    # Create history table (for storing user's recipe history)
    op.create_table('history',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('app_account_token', sa.String(length=36), nullable=False),
        sa.Column('recipe_id', sa.String(length=255), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('idx_history_token', 'history', ['app_account_token'], unique=False)
    op.create_index('idx_history_token_created', 'history', ['app_account_token', 'created_at'], unique=False)


def downgrade() -> None:
    # Drop tables in reverse order
    op.drop_index('idx_history_token_created', table_name='history')
    op.drop_index('idx_history_token', table_name='history')
    op.drop_table('history')
    
    op.drop_index('idx_recipe_language', table_name='recipe_cache')
    op.drop_index('idx_recipe_id', table_name='recipe_cache')
    op.drop_table('recipe_cache')
    
    op.drop_index('idx_usage_token_date', table_name='usage_logs')
    op.drop_table('usage_logs')
    
    op.drop_index('idx_subscriptions_token', table_name='subscriptions')
    op.drop_index('idx_subscriptions_status', table_name='subscriptions')
    op.drop_table('subscriptions')
