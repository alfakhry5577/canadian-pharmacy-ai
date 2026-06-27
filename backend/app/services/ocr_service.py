"""
OCR Service
-----------
Extracts raw text from a prescription image using Tesseract (ara+eng).

This is intentionally isolated behind a small interface (`extract_text`) so it can
be swapped later for a stronger cloud OCR/Document-AI service without touching
any other part of the app — just replace the implementation of `extract_text`.
"""
import logging

from PIL import Image, ImageOps, ImageFilter

from app.core.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

try:
    import pytesseract
    TESSERACT_AVAILABLE = True
except ImportError:  # pragma: no cover
    TESSERACT_AVAILABLE = False


def _preprocess(image: Image.Image) -> Image.Image:
    """Light preprocessing to improve OCR accuracy on photographed prescriptions."""
    gray = ImageOps.grayscale(image)
    gray = ImageOps.autocontrast(gray)
    gray = gray.filter(ImageFilter.SHARPEN)
    return gray


def extract_text(image_path: str) -> str:
    """
    Returns the raw OCR text from the prescription image.
    Falls back to an empty string (with a logged warning) if Tesseract
    is not installed in the environment — the AI service will still run
    on whatever text is available and the pharmacist can transcribe manually.
    """
    if not TESSERACT_AVAILABLE:
        logger.warning(
            "pytesseract/tesseract-ocr is not installed. "
            "Install tesseract-ocr + tesseract-ocr-ara, or plug in a cloud OCR provider."
        )
        return ""

    try:
        image = Image.open(image_path)
        processed = _preprocess(image)
        text = pytesseract.image_to_string(processed, lang=settings.TESSERACT_LANGS)
        return text.strip()
    except Exception as exc:  # noqa: BLE001
        logger.exception("OCR extraction failed for %s: %s", image_path, exc)
        return ""
