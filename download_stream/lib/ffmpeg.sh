#!/usr/bin/env bash
OUTPUT_FILE="$1$output_extension"

echo "Downloading 1080 stream..."
ffmpeg \
    -i "$VIDEO_URL" \
    -i "$AUDIO_URL" \
    -c "$codec" \
    -map "$map_video" \
    -map "$map_audio" \
    -f "$format" \
    -y \
    -stats \
    "$OUTPUT_FILE" && \
{
    echo "Success: $OUTPUT_FILE"
    explorer .
} || {
    echo "Download failed!"
    [ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
    exit 1
}
