#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Error: Output filename required"
    echo "Usage: $0 <output_name>"
    exit 1
fi

[ -f "$input_file" ] && rm "$input_file"

if ! command -v ffmpeg &>/dev/null; then
    echo "Error: FFmpeg not installed"
    exit 1
fi

curl -s "$(cat "$m3u8_source")" > "$input_file"
