#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCANS_DIR="$SCRIPT_DIR/scans"
LOGS_DIR="$SCRIPT_DIR/logs"
CONFIG_FILE="$SCRIPT_DIR/config.env"
LOG_FILE="$LOGS_DIR/sync.log"

IMAGE_EXTENSIONS="tif tiff png jpeg jpg"

# --- Setup ---

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: config.env not found. Copy config.env.example to config.env and fill in your values." >&2
    exit 1
fi

source "$CONFIG_FILE"

for var in RSYNC_USER RSYNC_HOST RSYNC_PATH; do
    if [ -z "${!var:-}" ]; then
        echo "ERROR: $var is not set in config.env" >&2
        exit 1
    fi
done

mkdir -p "$SCANS_DIR" "$LOGS_DIR"

RSYNC_DEST="${RSYNC_USER}@${RSYNC_HOST}:${RSYNC_PATH}/"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# --- Build include/exclude list ---

INCLUDE_ARGS=()
for ext in $IMAGE_EXTENSIONS; do
    INCLUDE_ARGS+=(--include="*.${ext}")
    INCLUDE_ARGS+=(--include="*.$(echo "$ext" | tr '[:lower:]' '[:upper:]')")
done

# --- Log skipped files ---

log "--- Sync started ---"

synced=0
skipped_files=()

for file in "$SCANS_DIR"/*; do
    [ -f "$file" ] || continue
    filename="$(basename "$file")"
    ext="${filename##*.}"
    ext_lower="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"

    matched=false
    for img_ext in $IMAGE_EXTENSIONS; do
        if [ "$ext_lower" = "$img_ext" ]; then
            matched=true
            break
        fi
    done

    if [ "$matched" = false ]; then
        skipped_files+=("$filename")
    fi
done

# --- Rsync (additive only) ---

rsync_output=$(rsync -avz \
    --itemize-changes \
    --ignore-existing \
    "${INCLUDE_ARGS[@]}" \
    --exclude="*" \
    "$SCANS_DIR/" \
    "$RSYNC_DEST" 2>&1) || {
    log "ERROR: rsync failed: $rsync_output"
    exit 1
}

# Count transferred files: --itemize-changes lines starting with >f mean a file was sent
synced=$(echo "$rsync_output" | grep -c '^<f' || true)

if [ ${#skipped_files[@]} -gt 0 ]; then
    log "Synced $synced file(s), skipped ${#skipped_files[@]} non-image file(s)"
    for skipped in "${skipped_files[@]}"; do
        log "  SKIPPED: $skipped"
    done
else
    log "Synced $synced file(s), no skipped files"
fi
log "--- Sync complete ---"
