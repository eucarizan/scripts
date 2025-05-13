#!/usr/bin/env bash

# -e, stop on errors
# -u, fail on unset variables
# -o pipefail, catch errors on pipelines
set -euo pipefail

# Log setup
LOG_FILE="batch-compress-$(date +%Y%m%d-%H.%M.%S).log"

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$message"
    [[ -n "${LOG_FILE:-}" ]] && echo "$message" >> "$LOG_FILE"
}

compress_video() {
    local input="$1"
    local output="${input%.*}-x265.mp4"

    # Skip if already compressed
    if [ -f "$output" ]; then
        log "[SKIP] $input (already compressed)"
        return
    fi

    log "[START] $input -> $output"
    local start_time end_time elapsed

    start_time=$(date +%s)

    if ffmpeg -i "$input" \
        -c:v libx265 \
        -crf 28 \
        -preset slower \
        -x265-params \
          "no-sao=1:strong-intra-smoothing=0:limit-tu=4:qg-size=16:rc-lookahead=80" \
        -vf "scale=1920:1080:flags=lanczos" \
        -c:a libopus \
        -b:a 64k \
        -movflags +faststart \
        "$output" 2>&1 | tee -a "$LOG_FILE"; then
        end_time=$(date +%s)
        elapsed=$((end_time - start_time))
        log "[DONE] $output compression time: $elapsed seconds"
    else
        end_time=$(date +%s)
        elapsed=$((end_time - start_time))
        log "[FAILED] $output compression time: $elapsed seconds"
        [[ -f "$output" ]] && "$output"
        return 1
    fi
}

total_start=$(date +%s)

find . -maxdepth 1 -type f -name "*.mp4" -not -regex ".*x265.mp4" | cut -d'/' -f2 | while read -r file; do
    compress_video "$file"
done

total_end=$(date +%s)
total_time=$((total_end - total_start))
log "Total time: $total_time seconds"
