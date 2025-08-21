from fastapi import FastAPI
from app.api import v1
from app.core.logging_conf import configure_logging

configure_logging("fastAPI")

app = FastAPI(title="FastAPI Demo")

# Routers
app.include_router(v1.router, prefix="/api/v1")

@app.get("/health")
def health():
    return {"status": "ok"}