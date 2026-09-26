#!/bin/bash

# Battery
BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)
if [ -n "$BAT_PATH" ] && [ -f "$BAT_PATH/capacity" ]; then
    PERCENT=${1:-$(cat "$BAT_PATH/capacity")}
else
    PERCENT=${1:-100}
fi

# Calculate bar offset
OFFSET=$(awk -v p="$PERCENT" 'BEGIN { printf "%.0f", -1158 + (11.58 * p) }')

# Use awk for float comparison and color selection
read -r COLOR_STOP1 COLOR_STOP2 <<< $(awk -v p="$PERCENT" 'BEGIN {
    if (p <= 21.25) { print "#890034 #AE0750" }
    else if (p <= 54.75) { print "#939409 #B4B733" }
    else { print "#65A719 #87D529" }
}')

# Setup Paths
# Rename your original SVG to life_gauge_template.svg so it doesn't get overwritten
TEMPLATE_PATH="$HOME/.config/eww/images/life_gauge_template.svg"
# Write output to tmpfs (RAM) to avoid SSD wear and force eww to bypass cache
OUTPUT_PATH="/tmp/life_gauge_${PERCENT}.svg"

if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "Error: Template not found at $TEMPLATE_PATH"
    exit 1
fi

# Only run sed if this percentage's file hasn't been generated yet
if [ ! -f "$OUTPUT_PATH" ]; then
    cp "$TEMPLATE_PATH" "$OUTPUT_PATH"
    
    # Modify the clip path
    sed -i -E "/id=[\"']gauge_clip[\"']/,/<\/clipPath>/ s/(transform=[\"']translate\()[^)]*(\)[\"'])/\1${OFFSET}, 0\2/" "$OUTPUT_PATH"
    
    # Update stop-colors inside linearGradient id="1st_hp_a"
    sed -i -E "/id=[\"']1st_hp_a[\"']/,/<\/linearGradient>/ {
        s/(offset=[\"']0[\"'][^>]*stop-color=[\"'])#[0-9a-fA-F]{6}([\"'])/\1${COLOR_STOP1}\2/
        s/(offset=[\"']1[\"'][^>]*stop-color=[\"'])#[0-9a-fA-F]{6}([\"'])/\1${COLOR_STOP2}\2/
    }" "$OUTPUT_PATH"
fi

# Output the unique file path for Eww
echo "${OUTPUT_PATH}"