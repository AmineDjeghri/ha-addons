#!/usr/bin/env bashio
# shellcheck shell=bash
# =============================================================================
# Beets addon — watches the music library, auto-tags new files, cleans
# duplicates, and optionally pokes Navidrome to rescan after imports.
# =============================================================================

set -e

# ---- Paths ---------------------------------------------------------------
DATA_DIR="/data/beets"
CONFIG_FILE="${DATA_DIR}/config.yaml"
LOG_FILE="${DATA_DIR}/import.log"
LOCK_FILE="${DATA_DIR}/import.lock"

# ---- Options -------------------------------------------------------------
LIBRARY_PATH=$(bashio::config 'library_path')
WATCH_ENABLED=$(bashio::config 'watch_enabled')
WATCH_DEBOUNCE=$(bashio::config 'watch_debounce_seconds')
DAILY_INCREMENTAL=$(bashio::config 'daily_incremental')
DAILY_TIME=$(bashio::config 'daily_incremental_time')
AUTOTAG=$(bashio::config 'autotag')
WRITE=$(bashio::config 'write')
QUIET=$(bashio::config 'quiet')
QUIET_FALLBACK=$(bashio::config 'quiet_fallback')
TIMID=$(bashio::config 'timid')
INCREMENTAL=$(bashio::config 'incremental')
DUPLICATE_ACTION=$(bashio::config 'duplicate_action')
DUPLICATES_ENABLED=$(bashio::config 'duplicates_enabled')
DUPLICATES_INTERVAL=$(bashio::config 'duplicates_interval_hours')
NAVIDROME_URL=$(bashio::config 'navidrome_url')
NAVIDROME_USER=$(bashio::config 'navidrome_user')
NAVIDROME_PASSWORD=$(bashio::config 'navidrome_password')
ACOUSTID_APIKEY=$(bashio::config 'acoustid_apikey')

mkdir -p "${DATA_DIR}"

# ---- Helpers -------------------------------------------------------------
log() {
    bashio::log.info "${1}"
    echo "[$(date -Is)] ${1}" >> "${LOG_FILE}"
}

# Render the Beets config from addon options.
write_beets_config() {
    cat > "${CONFIG_FILE}" <<EOF
directory: ${LIBRARY_PATH}
library: ${DATA_DIR}/library.db
import:
  write: ${WRITE}
  copy: no
  move: no
  autotag: ${AUTOTAG}
  quiet: ${QUIET}
  quiet_fallback: ${QUIET_FALLBACK}
  timid: ${TIMID}
  incremental: ${INCREMENTAL}
  duplicate_action: ${DUPLICATE_ACTION}
  resume: skip
plugins: fetchart lastgenre embedart titlecase chroma
fetchart:
  fetch_for_asis: yes
EOF
    if [ -n "${ACOUSTID_APIKEY}" ]; then
        printf 'acoustid:\n  apikey: %s\n' "${ACOUSTID_APIKEY}" >> "${CONFIG_FILE}"
    fi
}

# Trigger a Navidrome rescan via the Subsonic API (token auth).
navidrome_scan() {
    [ -n "${NAVIDROME_URL}" ] || return 0
    [ -n "${NAVIDROME_USER}" ] || return 0
    [ -n "${NAVIDROME_PASSWORD}" ] || return 0

    local salt token base
    salt=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')
    token=$(printf '%s' "${NAVIDROME_PASSWORD}${salt}" | md5sum | awk '{print $1}')
    base="${NAVIDROME_URL}"
    [[ "${base}" != http* ]] && base="http://${base}"

    if curl -sf --max-time 15 \
        "${base}/rest/startScan?u=${NAVIDROME_USER}&t=${token}&s=${salt}&v=1.16.1&c=beets-addon&f=json" \
        >/dev/null 2>&1; then
        log "Navidrome rescan triggered"
    else
        log "WARN: Navidrome rescan failed (${NAVIDROME_URL})"
    fi
}

