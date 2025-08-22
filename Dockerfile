FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_TOOL_BIN_DIR=/usr/local/bin

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/uv \
   --mount=type=bind,source=uv.lock,target=uv.lock \
   --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
   uv sync --locked --no-install-project --no-dev

COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev


FROM python:3.13-slim-bookworm AS development

RUN useradd -m app

COPY --from=builder --chown=app:app /app /app
WORKDIR /app

ENV PATH="/app/.venv/bin:$PATH"

USER app

ENTRYPOINT []

CMD ["fastapi", "dev", "--host", "0.0.0.0", "app/main.py"]

FROM python:3.13-slim-bookworm AS production

# Create non-root user
RUN useradd -m nonroot
WORKDIR /app

# Copy only the app folder and virtual environment from builder
COPY --from=builder --chown=nonroot:nonroot /app/.venv /app/.venv
COPY --from=builder --chown=nonroot:nonroot /app/app /app/app

# Ensure virtualenv binaries are in PATH
ENV PATH="/app/.venv/bin:$PATH"

# Run as non-root user
USER nonroot

# Run FastAPI CLI in production
ENTRYPOINT []
CMD ["/app/.venv/bin/fastapi", "run", "app/main.py", "--port", "80", "--host", "0.0.0.0"]