#!/usr/bin/env bashio
# shellcheck shell=bash
set -e

# Read options from Home Assistant and export as environment variables
export Subsonic__Url=$(bashio::config 'subsonic_url')
export Subsonic__MusicService=$(bashio::config 'music_service')
export Subsonic__StorageMode=$(bashio::config 'storage_mode')
export Subsonic__EnableExternalPlaylists=$(bashio::config 'enable_external_playlists')
export Subsonic__ExplicitFilter=$(bashio::config 'explicit_filter')
export Subsonic__DownloadMode=$(bashio::config 'download_mode')
export Subsonic__CacheDurationHours=$(bashio::config 'cache_duration_hours')
export Subsonic__FolderTemplate=$(bashio::config 'folder_template')
export Subsonic__RetryDuration=$(bashio::config 'retry_duration')
export Subsonic__ForceMinimal=$(bashio::config 'force_minimal')
export Library__DownloadPath=$(bashio::config 'library_download_path')

# Optional provider credentials (only set if not empty)
DEEZER_ARL=$(bashio::config 'deezer_arl')
if [ -n "$DEEZER_ARL" ]; then
    export Deezer__Arl="$DEEZER_ARL"
fi

QOBUZ_AUTH=$(bashio::config 'qobuz_auth_token')
if [ -n "$QOBUZ_AUTH" ]; then
    export Qobuz__UserAuthToken="$QOBUZ_AUTH"
fi

QOBUZ_ID=$(bashio::config 'qobuz_user_id')
if [ -n "$QOBUZ_ID" ]; then
    export Qobuz__UserId="$QOBUZ_ID"
fi

YANDEX_TOKEN=$(bashio::config 'yandex_oauth_token')
if [ -n "$YANDEX_TOKEN" ]; then
    export Yandex__OAuthToken="$YANDEX_TOKEN"
fi

# Set ASP.NET defaults
export ASPNETCORE_ENVIRONMENT=Production
export ASPNETCORE_URLS="http://+:8080"

bashio::log.info "Starting Octo-Fiesta..."
exec dotnet /app/octo-fiesta.dll
