#!/bin/bash
# Setup script for FridgeGPT Backend

set -e

echo "🚀 Setting up FridgeGPT Backend..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Start PostgreSQL with Docker
echo "🐘 Starting PostgreSQL..."
docker compose up -d

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 5

# Create initial migration
echo "📝 Creating initial migration..."
alembic revision --autogenerate -m "Initial migration" || echo "⚠️  Migration already exists or database not ready"

# Fix migration revision if needed (when migrations are consolidated or deleted)
echo "🔧 Checking migration revision..."
python3 << 'EOF'
import sys
import os
import subprocess
from sqlalchemy import create_engine, text, inspect
from app.config import settings

try:
    # Get head revision from alembic
    result = subprocess.run(
        ["alembic", "heads"],
        capture_output=True,
        text=True,
        cwd="."
    )
    if result.returncode != 0 or not result.stdout.strip():
        print("⚠️  Could not get head revision from alembic")
        sys.exit(0)
    
    head_revision = result.stdout.strip().split()[0]
    
    engine = create_engine(settings.database_url)
    with engine.connect() as conn:
        # Check if alembic_version table exists
        inspector = inspect(engine)
        if 'alembic_version' not in inspector.get_table_names():
            print("ℹ️  alembic_version table does not exist yet - will be created by migrations")
            sys.exit(0)
        
        # Get current revision from database
        result = conn.execute(text("SELECT version_num FROM alembic_version"))
        current_revision = result.scalar()
        
        if current_revision and current_revision != head_revision:
            # Check if current revision exists in migration files
            migration_dir = "migrations/versions"
            revision_exists = False
            if os.path.exists(migration_dir):
                migration_files = os.listdir(migration_dir)
                revision_exists = any(current_revision in f for f in migration_files)
            
            if not revision_exists:
                print(f"⚠️  Current revision '{current_revision}' not found in migration files")
                print(f"🔄 Updating to head revision '{head_revision}'...")
                conn.execute(text(f"UPDATE alembic_version SET version_num = '{head_revision}'"))
                conn.commit()
                print(f"✅ Successfully updated alembic_version to '{head_revision}'")
            elif current_revision != head_revision:
                # Revision exists but is not head - this is normal if migrations are ahead
                print(f"ℹ️  Current revision '{current_revision}' is valid (head is '{head_revision}')")
        elif current_revision == head_revision:
            print(f"✅ Current revision '{current_revision}' matches head")
except Exception as e:
    print(f"⚠️  Could not check migration revision: {e}")
    # Don't fail setup if this check fails
    sys.exit(0)
EOF

# Run migrations
echo "🔄 Running migrations..."
alembic upgrade head || echo "⚠️  Migrations may have failed - check database connection"

echo "✅ Setup complete!"
echo ""
echo "To start the server:"
echo "  source venv/bin/activate"
echo "  uvicorn main:app --reload"
echo ""
echo "To stop PostgreSQL:"
echo "  docker compose down"
