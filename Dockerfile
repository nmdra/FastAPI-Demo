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

RUN useradd -m nonroot
WORKDIR /app

COPY --from=builder --chown=nonroot:nonroot /app/.venv /app/.venv
COPY --from=builder --chown=nonroot:nonroot /app/app /app/app

ENV PATH="/app/.venv/bin:$PATH"

USER nonroot

ENTRYPOINT []
# CMD ["/app/.venv/bin/fastapi", "run", "app/main.py", "--port", "80", "--host", "0.0.0.0"]

CMD ["/app/.venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]