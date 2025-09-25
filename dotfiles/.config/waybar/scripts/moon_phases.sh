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

sleep $((5 + RANDOM % 10))

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
    cat "$CACHE_FILE" 2>/dev/null || echo '{"text": "--"}'
    exit 0
fi

# Clean up lock on exit
trap 'rmdir "$LOCK_FILE" 2>/dev/null' EXIT

# Fetch moon phase data
echo "Fetching moon phase data..." >&2
moon_data=$(curl -s "wttr.in/moon?format=%M" 2>&1)
curl_exit=$?

echo "Curl exit code: $curl_exit" >&2
echo "Raw moon data: '$moon_data'" >&2

if [[ $curl_exit -ne 0 ]]; then
    echo "ERROR: Curl failed with exit code $curl_exit" >&2
    # Instead of exit 1, provide fallback JSON
    if [[ -f "$CACHE_FILE" ]]; then
        jq -c '.tooltip += " (Data stale)"' "$CACHE_FILE"
        exit 0
    else
        echo '{"text": "---", "tooltip": "Moon phase data unavailable", "class": "moon-phase-error"}'
        exit 0
    fi
fi

if [[ -n "$moon_data" ]]; then
    # Extract phase number (first character) and emoji (second character)
    phase_num=${moon_data:0:1}

    # Map phase number to description and nerd font icon
    case "$phase_num" in
        1) phase_name="New Moon"; phase_icon="󰽤" ;;
        2) phase_name="Waxing Crescent"; phase_icon="" ;;
        3) phase_name="First Quarter"; phase_icon="" ;;
        4) phase_name="Waxing Gibbous"; phase_icon="" ;;
        5) phase_name="Full Moon"; phase_icon="" ;;
        6) phase_name="Waning Gibbous"; phase_icon="󰽦" ;;
        7) phase_name="Third Quarter"; phase_icon="" ;;
        8) phase_name="Waning Crescent"; phase_icon="" ;;
        *) phase_name="Unknown Phase"; phase_icon="󰽧" ;;
    esac
    
    # Try using the emoji from wttr.in first, fallback to nerd font if needed
    # You can test which one works better with your font
    display_icon="$phase_icon"  # Uncomment this line to use nerd font instead
    
    # Create JSON output
    output=$(cat <<EOF
{
    "text": "$display_icon",
    "tooltip": "Moon Phase: $phase_name\nPhase: $phase_num/8\nClick for detailed moon info",
    "class": "moon-phase"
}
EOF
)
    
    # Convert multi-line JSON to single-line and cache it
    echo "$output" | jq -c . > "$CACHE_FILE"
    cat "$CACHE_FILE"
else
    if [[ -f "$CACHE_FILE" ]]; then
        jq -c '.tooltip += " (Data stale)"' "$CACHE_FILE"
        exit 0
    else
    # Fallback if moon data fetch fails and there is no cache
        echo '{"text": "---", "tooltip": "Moon phase data unavailable", "class": "moon-phase-error"}'
    fi
fi