#!/usr/bin/env bash
if [ -z "$1" ]; then
    log "Error: Please provide input file as an argument."
    log "Usage: $0 input.mp4"
    exit 1
fi

if [ ! -f "$1" ]; then
    log "Error: File '$1' not found"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    log "Error: FFmpeg is not installed"
    exit 1
fi
