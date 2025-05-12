#!/usr/bin/env bash

# Load configuration
source ./config/paths.sh

# Validate input
if [ -z "$1" ]; then
    echo "Error: Output filename required"
    echo "Usage: $0 <output_name>"
    exit 1
fi

# Run modules
source ./lib/cleanup.sh
source ./lib/extract_urls.sh
source ./lib/validate.sh
source ./lib/download.sh "$1"

