#!/bin/bash

echo "Current state: $(if [[ -f /tmp/waybar_gamemode ]]; then echo 'ACTIVE'; else echo 'INACTIVE'; fi)"

STATE_FILE="/tmp/waybar_gamemode"

if [[ -f "$STATE_FILE" ]]; then
    # Game mode is ON, turn it OFF
    rm "$STATE_FILE"
    
    # Restore settings manually instead of full reload
    hyprctl --batch "keyword animations:enabled yes; \
    keyword decoration:shadow:enabled true; \
    keyword general:allow_tearing true; \
    keyword input:kb_options caps:super; \
    keyword input:kb_model ''"
    
    # Re-enable the clipboard history keybind
    hyprctl keyword bind "CONTROL, grave, exec, \$HOME/.local/share/launch-scripts/wofi-clip-history.sh"
    
    pkill -x -RTMIN+12 waybar
    notify-send "Game Mode" "Disabled - Full desktop restored" -t 2000
    
else
    # Game mode is OFF, turn it ON
    touch "$STATE_FILE"
    
    # Apply game mode settings (from your original script)
    hyprctl --batch "keyword animations:enabled 0; \
    keyword decoration:shadow:enabled 0; \
    keyword general:allow_tearing 1; \
    keyword input:kb_options ''; \
    keyword input:kb_model ''"
    
    # Disable the clipboard history keybind
    hyprctl keyword unbind "CONTROL, grave"

    pkill -x -RTMIN+12 waybar
    notify-send "Game Mode" "Enabled - Performance optimized" -t 2000
    
fi
