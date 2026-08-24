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
GENRE_SOURCE=$(bashio::config 'genre_source')
GENRE_MODE=$(bashio::config 'genre_mode')
GENRE_WHITELIST=$(bashio::config 'genre_whitelist')
GENRE_COUNT=$(bashio::config 'genre_count')
GENRE_WHITELIST_EXTRA=$(bashio::config 'genre_whitelist_extra')
# keep = preserve existing (Tidal) genres; overwrite = replace with Last.fm;
# combine = merge existing + Last.fm (force + keep_existing).
case "${GENRE_MODE}" in
    overwrite) LASTGENRE_FORCE=yes; LASTGENRE_KEEP=no ;;
    combine)   LASTGENRE_FORCE=yes; LASTGENRE_KEEP=yes ;;
    *)         LASTGENRE_FORCE=no;  LASTGENRE_KEEP=no ;;
esac
# When the whitelist is enabled, build a merged whitelist file: beets' bundled
# genres.txt + the bundled supplement (/genres-extra.txt — Spotify/EveryNoise
# catalog + regional descriptors) + user extras (case-insensitive).
# When disabled, no filtering happens (every tag is kept).
if [ "${GENRE_WHITELIST}" = "true" ]; then
    WL_SRC="$(find /root/.local -type f -path '*/beetsplug/lastgenre/genres.txt' 2>/dev/null | head -1)"
    if [ -n "${WL_SRC}" ]; then
        cp "${WL_SRC}" /data/beets/genres-extra.txt
        cat /genres-extra.txt >> /data/beets/genres-extra.txt
        for extra in ${GENRE_WHITELIST_EXTRA}; do
            echo "${extra}" | tr '[:upper:]' '[:lower:]' >> /data/beets/genres-extra.txt
        done
        sort -u -o /data/beets/genres-extra.txt /data/beets/genres-extra.txt
        GENRE_WHITELIST=/data/beets/genres-extra.txt
    fi
fi
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
artist_credit: yes
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
match:
  strong_rec_thresh: 0.05
  medium_rec_thresh: 0.3
  distance_weights:
    data_source: 0.0
    missing_tracks: 0.0
    explicit: 0.0
    country: 0.0
    media: 0.0
    tracks: 2.5
    track_title: 4.0
    track_index: 4.0
    track_length: 2.0
    track_artist: 5.0
    unmatched_tracks: 0.0
  preferred:
    countries: [XW, US, GB|UK, FR]
    media: [CD, Digital Media|File]
  ignored: track_length
plugins: fetchart lastgenre embedart titlecase chroma duplicates ftintitle musicbrainz
fetchart:
  minwidth: 500
  enforce_ratio: yes
  sources:
    - coverart
    - itunes
    - filesystem=*
  fetch_for_asis: yes
embedart:
  auto: yes
  ifempty: yes
titlecase:
  auto: yes
  all_caps: yes
  fields:
    - title
    - album
  preserve:
    - "A"
    - "An"
    - "The"
    - "And"
    - "But"
    - "Or"
    - "Nor"
    - "For"
    - "So"
    - "Yet"
    - "At"
    - "By"
    - "In"
    - "Of"
    - "On"
    - "To"
    - "Up"
    - "As"
    - "Per"
    - "Via"
    - "With"
    - "From"
    - "Into"
    - "Over"
    - "Upon"
    - "Off"
    - "Out"
    - "Around"
    - "About"
    - "Before"
    - "After"
    - "Under"
    - "Between"
    - "Without"
    - "Le"
    - "La"
    - "Les"
lastgenre:
  source: ${GENRE_SOURCE}
  count: ${GENRE_COUNT}
  prefer_specific: no
  separator: "; "
  force: ${LASTGENRE_FORCE}
  keep_existing: ${LASTGENRE_KEEP}
  whitelist: ${GENRE_WHITELIST}
ftintitle:
  auto: yes
  drop: yes
  keep_in_artist: yes
musicbrainz:
  extra_tags: [alias, year]
  search_limit: 7
duplicates:
  keys: [title, albumartist]
  tiebreak:
    items: [bitrate, added]
  delete: no
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
        # -vv + filter: full progress including genre resolutions
        # ("Resolved (…): [genres]") without the noise — event traces,
        # chroma fingerprint UUID dumps, ftintitle no-ops, MusicBrainz
        # request UUIDs. awk (not grep -v) keeps pipefail safe on empty
        # output.
        set -o pipefail
        if /usr/local/bin/beet -c "${CONFIG_FILE}" -vv import "${args[@]}" 2>&1 \
            | awk '!/^Sending event:/ && !/^ftintitle: .*Not changing/ && !/^ftintitle: \// && !/^titlecase: .*does not exist/ && !/^chroma: .*matched recordings/ && !/^chroma: chroma: fingerprinted/ && !/^musicbrainz: Requesting MusicBrainz release/ && !/^musicbrainz: Searching for/ && !/^musicbrainz: Found /' \
            | tee -a "${LOG_FILE}"; then
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
# Rotate the import log at startup so /data (and HA backups) stay bounded.
if [ -f "${LOG_FILE}" ] && [ "$(stat -c %s "${LOG_FILE}" 2>/dev/null)" -gt 10485760 ]; then
    mv -f "${LOG_FILE}" "${LOG_FILE}.1"
fi
write_beets_config
BEETS_VERSION=$(/usr/local/bin/beet -c "${CONFIG_FILE}" version | grep '^beets ' | head -1)
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
