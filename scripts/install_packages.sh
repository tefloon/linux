#!/usr/bin/env bash

CURRENT_STEP_MESSAGE="Enabling multilib"
status_msg

PACMAN_CONF="/etc/pacman.conf"
# Uncomment [multilib] and its Include line if commented
sudo sed -i '/^\s*#\s*\[multilib\]/, /^\s*#\s*Include = \/etc\/pacman.d\/mirrorlist/ {
    s/^\s*#\s*\(\[multilib\]\)/\1/
    s/^\s*#\s*\(Include = \/etc\/pacman.d\/mirrorlist\)/\1/
}' "$PACMAN_CONF"


install_pkg() {
    local pkg="$1"
    CURRENT_STEP_MESSAGE="Installing $pkg"
    status_msg
    if sudo pacman -S --noconfirm --needed $pkg > /tmp/pacman.log 2>&1; then
        status_ok
    else
        status_skip "Failed to install $pkg."
    fi
}

install_aur_pkg() {
    local pkg="$1"
    CURRENT_STEP_MESSAGE="Installing AUR package $pkg"
    status_msg
    if yay -S --noconfirm --needed $pkg > /tmp/yay.log 2>&1; then
        status_ok
    else
        status_skip "Failed to install $pkg."
    fi
}

# --- HYPRLAND CORE ---
install_pkg "hyprland"                    # Wayland compositor (window manager)
install_pkg "hyprpaper"                   # Wallpaper daemon for Hyprland
install_pkg "waybar"                      # Status bar for Wayland
install_pkg "wofi"                        # Application launcher (like rofi for Wayland)
install_pkg "kitty"                       # GPU-accelerated terminal emulator
install_pkg "mako"                        # Notification daemon for Wayland
install_pkg "swaylock"                    # Screen locker for Wayland
install_pkg "wl-clipboard"                # Clipboard utilities for Wayland
install_pkg "grim"                        # Screenshot utility for Wayland
install_pkg "slurp"                       # Screen area selection for screenshots
install_pkg "polkit-kde-agent"            # Authentication agent for privilege escalation
install_pkg "xdg-desktop-portal-hyprland" # Desktop portal for Hyprland (file dialogs, etc.)
install_pkg "xdg-desktop-portal-gtk"      # Desktop portal for Hyprland (file dialogs, etc.)
install_pkg "xdg-desktop-portal"          # Desktop portal for Hyprland (file dialogs, etc.)
install_pkg "qt5-wayland"                 # Qt5 Wayland support
install_pkg "qt6-wayland"                 # Qt6 Wayland support
install_pkg "qt5ct"                       # Qt5 configuration tool
install_pkg "qt6ct"                       # Qt6 configuration tool

# --- SYSTEM ESSENTIALS ---
install_pkg "xorg-xwayland"               # X11 compatibility layer for Wayland
install_pkg "brightnessctl"               # Screen brightness control
install_pkg "upower"                      # Battery/power management info
install_pkg "nm-connection-editor"        # GUI network connection editor

# --- FILE & ARCHIVE MANAGEMENT ---
install_pkg "atool"                       # Archive extraction/creation wrapper
install_pkg "unrar"                       # RAR archive extraction
install_pkg "fd"                          # Fast file finder (rust alternative to find)
install_pkg "tree"                        # Directory tree visualization
install_pkg "yazi"                        # Terminal file manager
install_pkg "nautilus"                    # GNOME file manager

# --- SYSTEM MONITORING & INFO ---
install_pkg "bat"                         # Enhanced cat with syntax highlighting
install_pkg "btop"                        # System resource monitor (htop alternative)
install_pkg "ugrep"                       # Fast grep alternative
install_pkg "tealdeer"                    # Fast tldr client (command examples)
install_pkg "wiki-tui"                    # Wikipedia terminal interface

# --- PASSWORD & SECURITY ---
install_pkg "bitwarden-cli"               # Password manager CLI
install_pkg "keychain"                    # SSH key management
install_pkg "openssl"                     # Cryptography toolkit
install_pkg "openssh"                     # SSH client/server

# --- DEVELOPMENT & TEXT ---
install_pkg "jq"                          # JSON processor
install_pkg "debugedit"                   # Debug information editor

# --- FONTS ---
install_pkg "ttf-jetbrains-mono-nerd"     # JetBrains Mono with Nerd Font icons
install_pkg "ttf-fira-code"               # Fira Code programming font

# --- MULTIMEDIA ---
install_pkg "mpv"                         # Media player
install_pkg "kodi"                        # Media center application
install_pkg "helvum"                      # PipeWire patchbay/mixer
install_pkg "yt-dlp"                      # YouTube/video downloader
install_pkg "zathura"                      # Lightweight PDF viewer
install_pkg "zathura-pdf-mupdf"           # PDF backend for Zathura

# --- CLIPBOARD & PRODUCTIVITY ---
install_pkg "cliphist"                    # Clipboard history for Wayland

# --- NETWORKING & COMMUNICATION ---
install_pkg "kdeconnect"                  # Device integration (phone/computer sync)
install_pkg "qbittorrent"                 # BitTorrent client

# --- MUSIC ---
install_pkg "spotifyd"                    # Spotify daemon

# --- GAMING ---
install_pkg "steam"                       # Gaming platform
install_pkg "lutris"                      # Gaming management (Wine, emulators)
install_pkg "vulkan-radeon"               # AMD Vulkan graphics drivers
install_pkg "lib32-vulkan-radeon"         # 32-bit AMD Vulkan drivers for games
install_pkg "vulkan-tools"                # Vulkan utilities and diagnostics

# --- VIRTUALIZATION ---
install_pkg "virt-manager"          # GUI for managing VMs
install_pkg "qemu-full"             # Full QEMU virtualization
install_pkg "dnsmasq"               # Lightweight DNS/DHCP for VM networking
install_pkg "ebtables"              # Ethernet bridge filtering (for VM networking)
install_pkg "iptables-nft"          # Network packet filtering

# --- AI/ML ---
# install_pkg "ollama-rocm"                 # Local AI model runner (AMD GPU optimized)

# --- DOCUMENT MANAGEMENT ---
install_pkg "calibre"                     # E-book management
install_pkg "libqalculate"                # Calculator library

# --- SYSTEM TOOLS ---
install_pkg "corectrl"                    # AMD GPU control panel
install_pkg "nwg-dock-hyprland"           # Dock/taskbar for Hyprland

# --- SHELL ENHANCEMENTS ---
install_pkg "zsh-syntax-highlighting"     # Syntax highlighting for zsh
install_pkg "zsh-autosuggestions"         # Auto-suggestions for zsh
install_pkg "zoxide"                      # Smart directory jumper (cd replacement)

# --- APPLICATIONS (EDITORS, BROWSERS, ETC.) ---
install_pkg "obsidian"                    # Note-taking application
install_pkg "gnome-calendar"              # Calendar application

# --- AUR PACKAGES (Third-party/Community) ---
install_aur_pkg "code"                    # Visual Studio Code
install_aur_pkg "cursor-electron"         # AI-powered code editor
install_aur_pkg "dragon-drop"             # Simple drag-and-drop utility
install_aur_pkg "ferdium-nightly-bin"     # Multi-platform messaging app
install_aur_pkg "spotify"                 # Music streaming
install_aur_pkg "spotify-player"          # Terminal Spotify client
install_aur_pkg "sublime-text-4"          # Text editor
install_aur_pkg "helium-browser-bin"      # Privacy-focused web browser (my main)
install_aur_pkg "adw-gtk-theme-git"       # Adwaita GTK theme (development version)
install_aur_pkg "freeoffice"              # Office suite