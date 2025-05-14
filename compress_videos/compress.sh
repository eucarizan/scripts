#!/usr/bin/env bash
source config/config.sh
source lib/validate.sh "$1"
source lib/utils.sh

init_logging

compress_gpu() {
    local input="$1"
    local output="${input%.*}-hybrid.mp4"
    local start_time=$(date +%s)
    log "[GPU] attepmting compression.."
    
    if ffmpeg -hwaccel cuda -i "$input" \
        -c:v hevc_nvenc -cq 28 -preset p6 \
        -c:a libopus -b:a 64k \
        -movflags +faststart \
        "$output" 2>&1 | grep -q "not supported"; then

        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        log "[GPU SUCCESS] $OUTPUT, $((elapsed/3600))h $(( (elapsed%3600)/60 ))m $((elapsed%60))s"
        return 0
    else
        log "[GPU FAIL] Falling back to CPU"
        rm -f "$output"
        return 1
    fi
}

compress() {
    local input="$1"
    local output="${1%.*}-x265.mp4"
    local start_time=$(date +%s)
    log "[START] Processing: $input"

    if compress_gpu "$input"; then
        return 0;
    fi

    log "[CPU] Starting compression..."
    if ffmpeg -i "$1" \
        "${FFMPEG_PARAMS[@]}" \
        "$OUTPUT" 2>&1 | tee -a "$LOG_FILE"; then

        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        log "[CPU SUCCESS] $OUTPUT, $((elapsed/3600))h $(( (elapsed%3600)/60 ))m $((elapsed%60))s"
        return 0
    else
        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        log "[FAIL] $output, $((elapsed/3600))h $(( (elapsed%3600)/60 ))m $((elapsed%60))s"
        [ -f "$OUTPUT" ] && rm "$OUTPUT"
        return 1
    fi
}

compress "$1"
