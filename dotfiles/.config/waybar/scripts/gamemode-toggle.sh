#!/bin/bash

echo "Current state: $(if [[ -f /tmp/waybar_gamemode ]]; then echo 'ACTIVE'; else echo 'INACTIVE'; fi)"

STATE_FILE="/tmp/waybar_gamemode"

# Since the migration to the Lua config, `hyprctl keyword` no longer works
# ("keyword can't work with non-legacy parsers. Use eval."), so everything
# goes through `hyprctl eval` + the `hl` Lua API instead.

if [[ -f "$STATE_FILE" ]]; then
    # Game mode is ON, turn it OFF
    rm "$STATE_FILE"

    # Restore settings manually instead of full reload
    hyprctl eval 'hl.config({
        animations = { enabled = true },
        decoration = { shadow = { enabled = true } },
        general    = { allow_tearing = true },
        input      = { kb_options = "caps:super,altwin:hyper_win", kb_model = "" },
    })'

    # Re-enable the clipboard history keybind
    hyprctl eval "hl.bind('CONTROL + grave', hl.dsp.exec_cmd('$HOME/.local/share/launch-scripts/wofi-clip-history.sh'))"

    pkill -x -RTMIN+12 waybar
    notify-send "Game Mode" "Disabled - Full desktop restored" -t 2000

else
    # Game mode is OFF, turn it ON
    touch "$STATE_FILE"

    # Apply game mode settings
    hyprctl eval 'hl.config({
        animations = { enabled = false },
        decoration = { shadow = { enabled = false } },
        general    = { allow_tearing = true },
        input      = { kb_options = "", kb_model = "" },
    })'

    # Disable the clipboard history keybind
    hyprctl eval 'hl.unbind("CONTROL + grave")'

    pkill -x -RTMIN+12 waybar
    notify-send "Game Mode" "Enabled - Performance optimized" -t 2000

fi
