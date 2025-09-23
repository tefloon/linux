#!/bin/bash

MOON_CACHE_FILE="/tmp/waybar_moon"
MOON_PHASE_COOLDOWN=86400  # 24 hours

# Check if cache exists and is recent
if [[ -f "$MOON_CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$MOON_CACHE_FILE" 2>/dev/null || echo 99999))) -lt $MOON_PHASE_COOLDOWN ]]; then
    cat "$MOON_CACHE_FILE"
    exit 0
fi

# Fetch moon phase data
moon_data=$(curl -s "wttr.in/moon?format=%M" 2>/dev/null)

if [[ $? -eq 0 ]] && [[ -n "$moon_data" ]]; then
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
    "tooltip": "Moon Phase: $phase_name\\nPhase: $phase_num/8\\nClick for detailed moon info",
    "class": "moon-phase"
}
EOF
)
    
    # Cache the output and display it
    echo "$output" | jq -c . > "$MOON_CACHE_FILE"
    cat "$MOON_CACHE_FILE"
else
    # Fallback if moon data fetch fails
    echo '{"text": "--", "tooltip": "Moon phase data unavailable", "class": "moon-phase-error"}'
fi