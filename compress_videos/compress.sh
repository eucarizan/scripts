#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "Error: Please provide input file as an argument."
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found"
    exit 1
fi

OUTPUT="${1%.*}-x265.mp4"

echo "Compressing $1 -> $OUTPUT"
echo "Using extreme 1080p H.265 compression.."

ffmpeg -i "$1" \
    -c:v libx265 \
    -crf 28 -preset slower \
    -x265-params \
      "no-sao=1:strong-intra-smoothing=0:limit-tu=4:qg-size=16:rc-lookahead=80" \
    -vf "scale=1920:1080:flags=lanczos" \
    -c:a libopus -b:a 64k \
    -movflags +faststart \
    "$OUTPUT"

if [ -f "$OUTPUT" ]; then
    echo "Successfully created compressed version:"
    ls -lh "$OUTPUT"
else
    echo "Compression failed"
    exit 1
fi
