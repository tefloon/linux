#!/bin/bash

# This script is the single entry point for the uwsm session.
# It's responsible for setting up the environment and launching
# all necessary components for the Hyprland desktop.

# --- 1. Set Environment Variables for Wayland ---
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export ECORE_EVAS_ENGINE=wayland_egl
export ELM_ENGINE=wayland_egl

# --- 2. Launch XDG Desktop Portal Services ---
# These are crucial for screen sharing, flatpak support, and more.
# We kill any existing instances first to ensure a clean start.
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal
sleep 1
/usr/lib/xdg-desktop-portal-hyprland &
sleep 1
/usr/lib/xdg-desktop-portal &

# --- 3. Update D-Bus Environment ---
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# --- 4. Launch Essential Background Services ---
/usr/lib/polkit-kde-authentication-agent-1 & # Handles graphical password prompts
mako &                                      # Notification daemon
waybar &                                    # The status bar
swayidle -w \
    timeout 300 'swaylock -f' \
    timeout 600 'hyprctl dispatch dpms off' \
    resume 'hyprctl dispatch dpms on' &     # Idle manager

# --- 5. Set Wallpaper ---
hyprpaper &

# --- 6. Launch Hyprland ---
# 'exec' replaces this script's process with Hyprland's.
# When Hyprland exits, the session ends.
exec Hyprland