#!/usr/bin/env bash
# Show currently playing music for waybar
# Outputs JSON: {"text": "...", "class": "...", "tooltip": "..."}

set -euo pipefail

player_status=$(playerctl status 2>/dev/null) || {
    jq -cn '{text: "", class: "stopped", tooltip: "No player running"}'
    exit 0
}

artist=$(playerctl metadata artist 2>/dev/null || echo "Unknown")
title=$(playerctl metadata title 2>/dev/null || echo "Unknown")

if [ "$player_status" = "Playing" ]; then
    icon=""
    class="playing"
elif [ "$player_status" = "Paused" ]; then
    icon=""
    class="paused"
else
    icon=""
    class="stopped"
fi

# Truncate if too long
label="$icon $artist - $title"
if [ ${#label} -gt 42 ]; then
    label="${label:0:39}..."
fi

jq -cn --arg text "$label" --arg class "$class" --arg tooltip "$artist - $title" \
    '{text: $text, class: $class, tooltip: $tooltip}'
