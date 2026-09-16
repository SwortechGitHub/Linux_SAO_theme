#!/bin/bash

# Kill any existing eww daemon instances
killall eww 2>/dev/null

# Start the eww daemon in the background
eww daemon &

# Wait briefly for the daemon to initialize
sleep 0.5

# Open your window
eww open battery
eww open clock