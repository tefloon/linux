#!/usr/bin/env bash
if pgrep -x "wofi" > /dev/null; then
    pkill wofi
else
    wofi --show drun --allow-images --insensitive --prompt "Launch"
fi