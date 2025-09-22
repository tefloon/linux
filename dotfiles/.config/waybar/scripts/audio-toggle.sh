#!/bin/bash

# Toggle mute for default sink
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Optional: Send notification
if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
    notify-send "Audio" "Muted" -t 1000
else
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
    notify-send "Audio" "Unmuted - ${volume}%" -t 1000
fi