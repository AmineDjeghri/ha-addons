#!/usr/bin/env bashio
# shellcheck shell=bash
set -e

# Helper: export env var only if config value is non-empty and not null
export_if_set() {
    local env_name=$1
    local config_key=$2
    local value
    value=$(bashio::config "$config_key")
    if [ -n "$value" ] && [ "$value" != "null" ]; then
        export "$env_name=$value"
    fi
}

# ===== HERMES WEBUI SETTINGS =====

# Bind to all interfaces inside the HA container
export HERMES_WEBUI_HOST="0.0.0.0"
export HERMES_WEBUI_PORT="8787"

# HERMES_HOME: use configured path, or auto-discover *_hermes_agent addon, or fall back to isolated
hermes_home=$(bashio::config 'hermes_home')
if [ -z "$hermes_home" ] || [ "$hermes_home" = "null" ]; then
    # Auto-discover: find .hermes inside any *_hermes_agent addon config dir
    hermes_home=$(find /addon_configs -maxdepth 2 -type d -name ".hermes" 2>/dev/null \
        | grep -i "_hermes_agent/" | head -1)
    if [ -n "$hermes_home" ]; then
        bashio::log.info "Auto-discovered Hermes Agent data at: ${hermes_home}"
    fi
fi

if [ -n "$hermes_home" ] && [ "$hermes_home" != "null" ]; then
    export HERMES_HOME="$hermes_home"
    # .hermes is owned by root (0700); the Hermes Agent keeps it that way.
    # Force server to run as root by spoofing whoami (see below).
    export WANTED_UID=0
    export WANTED_GID=0
    # The init script scans hardcoded paths for the agent source to install
    # its Python package into the venv. Symlink our agent into that path.
    mkdir -p /home/hermeswebui/.hermes
    ln -sfn "${hermes_home}/hermes-agent" /home/hermeswebui/.hermes/hermes-agent

    # Workspace: persist in hermes_agent's addon config dir (accessible from both addons,
    # backed up with the agent, survives hermes-webui reinstall)
    HERMES_AGENT_HOME=$(dirname "$hermes_home")

    # Share config and local data from hermes_agent (covers gh auth, npm, pip, and
    # any XDG-compliant tool — no per-tool overrides needed)
    [ -d "$HERMES_AGENT_HOME/.config" ] && ln -sfn "$HERMES_AGENT_HOME/.config" /root/.config
    [ -d "$HERMES_AGENT_HOME/.local" ]  && ln -sfn "$HERMES_AGENT_HOME/.local"  /root/.local
    export XDG_CONFIG_HOME="$HERMES_AGENT_HOME/.config"
    export XDG_DATA_HOME="$HERMES_AGENT_HOME/.local/share"

    # Share git config (includes credential helper set up by `gh auth setup-git`)
    [ -f "$HERMES_AGENT_HOME/.gitconfig" ] && ln -sfn "$HERMES_AGENT_HOME/.gitconfig" /root/.gitconfig

    WORKSPACE_DIR="$HERMES_AGENT_HOME/workspace"
    mkdir -p "$WORKSPACE_DIR"
    chmod 777 "$WORKSPACE_DIR"
    # Only auto-set if the user hasn't configured a custom default_workspace
    export HERMES_WEBUI_DEFAULT_WORKSPACE="$WORKSPACE_DIR"
    bashio::log.info "Workspace: ${WORKSPACE_DIR}"
else
    export HERMES_HOME="/data/hermes"
    mkdir -p /data/hermes
    chmod 777 /data/hermes
    bashio::log.info "No Hermes Agent addon found, using isolated data dir: /data/hermes"
fi

# WebUI state (sessions, settings) always stored in this addon's own data dir
export HERMES_WEBUI_STATE_DIR="/data/hermes-webui"
# Pre-create as root so hermeswebui user can write to it after privilege drop
mkdir -p /data/hermes-webui
chmod 777 /data/hermes-webui

# Optional settings from HA addon configuration
export_if_set HERMES_WEBUI_PASSWORD            password
export_if_set HERMES_WEBUI_AGENT_DIR           agent_dir
export_if_set HERMES_WEBUI_DEFAULT_WORKSPACE   default_workspace
export_if_set HERMES_WEBUI_DEFAULT_MODEL       default_model
export_if_set HERMES_CONFIG_PATH               hermes_config_path
export_if_set HERMES_WEBUI_CSP_CONNECT_EXTRA   csp_connect_extra
export_if_set HERMES_WEBUI_AGENT_CACHE_MAX     agent_cache_max
export_if_set HERMES_WEBUI_SESSIONS_MAX        sessions_max

# The init script's root phase rsyncs /apptoo→/app then drops to hermeswebui
# (UID 1024). In HA, /addon_configs is root-owned (0700) and that user can't
# write to it. To keep the server running as root we:
#   1. Do the rsync ourselves (bypassing the root phase)
#   2. Spoof whoami → "hermeswebui" so the root-phase check is skipped
#   3. WANTED_UID/GID=0 so the hermeswebui-phase UID assertion passes

mkdir -p /app /uv_cache
rsync -a /apptoo/ /app/
mkdir -p /tmp/ha_bin
printf '#!/bin/sh\necho hermeswebui\n' > /tmp/ha_bin/whoami
chmod +x /tmp/ha_bin/whoami
export PATH="/tmp/ha_bin:/root/.local/bin:/home/hermeswebui/.local/bin:${PATH}"

bashio::log.info "Starting Hermes WebUI on port 8787..."
exec /hermeswebui_init.bash
