#!/usr/bin/env bash
M3U8_URL=$(cat "$M3U8_SOURCE")
curl -s "$M3U8_URL" > "$TEMP_INPUT"

# Extract 1080p stream URL
grep -A1 "EXT-X-STREAM-INF.*RESOLUTION=1920x1080" "$TEMP_INPUT" |
    grep -v "RESOLUTION" |
    grep -v "^--%" > "$VIDEO_URL_FILE"

# Extract corresponding audio URL
AUDIO_GROUP=$(grep -E 'EXT-X-STREAM-INF.*RESOLUTION=1920x1080' "$TEMP_INPUT" |
    grep -o 'AUDIO="[^"]*' |
    cut -d'"' -f2)

grep -E "#EXT-X-MEDIA.*$AUDIO_GROUP" "$TEMP_INPUT" |
    grep -o 'URI="[^"]* |
    cut -d'"' -f2 > "$AUDIO_URL_FILE"
