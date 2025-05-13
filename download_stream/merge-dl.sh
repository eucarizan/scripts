#!/usr/bin/env bash
# Check if filename is provided
if [ -z "$1" ]; then
    echo "Error: Please provide the output filename (without extension) as an argument."
    echo "Usage: $0 <file_name>"
    exit 1
fi

INPUT="textmaster.txt"
[ -f "$INPUT" ] && rm "$INPUT"

M3U8_URL=$(cat m3u8.txt)
curl -s "$M3U8_URL" > "$INPUT"

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: FFmpeg is not installed. Please install it first."
    exit 1
fi

AUDIO_GROUP=$(grep -E 'EXT-X-STREAM-INF.*RESOLUTION=1920x1080' "$INPUT" | grep -o 'AUDIO="[^"]*' | cut -d'"' -f2)
VIDEO_URL=$(grep -A1 "EXT-X-STREAM-INF.*RESOLUTION=1920x1080" "$INPUT" | grep -v "RESOLUTION" | grep -v "^--%" | head -1)
AUDIO_URL=$(grep -E "#EXT-X-MEDIA.*$AUDIO_GROUP" "$INPUT" | grep -o 'URI=".*[^"]' | cut -d '"' -f2)

if [ -z "$VIDEO_URL" ] || [ -z "$AUDIO_URL" ]; then
    echo "Error: Failed to extract video/audio URLs"
    exit 1
fi

OUTPUT_FILE="$1.mp4"

echo "Downloading stream to $OUTPUT_FILE..."
ffmpeg \
    -i "$VIDEO_URL" \
    -i "$AUDIO_URL" \
    -c copy \
    -map 0:v \
    -map 1:a \
    -f mp4 -y -stats "$OUTPUT_FILE" && \
{
    echo "Successfully downloaded: $OUTPUT_FILE"
    explorer .
} || {
    echo "Download failed!"
    # Clean up partial file if download failed
    [ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
    exit 1
}
