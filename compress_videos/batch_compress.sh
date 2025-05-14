#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="batch-compress-$(date +%Y%m%d_%H-%M-%S).log"
exec 3>&1

update_progress() {
    local line="$1"
    if [[ -f "$LOG_FILE" ]] && tail -n 1 "$LOG_FILE" | grep -q 'frame='; then
        sed -i '$d' "$LOG_FILE"
    fi
    echo "$line" >> "$LOG_FILE"
    printf "r%s" "$line" >&3
}

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    if [[ -t 1 ]]; then
        echo "$message" | tee -a "$LOG_FILE"
    else
        echo "$message" >> "$LOG_FILE"
    fi
}

compress_video() {
    local input="$1"
    local output="${input%.*}-x265.mp4"
    local start_time=$(date +%s)

    # Skip if already compressed
    if [ -f "$output" ]; then
        log "[SKIP] $input (already compressed)"
        return 0
    fi

    log "[START] Proccessing $input"

    {
        ffmpeg -i "$input" \
            -c:v libx265 \
            -crf 28 \
            -preset slower \
            -x265-params \
              "no-sao=1:strong-intra-smoothing=0:limit-tu=4:qg-size=16:rc-lookahead=80" \
            -vf "scale=1920:1080:flags=lanczos" \
            -c:a libopus \
            -b:a 64k \
            -movflags +faststart \
            "$output" 2>&1 | while IFS= read -r line; do
                if [[ "$line" =~ frame=[[:space:]]*[0-9]+ ]]; then
                    update_progress "$line"
                else
                    echo "$line" >> "$LOG_FILE"
                fi
            done
    } || {
        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        log "[FAILED] $output, compression time: $elapsed seconds"
        [[ -f "$output" ]] && rm "$output"
        return 1
    }

    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    log "[DONE] $output compression time: $elapsed seconds"
    return 0
}

total_start=$(date +%s)

find . -maxdepth 1 -type f -name "*.mp4" -not -regex ".*x265.mp4" | cut -d'/' -f2 | while read -r file; do
    compress_video "$file"
done

total_end=$(date +%s)
total_time=$((total_end - total_start))
log "Total time: $((total_time/3600))h $(((total_time%3600)/60))m $((total_time%60))s"
