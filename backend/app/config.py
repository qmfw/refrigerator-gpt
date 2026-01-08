"""Application configuration"""
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # Server
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    debug: bool = True
    environment: str = "development"
    
    # CORS
    cors_origins: str = "http://localhost:3000,http://localhost:8080"
    
    # OpenAI
    openai_api_key: str
    openai_model_vision: str = "gpt-4o"
    openai_model_text: str = "gpt-4o"
    openai_max_tokens: int = 2000
    openai_temperature: float = 0.7
    
    # Database
    # Default to SQLite for development, PostgreSQL for production
    database_url: str = "sqlite:///./fridgegpt.db"
    
    # App Store (iOS)
    apple_shared_secret: Optional[str] = None
    apple_environment: str = "sandbox"  # sandbox or production
    
    # Google Play (Android)
    google_service_account_path: Optional[str] = None
    google_api_key: Optional[str] = None
    google_package_name: Optional[str] = None
    
    # File Storage
    upload_dir: str = "./uploads"
    max_upload_size: int = 10485760  # 10MB
    
    # Rate Limiting
    rate_limit_per_minute: int = 60
    
    # Logging
    log_level: str = "INFO"
    
    # API Version
    api_version: str = "v1"
    
    class Config:
        env_file = ".env"
        case_sensitive = False
        extra = "ignore"  # Ignore extra fields in .env that aren't in Settings


settings = Settings()

