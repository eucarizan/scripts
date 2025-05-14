#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "Error: file to track needed as an argument"
    echo "Usage: $0 <file>"
    exit 1
fi

git_log_stat=$(git log --all --pretty=format:"%h" --name-status 2>/dev/null | awk '/^[0-9a-f]{7,}$/ { hash = $0; next }; /^[A-Z]\t/ { split ($0, a, "\t"); print hash ";" a[1] ";" a[2] } ' | grep ";.*$1$")

if [ -z "$git_log_stat" ]; then
    echo "Error: File '$1' not found in git history"
    exit 1
fi

echo "hash;status;file"
echo "$git_log_stat"

#hash_latest=$(git log -1 --all --pretty=format:%h --follow -- "$1" 2>/dev/null)
#
#if [ -z "$hash_latest" ]; then
#    echo "Error: File '$1' not found in git history"
#    exit 1
#fi
#
#echo "Latest commit hash for '$1': $hash_latest"
#
#hash_new=$(git log --diff-filter=A --pretty=format:%h --find-renames -- "$1" | tail -1)
#
#if [ -z "$hash_new" ]; then
#    echo "Warning: Could not determine creation commit for '$1'"
#else
#    echo "Creation commit hash for '$1': $hash_new"
#fi

#hash:path/to/file/file.ext
#git log --all --pretty=format:"%h" --name-only | awk '/^[0-9a-f]{7,}$/ { hash = $0; next }; $0 != "" { print hash ":" $0 }' | grep "$1$"

