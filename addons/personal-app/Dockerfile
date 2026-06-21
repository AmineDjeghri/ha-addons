# Home Assistant Addon — Personal App
# The Supervisor injects BUILD_FROM from build.json at build time.
ARG BUILD_FROM
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

# Install all workspace packages (uv auto-downloads Python 3.14 if needed).
# --frozen: use exact versions from uv.lock
RUN uv sync --all-packages --frozen

COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
