#!/bin/bash

LOCATION="Warsaw"  # Change to your location
CACHE_FILE="/tmp/waybar_weather"
CACHE_DURATION=1800  # 30 minutes

# Check if cache exists and is recent
if [[ -f "$CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 99999))) -lt $CACHE_DURATION ]]; then
    cat "$CACHE_FILE"
    exit 0
fi

# Fetch weather data
weather_data=$(curl -s "wttr.in/${LOCATION}?format=%C+%t&m" 2>/dev/null)

if [[ $? -eq 0 ]] && [[ -n "$weather_data" ]]; then
    # Parse the data
    condition=$(echo "$weather_data" | cut -d' ' -f1)
    temp=$(echo "$weather_data" | cut -d' ' -f2-)
    
    # Simple icon mapping
    case "$condition" in
        *"Clear"*|*"Sunny"*) icon="☀️" ;;
        *"Partly"*|*"Cloudy"*) icon="⛅" ;;
        *"Overcast"*|*"Cloud"*) icon="☁️" ;;
        *"Rain"*|*"Drizzle"*) icon="🌧️" ;;
        *"Snow"*) icon="❄️" ;;
        *"Thunder"*) icon="⛈️" ;;
        *"Fog"*|*"Mist"*) icon="🌫️" ;;
        *) icon="🌡️" ;;
    esac
    
    # Create JSON output and convert to compact format
    output=$(cat <<EOF
{
    "text": "$icon $temp",
    "tooltip": "$condition $temp\\nLocation: $LOCATION\\nClick to open wttr.in",
    "class": "weather"
}
EOF
)
    
    # Convert multi-line JSON to single-line and cache it
    echo "$output" | jq -c . > "$CACHE_FILE"
    cat "$CACHE_FILE"
else
    # Fallback if weather fetch fails
    echo '{"text": "🌡️ --°C", "tooltip": "Weather data unavailable", "class": "weather-error"}'
fi