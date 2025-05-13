#!/usr/bin/env bash

AUDIO_GROUP=$(grep -E 'EXT-X-STREAM-INF.*RESOLUTION=1920x1080' "$input_file" |
    grep -o 'AUDIO="[^"]*' |
    cut -d'"' -f2)

# Extract 1080p stream URL
export VIDEO_URL=$(grep -A1 "EXT-X-STREAM-INF.*RESOLUTION=1920x1080" "$input_file" |
    grep -v "RESOLUTION" |
    grep -v "^--%" |
    head -1)

# Extract corresponding audio URL
export AUDIO_URL=$(grep -E "#EXT-X-MEDIA.*$AUDIO_GROUP" "$input_file" |
    grep -o 'URI="[^"]* |
    cut -d'"' -f2)

[ -z "$VIDEO_URL" ] || [ -z "$AUDIO_URL ] && {
    echo "Error: Failed to extract video/audio URLs"
    exit 1
}
