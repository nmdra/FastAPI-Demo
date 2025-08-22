import logging
import sys
from pythonjsonlogger.json import JsonFormatter
from app.core.config import LOG_LEVEL


class _ExcludeHealthFilter(logging.Filter):
    """Optionally exclude overly chatty health checks."""

    def filter(self, record: logging.LogRecord) -> bool:
        msg = getattr(record, "msg", "")
        return not (isinstance(msg, str) and "GET /health" in msg)


level_mapping = {
    "DEBUG": logging.DEBUG,
    "INFO": logging.INFO,
    "WARNING": logging.WARNING,
    "ERROR": logging.ERROR,
    "CRITICAL": logging.CRITICAL,
}


def configure_logging(service_name: str = "fastapi-demo") -> None:
    handler = logging.StreamHandler(sys.stdout)
    formatter = JsonFormatter(
        fmt="%(asctime)s %(levelname)s %(name)s %(message)s", json_ensure_ascii=False
    )
    handler.setFormatter(formatter)

    root = logging.getLogger()

    log_level = level_mapping.get(
        LOG_LEVEL.upper() if LOG_LEVEL else "INFO", logging.INFO
    )
    root.setLevel(log_level)
    root.handlers = [handler]
    root.addFilter(_ExcludeHealthFilter())

    # Enrich logs with service context via a custom adapter if desired
    logging.LoggerAdapter(root, extra={"service": service_name})
