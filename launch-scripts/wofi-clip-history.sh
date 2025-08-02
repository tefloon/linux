#!/bin/bash

if pgrep -x "wofi" > /dev/null; then
    pkill wofi
else
    cliphist list | wofi --dmenu --hide-scroll --width 400 | cliphist decode | wl-copy
fi
