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

if [[ "$current_status" == "up" ]]; then
  echo '{"text": "󰍹", "tooltip": "Up for: '"$duration"'", "class": "connected"}'
else
  echo '{"text": "󰶐", "tooltip": "Down for: '"$duration"'", "class": "disconnected"}'
fi
