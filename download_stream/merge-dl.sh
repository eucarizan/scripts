#!/usr/bin/env bash
# Check if filename is provided
if [ -z "$1" ]; then
    echo "Error: Please provide the output filename (without extension) as an argument."
    echo "Usage: $0 <file_name>"
    exit 1
fi

INPUT="textmaster.txt"
OUT_VID="video.txt"
OUT_AUD="audio.txt"

[ -f "$OUT_VID" ] && rm video.txt
[ -f "$OUT_AUD" ] && rm audio.txt
[ -f "$INPUT" ] && rm textmaster.txt

M3U8_URL=$(cat m3u8.txt)
curl -s "$M3U8_URL" > "$INPUT"

AUDIO_GROUP=$(grep -E 'EXT-X-STREAM-INF.*RESOLUTION=1920x1080' "$INPUT" | grep -o 'AUDIO="[^"]*' | cut -d'"' -f2)

grep -A1 "EXT-X-STREAM-INF.*RESOLUTION=1920x1080" "$INPUT" | grep -v "RESOLUTION" | grep -v "^--%" > "$OUT_VID"

grep -E "#EXT-X-MEDIA.*$AUDIO_GROUP" "$INPUT" | grep -o 'URI=".*[^"]' | cut -d '"' -f2 > "$OUT_AUD"

# Check if audio.txt exists
if [ ! -f "audio.txt" ]; then
    echo "Error: audio.txt not found in current directory."
    exit 1
fi

# Check if video.txt exists
if [ ! -f "video.txt" ]; then
    echo "Error: video.txt not found in current directory."
    exit 1
fi

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: FFmpeg is not installed. Please install it first."
    exit 1
fi

VIDEO_URL=$(cat video.txt)
AUDIO_URL=$(cat audio.txt)
OUTPUT_FILE="$1.mp4"

echo "Downloading stream to $OUTPUT_FILE..."
if ffmpeg -i "$VIDEO_URL" -i "$AUDIO_URL" -c copy -map 0:v -map 1:a -f mp4 -y -stats "$OUTPUT_FILE"; then
    echo "Successfully downloaded: $OUTPUT_FILE"
    explorer .
else
    echo "Download failed!"
    # Clean up partial file if download failed
    [ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
    exit 1
fi


