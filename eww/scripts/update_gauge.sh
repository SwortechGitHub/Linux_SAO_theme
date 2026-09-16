#!/bin/bash

RAW_VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}')
PERCENT=${1:-$(awk -v v="${RAW_VOL:-1.0}" 'BEGIN { printf "%.0f", v * 100 }')}

OFFSET=$(awk -v p="$PERCENT" 'BEGIN { printf "%.0f", -1158 + (11.58 * p) }')

SVG_PATH="/home/swortech/.config/eww/images/life_gauge.svg"

if [ -f "$SVG_PATH" ]; then
    sed -i -E "/id=[\"']gauge_clip[\"']/,/<\/clipPath>/ s/(transform=[\"']translate\()[^)]*(\)[\"'])/\1${OFFSET}, 0\2/" "$SVG_PATH"
    # Output the absolute file path with a timestamp query to bypass GTK image caching
    echo "${SVG_PATH}"
fi