#!/usr/bin/env bash

HOST="google.com"
CACHE_PATH="/tmp"
CACHE_FILE="$CACHE_PATH/waybar-internet-cache"


convert_date() {
  local d1="$1"
  local d2="$2"

  diff=$(( d2 - d1 ))
  hours=$(( diff / 3600 ))
  minutes=$(( (diff % 3600) / 60 ))
  seconds=$(( diff % 60 ))

  echo "${hours}h, ${minutes}m, ${seconds}s"
}

if ping -c 1 -W 2 "$HOST" &>/dev/null; then
  current_status="up"
else
  current_status="down"
fi

now=$(date +%s)

if [[ ! -f "$CACHE_FILE" ]]; then
  echo "$current_status $now" > "$CACHE_FILE"
  start=$now
  saved_status=$current_status
else
  read -r saved_status start < "$CACHE_FILE"

  if [[ "$current_status" != "$saved_status" ]]; then
    # Status changed — reset the timer
    echo "$current_status $now" > "$CACHE_FILE"
    start=$now
  fi
fi

duration=$(convert_date $start $now)

# Tailscale: local socket query, no network traffic. "Running" + Online = connected to the tailnet.
ts=$(tailscale status --json --peers=false 2>/dev/null \
  | jq -r 'if .BackendState == "Running" and .Self.Online then "up" elif .BackendState == "Running" then "offline" else (.BackendState // "unknown") end' 2>/dev/null)
[[ -z "$ts" ]] && ts="not running"

if [[ "$current_status" == "up" && "$ts" == "up" ]]; then
  echo '{"text": "󰍹", "tooltip": "Up for: '"$duration"'\nTailscale: up", "class": "connected"}'
elif [[ "$current_status" == "up" ]]; then
  echo '{"text": "󰍹", "tooltip": "Up for: '"$duration"'\nTailscale: '"$ts"'", "class": "no-tailscale"}'
else
  echo '{"text": "󰶐", "tooltip": "Down for: '"$duration"'", "class": "disconnected"}'
fi
