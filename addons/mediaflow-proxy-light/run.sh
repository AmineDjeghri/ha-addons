#!/usr/bin/env bashio
# shellcheck shell=bash
set -e

# Helper: export env var only if the config value is non-empty
export_if_set() {
    local env_name=$1
    local config_key=$2
    local value
    value=$(bashio::config "$config_key")
    if [ -n "$value" ]; then
        export "$env_name=$value"
    fi
}

# ===== SERVER SETTINGS =====
# Upstream default bind is 127.0.0.1 — must be 0.0.0.0 to be reachable from HA.
export APP__SERVER__HOST=0.0.0.0
export APP__SERVER__PORT=8888

# workers: 0 means let upstream use its CPU-core default (export only when > 0).
workers=$(bashio::config 'workers')
if [ -n "$workers" ] && [ "$workers" -gt 0 ]; then
    export APP__SERVER__WORKERS="$workers"
fi

# ===== AUTH SETTINGS =====
api_password=$(bashio::config 'api_password')
if [ -n "$api_password" ]; then
    export APP__AUTH__API_PASSWORD="$api_password"
else
    bashio::log.warning "api_password is not set — ALL proxy endpoints will return 401 (upstream treats auth as mandatory). Set it in the addon options."
fi

# ===== LOGGING =====
log_level=$(bashio::config 'log_level')
export RUST_LOG="$log_level"
export APP__LOG_LEVEL="$log_level"

# ===== PROXY SETTINGS =====
export_if_set APP__PROXY__CONNECT_TIMEOUT connect_timeout
export_if_set APP__PROXY__FOLLOW_REDIRECTS follow_redirects
export_if_set APP__PROXY__BUFFER_SIZE buffer_size
export_if_set APP__PROXY__PROXY_URL proxy_url
export_if_set APP__PROXY__ALL_PROXY all_proxy

# ===== HLS SETTINGS =====
export_if_set APP__HLS__PREBUFFER_SEGMENTS hls_prebuffer_segments
export_if_set APP__HLS__SEGMENT_CACHE_TTL hls_segment_cache_ttl
export_if_set APP__HLS__INACTIVITY_TIMEOUT hls_inactivity_timeout

# ===== MPD SETTINGS =====
export_if_set APP__MPD__LIVE_PLAYLIST_DEPTH mpd_live_playlist_depth
export_if_set APP__MPD__LIVE_INIT_CACHE_TTL mpd_live_init_cache_ttl
export_if_set APP__MPD__REMUX_TO_TS mpd_remux_to_ts

# ===== DRM / EPG SETTINGS =====
export_if_set APP__DRM__KEY_CACHE_TTL drm_key_cache_ttl
export_if_set APP__EPG__CACHE_TTL epg_cache_ttl

# ===== ACESTREAM SETTINGS =====
export_if_set APP__ACESTREAM__HOST acestream_host
export_if_set APP__ACESTREAM__PORT acestream_port

bashio::log.info "Starting MediaFlow Proxy Light..."
exec /usr/local/bin/mediaflow-proxy-light
