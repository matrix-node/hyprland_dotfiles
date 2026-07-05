#!/bin/bash
pkill waybar
pkill cava
env LANG=C.UTF-8 LC_ALL=C.UTF-8 waybar &
