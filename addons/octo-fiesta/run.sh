#!/usr/bin/env bashio
# shellcheck shell=bash
set -e

# Helper: export env var only if config value is non-empty
export_if_set() {
    local env_name=$1
    local config_key=$2
    local value
    value=$(bashio::config "$config_key")
    if [ -n "$value" ]; then
        export "$env_name=$value"
    fi
}

# ===== SUBSONIC SETTINGS =====
export_if_set Subsonic__Url subsonic_url
export_if_set Subsonic__MusicService music_service
export_if_set Subsonic__StorageMode storage_mode
export_if_set Subsonic__CacheDurationHours cache_duration_hours
export_if_set Subsonic__EnableExternalPlaylists enable_external_playlists
export_if_set Subsonic__PlaylistsDirectory playlists_directory
export_if_set Subsonic__ExplicitFilter explicit_filter
export_if_set Subsonic__DownloadMode download_mode
export_if_set Subsonic__AutoUpgradeQuality auto_upgrade_quality
export_if_set Subsonic__DisableLibraryScan disable_library_scan
export_if_set Subsonic__FolderTemplate folder_template
export_if_set Subsonic__AdminUsername admin_username
export_if_set Subsonic__AdminPassword admin_password

# ===== LIBRARY SETTINGS =====
export_if_set Library__DownloadPath library_download_path

# ===== LYRICS SETTINGS =====
export_if_set Lyrics__Enabled lyrics_enabled
export_if_set Lyrics__LrclibBaseUrl lyrics_lrclib_base_url
export_if_set Lyrics__WriteLrcFile lyrics_write_lrc_file
export_if_set Lyrics__AllowPlainFallback lyrics_allow_plain_fallback
export_if_set Lyrics__TimeoutSeconds lyrics_timeout_seconds

# ===== DEEZER SETTINGS =====
export_if_set Deezer__Arl deezer_arl
export_if_set Deezer__ArlFallback deezer_arl_fallback
export_if_set Deezer__Quality deezer_quality

# ===== QOBUZ SETTINGS =====
export_if_set Qobuz__UserAuthToken qobuz_auth_token
export_if_set Qobuz__UserId qobuz_user_id
export_if_set Qobuz__Quality qobuz_quality

# ===== SQUIDWTF SETTINGS =====
export_if_set SquidWTF__Source squidwtf_source
export_if_set SquidWTF__Quality squidwtf_quality
export_if_set SquidWTF__Country squidwtf_country
export_if_set SquidWTF__InstanceTimeoutSeconds squidwtf_instance_timeout
export_if_set SquidWTF__Instances__0 squidwtf_instance
export_if_set SquidWTF__InstancesUrl squidwtf_instances_url

# ===== YANDEX MUSIC SETTINGS =====
export_if_set Yandex__Language yandex_language
export_if_set Yandex__IncludeUnavailable yandex_include_unavailable
export_if_set Yandex__OAuthToken yandex_oauth_token
export_if_set Yandex__Quality yandex_quality

# ===== ASP.NET CORE =====
export ASPNETCORE_ENVIRONMENT=Production
export ASPNETCORE_URLS="http://+:8080"

bashio::log.info "Starting Octo-Fiesta..."
exec dotnet /app/octo-fiesta.dll
