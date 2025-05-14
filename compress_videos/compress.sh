#!/usr/bin/env bash
source config/config.sh
source lib/validate.sh "$1"
source lib/utils.sh

compress_gpu() {
    local input="$1"
    local temp_output="${input%.*}-temp-gpu.mp4"
    local final_output="${input%.*}-x265.mp4"  # Consistent naming
    
    log "[GPU] attepmting GPU acceleration.."
    
    if ffmpeg -hwaccel cuda -i "$input" \
        -c:v hevc_nvenc -cq 28 -preset p6 \
        -c:a libopus -b:a 64k \
        -movflags +faststart \
        "$temp_output" 2>&1 | grep -q "not supported"; then

        # Rename to standard format if successful
        mv "$temp_output" "$final_output"
        return 0
    else
        rm -f "$temp_output"
        return 1
    fi
}

compress() {
    local input="$1"
    local output="${input%.*}-x265.mp4"
    local start_time=$(date +%s)

    log "[START] Processing: $input"

    if command -v nvidia-smi &> /dev/null; then
        if compress_gpu "$input"; then
            local elapsed=$(( $(date +%s) - start_time ))
            log "[GPU SUCCESS] $OUTPUT, $((elapsed/3600))h $(( (elapsed%3600)/60 ))m $((elapsed%60))s"
            return 0;
        fi
    fi

    log "[CPU] Starting compression..."
    if ffmpeg -i "$input" \
        "${FFMPEG_PARAMS[@]}" \
        "$output" 2>&1 | tee -a "$LOG_FILE"; then

        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        log "[CPU SUCCESS] $output, $((elapsed/3600))h $(( (elapsed%3600)/60 ))m $((elapsed%60))s"
        return 0
    else
        local end_time=$(date +%s)
        local elapsed=$((end_time - start_time))
        log "[FAILED] $output, $((elapsed/3600))h $(( (elapsed%3600)/60 ))m $((elapsed%60))s"
        [ -f "$output" ] && rm "$output"
        return 1
    fi
}

compress "$1"
