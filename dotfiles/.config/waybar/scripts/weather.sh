#!/bin/bash

LOCATION="ursynow"  # Change to your location
CACHE_PATH="$HOME/.config/waybar/tmp"
CACHE_FILE="$CACHE_PATH/weather_cache"
CACHE_DURATION=1800  # 30 minutes
LOCK_FILE="/tmp/waybar_weather.lock"

mkdir -p "$CACHE_PATH"

# Check if cache exists and is recent
if [[ -f "$CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 99999))) -lt $CACHE_DURATION ]]; then
    cat "$CACHE_FILE"
    exit 0
fi

# Try to acquire lock
if ! mkdir "$LOCK_FILE" 2>/dev/null; then
    echo "Another waybar instance is fetching weather data, skipping..." >&2

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

# Fetch weather data
echo "Fetching weather for $LOCATION..." >&2
weather_data=$(curl -s "wttr.in/${LOCATION}?format=%C+%t" 2>&1)
curl_exit=$?

echo "Curl exit code: $curl_exit" >&2
echo "Raw weather data: '$weather_data'" >&2

if [[ $curl_exit -ne 0 ]]; then
    echo "ERROR: Curl failed with exit code $curl_exit" >&2
    # Instead of exit 1, provide fallback JSON
    if [[ -f "$CACHE_FILE" ]]; then
        jq -c '.tooltip += " (Data stale)"' "$CACHE_FILE"
        exit 0
    else
        echo '{"text": "---", "tooltip": "Weather data unavailable", "class": "weather-error"}'
        exit 0
    fi
fi

if [[ -n "$weather_data" ]]; then
    # Parse from the end: extract temperature with proper sign handling
    temp_with_sign=$(echo "$weather_data" | grep -o '[+-]\?[0-9]\+°C')

    # Remove leading + but keep - for negative temperatures
    if [[ "$temp_with_sign" =~ ^\+.*$ ]]; then
        temp=${temp_with_sign#+}  # Remove leading +
    else
        temp="$temp_with_sign"    # Keep - or no sign
    fi

    condition=$(echo "$weather_data" | sed 's/[[:space:]]*[+-]\?[0-9]\+°C.*$//')

    # Lowercase copy for matching; $condition stays intact for display
    cond="${condition,,}"

    # Nerd font icon mapping.
    # Order matters: first match wins, so specific patterns go above broad ones.
    case "$cond" in
        # Thunder first - wttr.in appends "with thunder" to rain/snow conditions
        *thunder*|*lightning*)              icon="󰖓" ;;

        # Severe / frozen precipitation
        *blizzard*|*"blowing snow"*)        icon="󰼸" ;;
        *tornado*|*hurricane*)              icon="󰼲" ;;
        *"freezing rain"*|*"freezing drizzle"*) icon="󰙿" ;;
        *sleet*|*"ice pellets"*)            icon="󰙿" ;;
        *snow*)                             icon="󰖘" ;;

        # Liquid precipitation
        *drizzle*)                          icon="󰼳" ;;
        *rain*|*shower*)                    icon="󰖖" ;;

        # Visibility
        *fog*|*mist*|*haze*)                icon="󰖑" ;;
        *dust*|*sand*)                      icon="󰼯" ;;

        # Cloud cover
        *overcast*)                         icon="󰖐" ;;
        *"partly cloudy"*|*"partly sunny"*) icon="󰖕" ;;
        *cloud*)                            icon="󰖐" ;;

        # Clear
        *sunny*|*clear*)                    icon="󰖙" ;;

        # Temperature extremes (only reached if nothing above matched)
        *hot*)                              icon="󰔏" ;;
        *cold*|*freezing*)                  icon="❄" ;;
        *wind*|*breezy*)                    icon="󰖝" ;;

        # Default fallback - visible, not empty
        *)                                  icon="󰖐" ;;
    esac

    # Create main display
    main_text="$icon   $temp"

    # Build JSON with jq so quotes/backslashes in $condition can't break it
    jq -nc \
        --arg text "$main_text" \
        --arg tooltip "$condition $temp"$'\n'"$LOCATION" \
        '{text: $text, tooltip: $tooltip, class: "weather"}' > "$CACHE_FILE"

    cat "$CACHE_FILE"
else
    if [[ -f "$CACHE_FILE" ]]; then
        jq -c '.tooltip += " (Data stale)"' "$CACHE_FILE"
        exit 0
    else
        # Fallback if weather fetch fails and there is no cache
        echo '{"text": "---", "tooltip": "Weather data unavailable", "class": "weather-error"}'
    fi
fi
