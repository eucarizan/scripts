#!/usr/bin/env bash
source config/config.sh

init_logging() {
    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/compress-$(date +%Y%m%d_%H-%M-%S).log"
    exec 3>&1
    exec &> >(tee -a "$LOG_FILE") 2>&1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&3
}
