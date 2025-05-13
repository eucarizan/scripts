#!/usr/bin/env bash

# Set up logging
LOG_FILE="${1%.*}-compression.log"
exec 3>&1 # Save stdout descriptor
exec > >(tee -a "$LOG_FILE") 2>&1

# log function with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee /dev/fd/3
}

if [ -z "$1" ]; then
    log "Error: Please provide input file as an argument."
    log "Usage: $0 input.mp4"
    exit 1
fi

if [ ! -f "$1" ]; then
    log "Error: File '$1' not found"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    log "Error: FFmpeg is not installed"
    exit 1
fi

OUTPUT="${1%.*}-x265.mp4"

start_time=$(date +%s)
log "Starting compression: $1 -> $OUTPUT"
log "FFmpeg settings:"
log "  Codec: H.265/HEVC (libx265)"
log "  CRF: 28 | Preset: slower"
log "  Audio: Opus @ 65kbit/s"
log "  Resolution: 1920x1080 (lanczos)"

if ffmpeg -i "$1" \
    -c:v libx265 \
    -crf 28 -preset slower \
    -x265-params \
      "no-sao=1:strong-intra-smoothing=0:limit-tu=4:qg-size=16:rc-lookahead=80" \
    -vf "scale=1920:1080:flags=lanczos" \
    -c:a libopus -b:a 64k \
    -movflags +faststart \
    "$OUTPUT" 2>&1 | tee -a "$LOG_FILE"
then
    log "Compression successful"
    log "Output file size: $(du -h "$OUTPUT" | cut -f1)"
else
    log "Compression failed with exit code $?"
    [ -f "$OUTPUT" ] && rm "$OUTPUT"
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    log "Total time before failur: ${elapsed} seconds"
    exit 1
fi

end_time=$(date +%s)
elapsed=$((end_time - start_time))
log "Total time: ${elapsed} seconds"
log "Process completed. Full log saved to: $LOG_FILE"
