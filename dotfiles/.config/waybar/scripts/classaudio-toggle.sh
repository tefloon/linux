#!/bin/bash

# Class audio toggle: lets Meet students hear Class-Audio (Spotify / mpv / Brave)
# by linking it into the Meet-Mic mix.
# Devices live in ~/.config/pipewire/pipewire.conf.d/90-class-audio.conf.
#
# State is read from PipeWire, not a /tmp file, so the icon can't claim
# "on" after a PipeWire restart dropped the link.
#
#   classaudio-toggle.sh          toggle
#   classaudio-toggle.sh status   print waybar JSON

LOOPBACK_ARGS="source=class_audio.monitor sink=meet_mix"

module_id() {
    pactl list modules short | awk -v args="$LOOPBACK_ARGS" '$2 == "module-loopback" && index($0, args) { print $1; exit }'
}

if [[ "$1" == "status" ]]; then
    if [[ -n "$(module_id)" ]]; then
        echo '{"class": "active", "tooltip": "Class audio: students hear it"}'
    else
        echo '{"class": "inactive", "tooltip": "Class audio: only you hear it"}'
    fi
    exit 0
fi

ID="$(module_id)"

if [[ -n "$ID" ]]; then
    # Class audio is ON, turn it OFF
    pactl unload-module "$ID"

    pkill -x -RTMIN+14 waybar
    notify-send "Class Audio" "Off - students hear only you" -t 2000
else
    # Class audio is OFF, turn it ON
    if pactl load-module module-loopback $LOOPBACK_ARGS latency_msec=20 source_dont_move=true sink_dont_move=true >/dev/null; then
        notify-send "Class Audio" "On - students hear the music" -t 2000
    else
        notify-send -u critical "Class Audio" "Failed - is the PipeWire class-audio config loaded?" -t 4000
    fi

    pkill -x -RTMIN+14 waybar
fi
