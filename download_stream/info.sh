#!/usr/bin/env bash
M3U8_URL=$(cat m3u8.txt)
curl -s "$M3U8_URL" | wc -l
