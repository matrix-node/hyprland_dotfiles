#! /bin/bash

bar="▁▂▃▄▅▆▇█"
dict="s/;/ /g;"

# creating "dictionary" to replace char with bar
i=0
while [ $i -lt ${#bar} ]; do
  dict="${dict}s/$i/${bar:$i:1}/g;"
  i=$((i = i + 1))
done

# write cava config
config_file="/tmp/cava_waybar_config"
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
EOF

# read stdout from cava
cava -p "$config_file" | while read -r line; do
  echo "$line" | sed "$dict"
done
