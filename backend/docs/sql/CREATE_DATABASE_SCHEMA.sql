-- ============================================================================
-- DROP EXISTING TABLES AND INDEXES (for clean reset)
-- ============================================================================

-- Drop indexes first
DROP INDEX IF EXISTS idx_history_batch;
DROP INDEX IF EXISTS idx_history_token_created;
DROP INDEX IF EXISTS idx_history_token;
DROP INDEX IF EXISTS idx_recipe_language;
DROP INDEX IF EXISTS idx_recipe_id;
DROP INDEX IF EXISTS idx_usage_token_date;
DROP INDEX IF EXISTS idx_subscriptions_status;
DROP INDEX IF EXISTS idx_subscriptions_token;

-- Drop unique constraints (SQLite syntax)
-- Note: SQLite doesn't support DROP INDEX for unique constraints directly
-- They are dropped when the table is dropped

-- Drop tables
DROP TABLE IF EXISTS history;
DROP TABLE IF EXISTS recipe_cache;
DROP TABLE IF EXISTS usage_logs;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS alembic_version;

-- ============================================================================
-- CREATE TABLES (matching current migration: cd6e98d4e2be)
-- ============================================================================

-- Create subscriptions table (for premium features)
CREATE TABLE subscriptions (
    id VARCHAR(36) NOT NULL,  -- Use String for SQLite compatibility
    platform VARCHAR(10) NOT NULL,
    app_account_token VARCHAR(36) NOT NULL,  -- Use String for SQLite
    original_transaction_id VARCHAR(255),
    purchase_token VARCHAR(500),
    product_id VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY (id),
    UNIQUE (app_account_token, platform)
);

CREATE INDEX idx_subscriptions_status ON subscriptions(status, expires_at);
CREATE INDEX idx_subscriptions_token ON subscriptions(app_account_token);

-- Create usage_logs table (for usage tracking)
CREATE TABLE usage_logs (
    app_account_token VARCHAR(36) NOT NULL,  -- Use String for SQLite
    feature VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    count INTEGER NOT NULL,
    PRIMARY KEY (app_account_token, feature, date)
);

CREATE INDEX idx_usage_token_date ON usage_logs(app_account_token, date);

-- Create recipe_cache table (for multi-language recipe support)
CREATE TABLE recipe_cache (
    id VARCHAR(36) NOT NULL,
    recipe_id VARCHAR(255) NOT NULL,
    language VARCHAR(10) NOT NULL,
    emoji VARCHAR(10) NOT NULL,  -- Kept as fallback if image generation fails
    badge VARCHAR(50) NOT NULL,
    title VARCHAR(500) NOT NULL,
    steps TEXT NOT NULL,
    ingredients TEXT,
    -- image_url VARCHAR(500),  -- AI-generated image URL (DALL-E)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY (id),
    UNIQUE (recipe_id, language)
);

CREATE INDEX idx_recipe_id ON recipe_cache(recipe_id);
CREATE INDEX idx_recipe_language ON recipe_cache(recipe_id, language);

-- Create history table (for storing user's recipe history)
CREATE TABLE history (
    id VARCHAR(36) NOT NULL,
    app_account_token VARCHAR(36) NOT NULL,
    recipe_id VARCHAR(255) NOT NULL,
    generation_batch_id VARCHAR(36),  -- Groups recipes generated together
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP) NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX idx_history_token ON history(app_account_token);
CREATE INDEX idx_history_token_created ON history(app_account_token, created_at);
CREATE INDEX idx_history_batch ON history(generation_batch_id);

-- Create alembic_version table (for Alembic migration tracking)
CREATE TABLE alembic_version (
    version_num VARCHAR(32) NOT NULL PRIMARY KEY
);

-- Insert current migration version
INSERT INTO alembic_version (version_num) 
VALUES ('cd6e98d4e2be')
ON CONFLICT (version_num) DO NOTHING;

