#!/usr/bin/env bash
# Check if filename is provided
if [ -z "$1" ]; then
    echo "Error: Please provide the output filename (without extension) as an argument."
    echo "Usage: $0 <file_name>"
    exit 1
fi

# Check if m3u8.txt exists
if [ ! -f "m3u8.txt" ]; then
    echo "Error: m3u8.txt not found in current directory."
    exit 1
fi

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: FFmpeg is not installed. Please install it first."
    exit 1
fi

M3U8_URL=$(cat m3u8.txt)
OUTPUT_FILE="$1.mp4"

echo "Downloading stream to $OUTPUT_FILE..."
if ffmpeg -i "$M3U8_URL" -c copy -f mp4 -y -stats "$OUTPUT_FILE"; then
    echo "Successfully downloaded: $OUTPUT_FILE"
    explorer .
else
    echo "Download failed!"
    # Clean up partial file if download failed
    [ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
    exit 1
fi
