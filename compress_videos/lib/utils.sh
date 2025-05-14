#!/usr/bin/env bash

init_logging() {
    mkidr -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/compress-$(date +%Y%m%d_%H-%M-%S).log"
    exec 3>&1
    exec &> >(tee -a "$LOG_FILE") 2>&1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee /dev/fd/3
}