# Run one beets import under flock. No args = full incremental sweep.
run_import() {
    local -a args=()
    if [ "$#" -eq 0 ]; then
        args=("${LIBRARY_PATH}")
        [ "${INCREMENTAL}" = "true" ] && args+=("--incremental")
    else
        args=("$@")
    fi
    (
        flock -n 9 || { log "Import skipped: another import is running"; exit 0; }
        log "Importing: ${args[*]}"
        if /usr/local/bin/beet -c "${CONFIG_FILE}" -vv import "${args[@]}" >> "${LOG_FILE}" 2>&1; then
            log "Import finished OK"
            navidrome_scan
        else
            log "ERROR: import failed — see ${LOG_FILE}"
        fi
    ) 9>"${LOCK_FILE}"
}

# Run the duplicates cleanup under flock.
run_duplicates() {
    (
        flock -n 9 || { log "Duplicates check skipped: import in progress"; exit 0; }
        log "Running duplicates check (report only, nothing deleted)"
        if /usr/local/bin/beet -c "${CONFIG_FILE}" duplicates -k title -k albumartist >> "${LOG_FILE}" 2>&1; then
            log "Duplicates check finished OK"
        else
            log "ERROR: duplicates check failed — see ${LOG_FILE}"
        fi
    ) 9>"${LOCK_FILE}"
}

# ---- Startup -------------------------------------------------------------
write_beets_config
BEETS_VERSION=$(/usr/local/bin/beet -c "${CONFIG_FILE}" version | head -1)
log "Beets addon started — ${BEETS_VERSION}, library: ${LIBRARY_PATH}"
if [ ! -d "${LIBRARY_PATH}" ]; then
    log "WARN: library path ${LIBRARY_PATH} does not exist yet (media mount not ready?)"
fi
# Catch anything that arrived while the addon was stopped.
run_import

LAST_DUPLICATES_RUN=$(date +%s)

# ---- Main loop -----------------------------------------------------------
while true; do
    NOW=$(date +%s)

    # Daily full incremental sweep — catches anything the watch missed.
    if [ "${DAILY_INCREMENTAL}" = "true" ] && [ "$(date +%H:%M)" = "${DAILY_TIME}" ]; then
        run_import
        sleep 61
    fi

    # Duplicates cleanup on interval.
    if [ "${DUPLICATES_ENABLED}" = "true" ] \
        && [ $((NOW - LAST_DUPLICATES_RUN)) -ge $((DUPLICATES_INTERVAL * 3600)) ]; then
        run_duplicates
        LAST_DUPLICATES_RUN=$(date +%s)
    fi

    # Watch mode: collect filesystem events for the debounce window, then
    # import whatever new audio appeared.
    if [ "${WATCH_ENABLED}" = "true" ]; then
        if [ -d "${LIBRARY_PATH}" ]; then
            EVENTS=$(inotifywait -q -r -e close_write -e moved_to \
                --format '%w%f' -t "${WATCH_DEBOUNCE}" "${LIBRARY_PATH}" 2>/dev/null || true)
            if [ -n "${EVENTS}" ]; then
                # Keep only audio files, import their parent directories.
                AUDIO_EVENTS=$(printf '%s\n' "${EVENTS}" \
                    | grep -iE '\.(flac|mp3|m4a|aac|ogg|opus|wav|wma|alac|ape|wv|aiff)$' || true)
                if [ -n "${AUDIO_EVENTS}" ]; then
                    DIR_LIST=()
                    while IFS= read -r ev; do
                        [ -n "${ev}" ] && DIR_LIST+=("$(dirname "${ev}")")
                    done <<< "${AUDIO_EVENTS}"
                    UNIQUE=()
                    while IFS= read -r d; do
                        [ -n "${d}" ] && UNIQUE+=("${d}")
                    done < <(printf '%s\n' "${DIR_LIST[@]}" | sort -u | head -20)
                    if [ ${#UNIQUE[@]} -gt 0 ]; then
                        log "New audio detected — importing ${#UNIQUE[@]} directorie(s)"
                        run_import "${UNIQUE[@]}"
                    fi
                fi
            fi
        else
            sleep 60
        fi
    else
        sleep 60
    fi
done
