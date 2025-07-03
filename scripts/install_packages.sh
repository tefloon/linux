#!/usr/bin/env bash

# Path to pacman.conf
PACMAN_CONF="/etc/pacman.conf"

# Uncomment [multilib] and its Include line if commented
sed -i '/^\s*#\s*\[multilib\]/, /^\s*#\s*Include = \/etc\/pacman.d\/mirrorlist/ {
    s/^\s*#\s*\(\[multilib\]\)/\1/
    s/^\s*#\s*\(Include = \/etc\/pacman.d\/mirrorlist\)/\1/
}' "$PACMAN_CONF"

# Update package database
pacman -Sy

install_pkg "atool"
install_pkg "bat"
install_pkg "btop"
install_pkg "calibre"
install_pkg "copyq"
install_pkg "corectrl"
install_pkg "fd"
install_pkg "flameshot"
install_pkg "helvum"
install_pkg "jq"
install_pkg "kdeconnect"
install_pkg "keychain"
install_pkg "kodi"
install_pkg "lutris"
install_pkg "obsidian"
install_pkg "openssl"
install_pkg "qbittorrent"
install_pkg "spotifyd"
install_pkg "steam"
install_pkg "tealdeer"
install_pkg "tree"
install_pkg "ttf-fira-code"
install_pkg "ugrep"
install_pkg "unrar"
install_pkg "virtualbox"
install_pkg "xclip"
install_pkg "yazi"
install_pkg "zsh-syntax-highlighting"

install_aur_pkg "qalc"
install_aur_pkg "brave-bin"
install_aur_pkg "code"
install_aur_pkg "cursor-electron"
install_aur_pkg "dragon-drop"
install_aur_pkg "franz-bin"
install_aur_pkg "onlyoffice-bin"
install_aur_pkg "spotify"
install_aur_pkg "spotify-player"
install_aur_pkg "sublime-text-4"