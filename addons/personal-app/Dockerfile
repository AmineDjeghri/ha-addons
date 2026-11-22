# Home Assistant Addon — Personal App
# BUILD_FROM comes from build.json when the Supervisor passes it; since Supervisor 2026.04 it is no
# longer passed by default, so the argument carries a default (a multi-arch equivalent of the build.json images).
ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install curl (needed to install uv) then clean up
RUN apk add --no-cache curl \
    && curl -LsSf https://astral.sh/uv/install.sh \
       | env UV_INSTALL_DIR="/usr/local/bin" sh \
    && rm -rf /tmp/*

WORKDIR /app

# Copy workspace definition files first — this layer is only rebuilt when
# dependencies change, not when source code changes.
COPY pyproject.toml uv.lock ./
COPY backend/pyproject.toml ./backend/
COPY frontend/pyproject.toml ./frontend/

# Copy source code
COPY backend/src ./backend/src
COPY frontend/src ./frontend/src

# Install production packages only (uv auto-downloads Python 3.14 if needed).
# --frozen: use exact versions from uv.lock
RUN uv sync --all-packages --frozen

COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
