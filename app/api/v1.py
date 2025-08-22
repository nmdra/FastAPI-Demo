import logging
from fastapi import APIRouter, File, UploadFile, HTTPException
from google.genai import types
from google import genai
from app.api.schemas import CaptionResponse
from app.core.config import GEMINI_API_KEY
from prometheus_client import Counter

caption_requests = Counter(
    "image_caption_requests_total", "Total number of image caption requests"
)

logger = logging.getLogger("app.api.v1")
router = APIRouter()

client = genai.Client(api_key=GEMINI_API_KEY)


@router.post("/image/caption", response_model=CaptionResponse)
async def generate_caption(file: UploadFile = File(...)):
    caption_requests.inc()

    if file.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(
            status_code=400, detail="Only JPEG or PNG images are supported."
        )
    try:
        image_bytes = await file.read()
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                types.Part.from_bytes(data=image_bytes, mime_type=file.content_type),
                "Provide a caption for this image.",
            ],
            config={
                "response_mime_type": "application/json",
                "response_schema": CaptionResponse,
            },
        )
        caption_obj: CaptionResponse = response.parsed
        logger.debug("Generated caption: %s", caption_obj.caption)
        return caption_obj
    except Exception as e:
        logger.exception("Failed to generate caption")
        raise HTTPException(status_code=500, detail=str(e))
