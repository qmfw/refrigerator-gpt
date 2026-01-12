# FridgeGPT Backend API

A FastAPI-based backend service for the FridgeGPT mobile application. This service provides AI-powered ingredient detection from photos and recipe generation in 27 languages.

## What is FridgeGPT?

FridgeGPT is a mobile application that helps users discover recipes based on ingredients they already have. Users can:

- 📸 **Scan their fridge** - Take photos of ingredients and get them automatically detected
- 🍳 **Generate recipes** - Get personalized recipe suggestions based on available ingredients
- 🌍 **Multilingual support** - Full support for 27 languages
- 📱 **No account required** - Works with device-based identification

## Features

- **Ingredient Detection**: Uses OpenAI Vision API to detect food ingredients from photos
- **Recipe Generation**: Generates personalized recipes using OpenAI GPT-4
- **Multilingual Support**: 27 languages supported (English, Arabic, Bengali, Chinese, Danish, Dutch, Finnish, French, German, Greek, Hebrew, Hindi, Indonesian, Italian, Japanese, Korean, Norwegian, Polish, Portuguese, Romanian, Russian, Spanish, Swedish, Thai, Turkish, Ukrainian, Vietnamese)
- **Subscription Management**: App Store and Play Store receipt verification
- **Usage Tracking**: Daily usage limits and tracking
- **Recipe Caching**: Multi-language recipe caching for faster responses

## Tech Stack

- **Framework**: FastAPI (Python 3.9+)
- **Database**: SQLite (development) / PostgreSQL (production)
- **ORM**: SQLAlchemy
- **Migrations**: Alembic
- **AI Services**: OpenAI (GPT-4o for text, GPT-4o for vision)
- **HTTP Client**: httpx

## Prerequisites

- Python 3.9 or higher
- Docker and Docker Compose (for PostgreSQL)
- OpenAI API key

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd refrigerator-gpt/backend
```

### 2. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Create a `.env` file in the `backend` directory:

```env
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Server Configuration
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=true
ENVIRONMENT=development

# Database (SQLite for development)
DATABASE_URL=sqlite:///./fridgegpt.db

# CORS (comma-separated origins)
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Optional: App Store/Play Store (for production)
# APPLE_SHARED_SECRET=your_shared_secret
# APPLE_ENVIRONMENT=sandbox
# GOOGLE_SERVICE_ACCOUNT_PATH=path/to/service-account.json
# GOOGLE_PACKAGE_NAME=com.yourapp.package
```

**⚠️ Security Note**: Never commit your `.env` file to version control. Add it to `.gitignore`.

### 5. Setup Database

#### Option A: Quick Setup (SQLite - Development)

```bash
# Run setup script
chmod +x scripts/setup.sh
./scripts/setup.sh
```

#### Option B: Manual Setup (PostgreSQL - Production)

```bash
# Start PostgreSQL with Docker
docker compose up -d

# Run migrations
alembic upgrade head
```

### 6. Start the Server

```bash
# Development mode (with auto-reload)
uvicorn main:app --reload

# Production mode
uvicorn main:app --host 0.0.0.0 --port 8000
```

The API will be available at:
- **API**: http://localhost:8000
- **Documentation**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### Health Check
```
GET /api/v1/health
```

### Ingredient Detection
```
POST /api/v1/detect-ingredients
```
- Accepts 1-3 images
- Returns detected ingredients list
- Supports all 27 languages

### Recipe Generation
```
POST /api/v1/generate-recipes
```
- Generates recipes based on ingredients
- Supports diet preferences
- Returns recipes in requested language

### Subscription
```
POST /api/v1/subscription/verify-receipt
GET /api/v1/subscription/status
```

### Usage Tracking
```
GET /api/v1/usage/limits
```

## Project Structure

```
backend/
├── app/                       # Application code
│   ├── config.py              # Configuration settings
│   ├── db.py                  # Database connection
│   ├── models.py              # SQLAlchemy models
│   ├── schemas.py             # Pydantic schemas
│   ├── routers/               # API route handlers
│   │   ├── detection.py       # Ingredient detection
│   │   ├── recipes.py         # Recipe generation
│   │   ├── subscription.py    # Subscription management
│   │   └── usage.py           # Usage tracking
│   └── services/              # Business logic
│       ├── openai_service.py  # OpenAI API integration
│       ├── receipt_service.py # Receipt verification
│       └── usage_service.py  # Usage tracking logic
├── docs/                      # Documentation and design
│   ├── openapi.yaml          # OpenAPI specification
│   └── sql/                   # SQL scripts
│       └── CREATE_DATABASE_SCHEMA.sql
├── scripts/                   # Utility scripts
│   ├── setup.sh              # Setup script
│   └── test_api.py           # API testing script
├── migrations/                # Database migrations
├── main.py                    # FastAPI application entry point
├── requirements.txt           # Python dependencies
├── docker-compose.yml         # PostgreSQL Docker setup
└── .env                       # Environment variables (not in git)
```

## Database Models

- **Subscription**: Caches verified App Store/Play Store receipts
- **UsageLog**: Tracks daily usage limits per app instance
- **RecipeCache**: Stores generated recipes for multi-language support
- **History**: Stores user recipe history (optional, can be client-side)

## Language Support

The backend supports 27 languages through:
- Language-specific prompts for ingredient detection
- Language-specific recipe generation
- Multi-language recipe caching
- Language-specific food descriptions

See `LANGUAGE_GUIDE.md` for details on adding new languages.

## Development

### Running Tests

```bash
# Install test dependencies
pip install pytest pytest-asyncio

# Run tests
pytest
```

### Database Migrations

```bash
# Create a new migration
alembic revision --autogenerate -m "Description of changes"

# Apply migrations
alembic upgrade head

# Rollback migration
alembic downgrade -1
```

### Code Style

The project follows PEP 8 style guidelines. Consider using:
- `black` for code formatting
- `flake8` for linting
- `mypy` for type checking

## Production Deployment

### Environment Variables

For production, set:
- `ENVIRONMENT=production`
- `DEBUG=false`
- `DATABASE_URL` to your PostgreSQL connection string
- All required API keys and secrets

### Database

Use PostgreSQL in production:
```env
DATABASE_URL=postgresql://user:password@host:port/database
```

## Troubleshooting

### Database Connection Issues

```bash
# Check if PostgreSQL is running
docker ps

# Check database connection
python3 -c "from app.db import engine; engine.connect()"
```

### Migration Issues

```bash
# Check current migration status
alembic current

# View migration history
alembic history

# Fix migration revision if needed
# (See scripts/setup.sh for automatic fix)
```

### OpenAI API Issues

- Verify your API key is set correctly in `.env`
- Check your OpenAI account has sufficient credits
- Verify API rate limits haven't been exceeded

## License

MIT License

## Support

For issues and questions, please open an issue in the repository.
