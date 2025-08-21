import os

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
LOG_LEVEL = os.environ.get("LOG_LEVEL")

if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY environment variable is not set.")

if not LOG_LEVEL:
    LOG_LEVEL="INFO"