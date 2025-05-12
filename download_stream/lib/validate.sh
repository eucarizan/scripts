#!/usr/bin/env bash
# Validate files
for file in "$AUDIO_URL_FILE" "$VIDEO_URL_FILE"; do
    if [ ! -f "$file" ]; then
        echo "Error: missing $file"
        exit 1
    done
done

# Validate tools
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: Ffmpeg required"
    exit 1
fi
