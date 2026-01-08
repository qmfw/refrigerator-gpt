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
