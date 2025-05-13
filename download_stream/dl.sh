#!/usr/bin/env bash

# Load configuration
source <(grep = config.ini | sed 's/ *= */=/')

# Validate input
source lib/validate.sh "$1"

# Extract URLs
source lib/extract.sh

# Process download
source lib/ffmpeg.sh "$1"
