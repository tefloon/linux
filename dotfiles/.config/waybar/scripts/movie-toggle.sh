#!/bin/bash

# Cinema mode toggle script
# Dims all inactive windows dramatically

STATE_FILE="/tmp/waybar_cinemamode"

if [[ -f "$STATE_FILE" ]]; then
    # Cinema mode is ON, turn it OFF
    rm "$STATE_FILE"
    
    # Restore normal dim level
    hyprctl keyword decoration:dim_inactive true
    hyprctl keyword decoration:dim_strength 0.1
    
    pkill -x -RTMIN+13 waybar  # Different signal than game mode
    notify-send "Cinema Mode" "Disabled - Normal dimming restored" -t 2000
else
    # Cinema mode is OFF, turn it ON
    touch "$STATE_FILE"
    
    # Apply cinema mode settings - max dim inactive windows
    hyprctl keyword decoration:dim_inactive true
    hyprctl keyword decoration:dim_strength 1.0
    
    pkill -x -RTMIN+13 waybar
    notify-send "Cinema Mode" "Enabled - Movie time! 🎬" -t 2000
fi
```

Add this to your Hyprland config:
```
bind = $mainMod, C, exec, ~/.local/share/launch-scripts/cinema-mode.sh