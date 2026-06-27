"""
Application configuration.
All sensitive values are read from environment variables — never hardcoded.
"""
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    APP_NAME: str = "Roshetta AI - Pharmacy Assistant"
    ENV: str = "development"

    # Database — defaults to local SQLite for zero-config development.
    # In production, set DATABASE_URL to a PostgreSQL connection string, e.g.:
    # postgresql+psycopg2://user:password@localhost:5432/roshetta
    DATABASE_URL: str = "sqlite:///./roshetta.db"

    # JWT auth
    JWT_SECRET_KEY: str = "CHANGE_ME_IN_PRODUCTION_USE_A_LONG_RANDOM_SECRET"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 12  # 12 hours

    # OCR
    TESSERACT_LANGS: str = "ara+eng"

    # AI provider — the AI service is provider-agnostic.
    # Set ANTHROPIC_API_KEY to enable real AI analysis / chat.
    # Without it, the service falls back to a clearly-labeled rule-based mock
    # so the rest of the app remains fully testable offline.
    ANTHROPIC_API_KEY: str | None = None
    AI_MODEL: str = "claude-sonnet-4-6"

    # Uploads
    UPLOAD_DIR: str = "./uploads"
    MAX_UPLOAD_SIZE_MB: int = 10

    # CORS
    ALLOWED_ORIGINS: list[str] = ["http://localhost:3000"]

    class Config:
        env_file = ".env"


@lru_cache
def get_settings() -> Settings:
    return Settings()
