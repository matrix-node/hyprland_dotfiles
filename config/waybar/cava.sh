#!/bin/bash

bar="▁▂▃▄▅▆▇█"
dict="s/;/ /g;"

# creating "dictionary" to replace char with bar
i=0
while [ $i -lt ${#bar} ]; do
  dict="${dict}s/$i/${bar:$i:1}/g;"
  i=$((i = i + 1))
done

# write cava config — use matugen-generated config if available
config_file="/tmp/cava_waybar_config"
matugen_config="$HOME/.config/cava/waybar.conf"

if [[ -f "$matugen_config" ]]; then
  cp "$matugen_config" "$config_file"
else
  cat >"$config_file" <<EOF
[general]
bars = 24
bar_width = 2
bar_spacing = 0
sensitivity = 100
noise_reduction = 35

[input]
method = pipewire
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
channels = mono
mono_option = average

[smoothing]
noise_reduction = 65
monstercat = 1
waves = 0
gravity = 70
EOF
fi

# wait for PipeWire to be ready before starting cava
while true; do
  if pw-cli info all 2>/dev/null | grep -q "core" 2>/dev/null; then
    break
  fi
  sleep 0.5
done

# run cava in a restart loop
while true; do
  cava -p "$config_file" 2>/dev/null | while read -r line; do
    echo "$line" | sed "$dict"
  done
  sleep 0.5
done
