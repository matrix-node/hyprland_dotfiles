#!/usr/bin/env bash
# Pipe cava audio visualization to waybar
# Outputs JSON for waybar custom module

set -uo pipefail

config="$HOME/.config/cava/waybar.conf"
cava_bin="/usr/sbin/cava"
jq_bin="/usr/sbin/jq"
levels=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

emit() {
    "$jq_bin" -cn --arg text "$1" --arg class "$2" '{text: $text, class: $class}'
}

[ -f "$config" ] || config="$HOME/.config/cava/config"
[ -x "$cava_bin" ] || {
    emit "▁▁▁▁▁▁▁▁▁▁▁▁" "quiet"
    exit 0
}

frame="$(timeout 1s "$cava_bin" -p "$config" 2>/dev/null | head -n 1 || true)"
if [ -z "$frame" ]; then
    emit "▁▁▁▁▁▁▁▁▁▁▁▁" "quiet"
    exit 0
fi

IFS=';' read -ra values <<< "$frame"
text=""
peak=0

for value in "${values[@]}"; do
    [[ "$value" =~ ^[0-7]$ ]] || continue
    (( value > peak )) && peak=$value
    text+="${levels[$value]}"
done

[ -n "$text" ] || text="▁▁▁▁▁▁▁▁▁▁▁▁"

if (( peak <= 1 )); then
    emit "$text" "quiet"
elif (( peak >= 6 )); then
    emit "$text" "hot"
else
    emit "$text" "active"
fi
