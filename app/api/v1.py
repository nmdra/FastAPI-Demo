import logging
from fastapi import APIRouter, Request, File, UploadFile, HTTPException
from google.genai import types
from google import genai
from app.api.schemas import CaptionResponse
from app.core.config import GEMINI_API_KEY

logger = logging.getLogger("app.api.v1")
router = APIRouter()

client = genai.Client(api_key=GEMINI_API_KEY)


@router.get("/hello")
async def hello(request: Request):
    client_host = request.client.host if request.client else "unknown"
    logger.info("Hello endpoint called", extra={"client_host": client_host})
    return {"message": "Hello, FastAPI!"}


@router.post("/image/caption", response_model=CaptionResponse)
async def generate_caption(file: UploadFile = File(...)):
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
