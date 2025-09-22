#!/bin/bash

# Game mode toggle script for Waybar
# This replicates your QuickShell game mode functionality

# Test script
echo "Current state: $(if [[ -f /tmp/waybar_gamemode ]]; then echo 'ACTIVE'; else echo 'INACTIVE'; fi)"

STATE_FILE="/tmp/waybar_gamemode"

if [[ -f "$STATE_FILE" ]]; then
    # Game mode is ON, turn it OFF
    rm "$STATE_FILE"
    
    # Restore settings manually instead of full reload
    hyprctl --batch "keyword animations:enabled yes; keyword decoration:shadow:enabled true; keyword decoration:blur:enabled true; keyword general:gaps_in 5; keyword general:gaps_out 10; keyword general:border_size 1; keyword decoration:rounding 8; keyword general:allow_tearing true; keyword input:kb_options caps:super; keyword input:kb_model ''"
    
    # Re-enable the clipboard history keybind
    hyprctl keyword bind "CONTROL, grave, exec, \$HOME/.local/share/launch-scripts/wofi-clip-history.sh"
    
    $HOME/.local/share/launch-scripts/launch-nwg.sh &

    notify-send "Game Mode" "Disabled - Full desktop restored" -t 2000
else
    # Game mode is OFF, turn it ON
    touch "$STATE_FILE"
    
    # Apply game mode settings (from your original script)
    hyprctl --batch "keyword animations:enabled 0; keyword decoration:shadow:enabled 0; keyword decoration:blur:enabled 0; keyword general:gaps_in 0; keyword general:gaps_out 0; keyword general:border_size 1; keyword decoration:rounding 0; keyword general:allow_tearing 1; keyword input:kb_options ''; keyword input:kb_model ''"
    
    # Disable the clipboard history keybind
    hyprctl keyword unbind "CONTROL, grave"
    
    pkill nwg-dock

    notify-send "Game Mode" "Enabled - Performance optimized" -t 2000    
fi