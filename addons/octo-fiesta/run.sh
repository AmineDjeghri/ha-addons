#!/usr/bin/env bashio
# shellcheck shell=bash
set -e

# ===== SUBSONIC SETTINGS =====
export Subsonic__Url=$(bashio::config 'subsonic_url')
export Subsonic__MusicService=$(bashio::config 'music_service')
export Subsonic__StorageMode=$(bashio::config 'storage_mode')
export Subsonic__CacheDurationHours=$(bashio::config 'cache_duration_hours')
export Subsonic__EnableExternalPlaylists=$(bashio::config 'enable_external_playlists')
export Subsonic__PlaylistsDirectory=$(bashio::config 'playlists_directory')
export Subsonic__ExplicitFilter=$(bashio::config 'explicit_filter')
export Subsonic__DownloadMode=$(bashio::config 'download_mode')
export Subsonic__AutoUpgradeQuality=$(bashio::config 'auto_upgrade_quality')
export Subsonic__FolderTemplate=$(bashio::config 'folder_template')
export Subsonic__RetryDuration=$(bashio::config 'retry_duration')
export Subsonic__ForceMinimal=$(bashio::config 'force_minimal')

if bashio::config.has_value 'admin_username'; then
    export Subsonic__AdminUsername=$(bashio::config 'admin_username')
fi

if bashio::config.has_value 'admin_password'; then
    export Subsonic__AdminPassword=$(bashio::config 'admin_password')
fi

# ===== LIBRARY SETTINGS =====
export Library__DownloadPath=$(bashio::config 'library_download_path')

# ===== DEEZER SETTINGS =====
if bashio::config.has_value 'deezer_arl'; then
    export Deezer__Arl=$(bashio::config 'deezer_arl')
fi
if bashio::config.has_value 'deezer_arl_fallback'; then
    export Deezer__ArlFallback=$(bashio::config 'deezer_arl_fallback')
fi
if bashio::config.has_value 'deezer_quality'; then
    export Deezer__Quality=$(bashio::config 'deezer_quality')
fi

# ===== QOBUZ SETTINGS =====
if bashio::config.has_value 'qobuz_auth_token'; then
    export Qobuz__UserAuthToken=$(bashio::config 'qobuz_auth_token')
fi
if bashio::config.has_value 'qobuz_user_id'; then
    export Qobuz__UserId=$(bashio::config 'qobuz_user_id')
fi
if bashio::config.has_value 'qobuz_quality'; then
    export Qobuz__Quality=$(bashio::config 'qobuz_quality')
fi

# ===== SQUIDWTF SETTINGS =====
export SquidWTF__Source=$(bashio::config 'squidwtf_source')
export SquidWTF__InstanceTimeoutSeconds=$(bashio::config 'squidwtf_instance_timeout')
if bashio::config.has_value 'squidwtf_quality'; then
    export SquidWTF__Quality=$(bashio::config 'squidwtf_quality')
fi
if bashio::config.has_value 'squidwtf_instance'; then
    export SquidWTF__Instances__0=$(bashio::config 'squidwtf_instance')
fi
if bashio::config.has_value 'squidwtf_instances_url'; then
    export SquidWTF__InstancesUrl=$(bashio::config 'squidwtf_instances_url')
fi

# ===== YANDEX MUSIC SETTINGS =====
export Yandex__Language=$(bashio::config 'yandex_language')
export Yandex__IncludeUnavailable=$(bashio::config 'yandex_include_unavailable')
if bashio::config.has_value 'yandex_oauth_token'; then
    export Yandex__OAuthToken=$(bashio::config 'yandex_oauth_token')
fi
if bashio::config.has_value 'yandex_quality'; then
    export Yandex__Quality=$(bashio::config 'yandex_quality')
fi

# ===== ASP.NET CORE =====
export ASPNETCORE_ENVIRONMENT=Production
export ASPNETCORE_URLS="http://+:8080"

bashio::log.info "Starting Octo-Fiesta..."
exec dotnet /app/octo-fiesta.dll
