#!/usr/bin/env bash

# -e, stop on errors
# -u, fail on unset variables
# -o pipefail, catch errors on pipelines
set -euo pipefail

# Log setup
LOG_FILE="batch-compress-$(date +%Y%m%d-%H.%M.%S).log"
exec 3>&1
exec &> >(tee -a "$LOG_FILE")

compress_video() {
    local input="$1"
    local output="${input%.*}-x265.mp4"
    local start_time=$(date +%s)

    # Skip if already compressed
    [ -f "$output" ] && {
        echo "[SKIP] $input (already compressed)"
        return 0
    }

    echo "[START] $input -> $output"

    if ffmpeg -i "$input" \
        -c:v libx265 \
        -crf 28 \
        -preset slower \
        -x265-params "no-sao=1:strong-intra-smoothing=0:limit-tu=4:qg-size=16:rc-lookahead=80" \
        -vf "scale=1920:1080:flags=lanczos" \
        -c:a libopus \
        -b:a 64k \
        -movflags +faststart \
        "$output" 2>&1 | tee -a "$LOG_FILE"; then
        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        echo "[DONE] $output compression time: $elapsed seconds"
        return 0
    else
        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        echo "[FAILED] $output compression time: $elapsed seconds"
        return 1
    fi
}

total_start=$(date +%s)

find . -maxdepth 1 -type f -name "*.mp4" -not -regex ".*x265.*" | while read -r file; do
    compress_video "$file"
done

total_end=$(date +%s)
total_time=$((total_end - total_start))
echo "Total time: $total_time seconds"
