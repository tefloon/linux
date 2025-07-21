#!/usr/bin/env bash

CURRENT_STEP_MESSAGE="Enabling multilib"
status_msg

PACMAN_CONF="/etc/pacman.conf"
# Uncomment [multilib] and its Include line if commented
sudo sed -i '/^\s*#\s*\[multilib\]/, /^\s*#\s*Include = \/etc\/pacman.d\/mirrorlist/ {
    s/^\s*#\s*\(\[multilib\]\)/\1/
    s/^\s*#\s*\(Include = \/etc\/pacman.d\/mirrorlist\)/\1/
}' "$PACMAN_CONF"

sudo pacman -Sy --noconfirm --quiet && status_ok || status_error

# --- HYPRLAND CORE ---
install_pkg "hyprland"
install_pkg "hyprpaper"
install_pkg "waybar"
install_pkg "wofi"
install_pkg "kitty"
install_pkg "mako"
install_pkg "swaylock"
install_pkg "swayidle"
install_pkg "wl-clipboard"
install_pkg "grim"
install_pkg "slurp"
install_pkg "polkit-kde-agent"
install_pkg "xdg-desktop-portal-hyprland"
install_pkg "qt5-wayland"
install_pkg "qt6-wayland"
install_pkg "qt5ct"
install_pkg "qt6ct"

# --- YOUR EXISTING APPS & UTILITIES ---
install_pkg "atool"
install_pkg "bat"
install_pkg "btop"
install_pkg "bitwarden-cli"
install_pkg "calibre"
install_pkg "copyq"
install_pkg "corectrl"
install_pkg "fd"
install_pkg "helvum"
install_pkg "jq" 
install_pkg "ttf-jetbrains-mono-nerd"
install_pkg "kdeconnect"
install_pkg "keychain"
install_pkg "kodi"
install_pkg "libqalculate" 
install_pkg "lutris"
install_pkg "obsidian"
install_pkg "openssl"
install_pkg "openssh"
install_pkg "qbittorrent"
install_pkg "spotifyd"
install_pkg "steam"
install_pkg "tealdeer"
install_pkg "tree"
install_pkg "ttf-fira-code"
install_pkg "ugrep"
install_pkg "unrar"
install_pkg "virtualbox"
install_pkg "yazi"
install_pkg "zsh-syntax-highlighting"
install_pkg "zsh-autosuggestions"
install_pkg "zoxide"
install_pkg "debugedit"

# --- AUR PACKAGES ---
install_aur_pkg "qalc"
install_aur_pkg "brave-bin"
install_aur_pkg "code"
install_aur_pkg "cursor-electron"
install_aur_pkg "dragon-drop"
install_aur_pkg "ferdium-nightly-bin"
install_aur_pkg "onlyoffice-bin"
install_aur_pkg "spotify"
install_aur_pkg "spotify-player"
install_aur_pkg "sublime-text-4"