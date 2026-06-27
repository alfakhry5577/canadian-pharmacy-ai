import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import get_settings
from app.core.database import Base, engine
from app.api.router import api_router
import app.models  # noqa: F401  ensures all models are registered on Base.metadata

settings = get_settings()

app = FastAPI(
    title=settings.APP_NAME,
    description="منصة ذكية للصيدليات: تحليل الوصفات بالـ OCR والذكاء الاصطناعي، بحث الأدوية، "
                "المخزون، التنبيهات الدوائية، والدردشة الذكية الآمنة.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)

# Serves uploaded prescription images back to the frontend at /uploads/<filename>.
# NOTE for production: swap this for a private bucket (S3/GCS) with signed URLs —
# prescription photos are sensitive health data and shouldn't sit on local disk
# behind a public static route long-term.
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")


@app.on_event("startup")
def on_startup():
    # For local development / demos. In production, use Alembic migrations
    # against PostgreSQL instead of create_all().
    Base.metadata.create_all(bind=engine)


@app.get("/")
def root():
    return {
        "app": settings.APP_NAME,
        "status": "running",
        "docs": "/docs",
    }


@app.get("/health")
def health():
    return {"status": "ok"}
