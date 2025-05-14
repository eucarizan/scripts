#!/usr/bin/env bash
LOG_DIR="./logs"
FFMPEG_PARAMS=(
    -c:v libx265
    -crf 28
    -preset slower
    -x265-params "no-sao=1:strong-intra-smoothing=0:limit-tu=4:qg-size=16:rc-lookahead=80"
    -vf "scale=1920:1080:flags=lanczos"
    -c:a libopus
    -b:a 64k
    -movflags +faststart
)

