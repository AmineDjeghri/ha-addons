#!/usr/bin/env bashio
# shellcheck shell=bash
set -e

# Read HA addon options
export LOGGING_LEVEL="$(bashio::config 'logging_level')"
export BACKEND_HOST="0.0.0.0"
export BACKEND_PORT="8000"
export BACKEND_URL="http://localhost:${BACKEND_PORT}"

# ── Backend ────────────────────────────────────────────────────────────────────
bashio::log.info "Starting Personal App backend on port ${BACKEND_PORT}..."
cd /app && uv run python -m uvicorn \
    personal_app_backend.app:app \
    --host "${BACKEND_HOST}" \
    --port "${BACKEND_PORT}" \
    --no-access-log &
BACKEND_PID=$!

bashio::log.info "Waiting for backend to be ready..."
for i in $(seq 1 30); do
    if curl -sf "http://localhost:${BACKEND_PORT}/" >/dev/null 2>&1; then
        bashio::log.info "Backend is ready."
        break
    fi
    if [ "$i" -eq 30 ]; then
        bashio::log.error "Backend did not start in time — aborting."
        kill "${BACKEND_PID}" 2>/dev/null || true
        exit 1
    fi
    sleep 2
done

# ── Frontend ───────────────────────────────────────────────────────────────────
bashio::log.info "Starting Personal App frontend on port 8080..."
exec uv run python /app/frontend/src/personal_app_frontend/main.py
