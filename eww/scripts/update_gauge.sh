#!/bin/bash

# Volume for test
RAW_VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}')
PERCENT=${1:-$(awk -v v="${RAW_VOL:-1.0}" 'BEGIN { printf "%.0f", v * 100 }')}

# Battery
# BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)
# if [ -n "$BAT_PATH" ] && [ -f "$BAT_PATH/capacity" ]; then
#     PERCENT=${1:-$(cat "$BAT_PATH/capacity")}
# else
#     PERCENT=${1:-100}
# fi

#Calculate bar offset
OFFSET=$(awk -v p="$PERCENT" 'BEGIN { printf "%.0f", -1158 + (11.58 * p) }')

# Define gradient stop colors based on percentage thresholds
if [ "$PERCENT" -le 20 ]; then
    COLOR_STOP1="#A71919" # Dark Red
    COLOR_STOP2="#D52929" # Light Red
elif [ "$PERCENT" -le 70 ]; then
    COLOR_STOP1="#A77E19" # Dark Yellow/Orange
    COLOR_STOP2="#D5AA29" # Light Yellow
else
    COLOR_STOP1="#65A719" # Dark Green
    COLOR_STOP2="#87D529" # Light Green
fi

SVG_PATH="/home/swortech/.config/eww/images/life_gauge.svg"

if [ -f "$SVG_PATH" ]; then
    sed -i -E "/id=[\"']gauge_clip[\"']/,/<\/clipPath>/ s/(transform=[\"']translate\()[^)]*(\)[\"'])/\1${OFFSET}, 0\2/" "$SVG_PATH"
    
    # Update stop-colors inside linearGradient id="1st_hp_a"
    sed -i -E "/id=[\"']1st_hp_a[\"']/,/<\/linearGradient>/ {
        s/(offset=[\"']0[\"'][^>]*stop-color=[\"'])#[0-9a-fA-F]{6}([\"'])/\1${COLOR_STOP1}\2/
        s/(offset=[\"']1[\"'][^>]*stop-color=[\"'])#[0-9a-fA-F]{6}([\"'])/\1${COLOR_STOP2}\2/
    }" "$SVG_PATH"
    
    # Output the absolute file path with a timestamp query to bypass GTK image caching
    echo "${SVG_PATH}"
fi