#!/usr/bin/env bash
# Pipe cava audio visualization to waybar.
# Outputs JSON for waybar custom module. Never crashes the bar.

set -uo pipefail

config="${HOME}/.config/cava/waybar.conf"
cava_bin="$(command -v cava 2>/dev/null || true)"
jq_bin="$(command -v jq 2>/dev/null || true)"
levels=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

emit() {
    local text="$1" class="$2"
    if [[ -n "$jq_bin" ]]; then
        "$jq_bin" -cn --arg text "$text" --arg class "$class" '{text: $text, class: $class}'
    else
        # Minimal JSON fallback if jq is missing
        printf '{"text":"%s","class":"%s"}\n' "$text" "$class"
    fi
}

quiet_bars="▁▁▁▁▁▁▁▁▁▁▁▁"

[[ -f "$config" ]] || config="${HOME}/.config/cava/config"

if [[ -z "$cava_bin" || ! -x "$cava_bin" ]]; then
    emit "$quiet_bars" "quiet"
    exit 0
fi

frame="$(timeout 1s "$cava_bin" -p "$config" 2>/dev/null | head -n 1 || true)"
if [[ -z "$frame" ]]; then
    emit "$quiet_bars" "quiet"
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

[[ -n "$text" ]] || text="$quiet_bars"

if (( peak <= 1 )); then
    emit "$text" "quiet"
elif (( peak >= 6 )); then
    emit "$text" "hot"
else
    emit "$text" "active"
fi
