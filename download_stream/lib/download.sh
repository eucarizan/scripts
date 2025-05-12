#!/usr/bin/env bash
OUTPUT_FILE="$1.mp4"

echo "Downloading stream..."
if ffmpeg \
    -i "$(cat "$VIDEO_URL_FILE")" \
    -i "$(cat "$AUDIO_URL_FILE")" \
    -c copy \
    -map 0:v -map 1:a \
    -f mp4 -y -stats "$OUTPUT_FILE"; then
    echo "Success: $OUTPUT_FILE"
    [ "$OPEN_EXPLORER" = true ] && explorer .
else
    echo "Download failed!"
    [ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
    exit 1
fi
