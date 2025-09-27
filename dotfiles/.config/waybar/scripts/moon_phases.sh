#!/bin/bash

CACHE_PATH="$HOME/.config/waybar/tmp"
CACHE_FILE="$CACHE_PATH/moon_cache"
CACHE_DURATION=86400  # 24 hours
LOCK_FILE="/tmp/waybar_moon.lock"

mkdir -p "$CACHE_PATH"

# Check if cache exists and is recent
if [[ -f "$CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 99999))) -lt $CACHE_DURATION ]]; then
    cat "$CACHE_FILE"
    exit 0
fi

# Try to acquire lock
if ! mkdir "$LOCK_FILE" 2>/dev/null; then
    echo "Another waybar instance is fetching moon data, skipping..." >&2
    
    # Wait up to 30 seconds for other process to finish
    for i in {1..30}; do
        if [[ ! -d "$LOCK_FILE" ]]; then
            break
        fi
        sleep 1
    done
    
    # Output cached data to stdout (for waybar)
    cat "$CACHE_FILE" 2>/dev/null || echo '{"text": "󰽧", "tooltip": "Moon phase data unavailable", "class": "moon-phase-error"}'
    exit 0
fi

# Clean up lock on exit
trap 'rmdir "$LOCK_FILE" 2>/dev/null' EXIT

# Calculate moon phase using local Python script
echo "Calculating moon phase..." >&2
moon_data=$(python3 "$HOME/.config/waybar/scripts/moon_phase.py" 2>&1)
python_exit=$?

echo "Python exit code: $python_exit" >&2
echo "Moon data: '$moon_data'" >&2

if [[ $python_exit -eq 0 ]] && [[ -n "$moon_data" ]]; then
    # Cache and output the JSON
    echo "$moon_data" > "$CACHE_FILE"
    cat "$CACHE_FILE"
else
    echo "ERROR: Python script failed" >&2
    # Fallback to cached data if available
    if [[ -f "$CACHE_FILE" ]]; then
        jq -c '.tooltip += " (Data stale)"' "$CACHE_FILE"
    else
        echo '{"text": "󰽧", "tooltip": "Moon phase calculation failed", "class": "moon-phase-error"}'
    fi
fi