import logging
from fastapi import APIRouter, Request

logger = logging.getLogger("app.api.v1")

router = APIRouter()

@router.get("/hello")
async def hello(request: Request):
    client_host = request.client.host if request.client else "unknown"
    logger.info("Hello endpoint called", extra={"client_host": client_host})
    return {"message": "Hello, FastAPI!"}