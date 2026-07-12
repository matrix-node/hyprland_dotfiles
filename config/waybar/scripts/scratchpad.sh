#!/bin/bash
# Check if the magic scratchpad has any windows
count=$(hyprctl clients -j 2>/dev/null | jq '[.[] | select(.workspace.name == "special:magic")] | length' 2>/dev/null)
if [[ -n "$count" && "$count" -gt 0 ]]; then
  echo "{\"text\": \"󰎀 $count\", \"class\": \"scratchpad-active\"}"
else
  echo "{\"text\": \"\", \"class\": \"scratchpad-empty\"}"
fi
