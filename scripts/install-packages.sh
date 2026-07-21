#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

CURRENT_STEP_MESSAGE="Enabling multilib"
status_msg

PACMAN_CONF="/etc/pacman.conf"
# Uncomment [multilib] and its Include line if commented
sudo sed -i '/^\s*#\s*\[multilib\]/, /^\s*#\s*Include = \/etc\/pacman.d\/mirrorlist/ {
    s/^\s*#\s*\(\[multilib\]\)/\1/
    s/^\s*#\s*\(Include = \/etc\/pacman.d\/mirrorlist\)/\1/
}' "$PACMAN_CONF"
status_ok

install_pkg() {
    local pkg="$1"
    CURRENT_STEP_MESSAGE="Installing $pkg"
    status_msg
    if sudo pacman -S --noconfirm --needed $pkg >> /tmp/pacman.log 2>&1; then
        status_ok
    else
        status_skip "Failed to install $pkg."
    fi
}

install_aur_pkg() {
    local pkg="$1"
    CURRENT_STEP_MESSAGE="Installing AUR package $pkg"
    status_msg
    if yay -S --noconfirm --needed $pkg >> /tmp/yay.log 2>&1; then
        status_ok
    else
        status_skip "Failed to install $pkg."
    fi
}

# --- CORE UTILITIES ---
install_pkg "curl"                        # HTTP client (for Oh-My-Zsh download)
install_pkg "git"                         # Version control (for yay, Powerlevel10k)
install_pkg "desktop-file-utils"          # For update-desktop-database
install_pkg "sddm"                        # Login manager/launcher
install_pkg "uwsm"                        # Wayland session manager

# --- HYPRLAND CORE ---
install_pkg "hyprland"                    # Wayland compositor (window manager)
install_pkg "hyprpaper"                   # Wallpaper daemon for Hyprland
install_pkg "waybar"                      # System bar
install_pkg "wofi"                        # Dropdown menus
install_pkg "mako"                        # Notification daemon for Wayland
install_pkg "libnotify"                   # Notification daemon for Wayland
install_pkg "swaylock"                    # Screen locker for Wayland

# --- WAYLAND UTILITIES ---
install_pkg "wl-clipboard"                # Clipboard utilities for Wayland
install_pkg "grim"                        # Wayland screenshot tool
install_pkg "slurp"                       # Select region utility
install_pkg "cliphist"                    # Clipboard manager
install_pkg "polkit-gnome"                # Visual password input for elevated privileges
install_pkg "xdg-desktop-portal-hyprland" # Desktop portal for Hyprland (file dialogs, etc.)
install_pkg "xdg-desktop-portal-gtk"      # Desktop portal for Hyprland (file dialogs, etc.)
install_pkg "xdg-desktop-portal"          # Desktop portal for Hyprland (file dialogs, etc.)
install_pkg "qt5-wayland"                 # Qt5 Wayland support
install_pkg "qt6-wayland"                 # Qt6 Wayland support
install_pkg "qt5ct"                       # Qt5 configuration tool
install_pkg "qt6ct"                       # Qt6 configuration tool
install_pkg "xorg-xwayland"               # X11 compatibility layer for Wayland
install_pkg "brightnessctl"               # Screen brightness control
install_pkg "upower"                      # Battery/power management info
install_pkg "papirus-icon-theme"          # GTK icon theme

# --- TERMINALS & SHELLS ---
install_pkg "alacritty"                   # GPU-accelerated terminal emulator
install_pkg "foot"                        # Modern, super-fast CPU-only terminal
install_pkg "starship"                    # Modern, fast terminal prompt
install_pkg "nushell"                     # A data-oriented shell
install_pkg "zsh-syntax-highlighting"     # Syntax highlighting for zsh
install_pkg "zsh-autosuggestions"         # Auto-suggestions for zsh

# --- CLI PRODUCTIVITY TOOLS ---
install_pkg "tesseract"                   # OCR engine (for bin/ocr script)
install_pkg "tesseract-data-eng"          # English OCR data
install_pkg "tesseract-data-pol"          # Polish OCR data
install_pkg "eza"                         # Colored file/dir lists with icons
install_pkg "bat"                         # Nicely formatted file contents
install_pkg "zoxide"                      # Last visited directories shortcut
install_pkg "tealdeer"                    # Quick help for packages and commands
install_pkg "fzf"                         # Fuzzy finder. Integrates with everything
install_pkg "git-delta"                   # Comparing diffs
install_pkg "sd"                          # Find and replace string in files
install_pkg "dust"                        # Shows which dirs / files takes most space
install_pkg "duf"                         # Lists disk usage and free space
install_pkg "procs"                       # Processes monitor
install_pkg "fd"                          # Find files
install_pkg "sd"                          # Modern replacement for sed
install_pkg "ugrep"                       # Search files for strings
install_pkg "translate-shell"             # Terminal translator
install_pkg "urban-cli-bin"               # Urban dictionary CLI

# --- PYTHON PACKAGES ---
install_pkg "python-astral"               # Needed for the moon phase script
install_pkg "python-tiktoken"             # Needed for token counting script
install_pkg "python-youtube-transcript-api" # Needed for transcripts 

# --- FILE MANAGEMENT & NAVIGATION ---
install_pkg "atool"                       # Archive extraction/creation wrapper
install_pkg "unrar"                       # RAR archive extraction
install_pkg "tree"                        # Directory tree visualization
install_pkg "yazi"                        # Terminal file manager
install_pkg "nautilus"                    # File manager

# --- FILE TRANSFER & ENCRYPTION ---
install_pkg "age"                         # Simpler digital signing
install_pkg "croc"                        # Send large file p2p

# --- SYSTEM MONITORING & DIAGNOSTICS ---
install_pkg "btop"                        # Fancy system resources monitor
install_pkg "wiki-tui"                    # Wikipedia terminal interface
install_pkg "hwinfo"                      # Hardware information
install_pkg "fastfetch"                   # Display system info
install_pkg "hyperfine"                   # Benchmark scripts / code

# --- SECURITY & PRIVACY ---
install_pkg "gnupg"                       # GPG encryption (for retrieve-secrets.sh)
install_pkg "bitwarden-cli"               # Password manager CLI
install_pkg "openssl"                     # Cryptography toolkit
install_pkg "openssh"                     # SSH client/server
install_pkg "sshfs"                       # SSH filesystem
install_pkg "keychain"                    # Front to ssh-agent
install_pkg "tailscale"                   # Zero-trust VPN

# --- DEVELOPMENT TOOLS ---
install_pkg "jq"                          # JSON manipulation
install_pkg "debugedit"                   # Debug information editor
install_pkg "helix"                       # NeoVim-like text editor
install_pkg "micro"                       # Simple but sane text editor
install_pkg "lazygit"                     # Git management tool

# --- FONTS ---
install_pkg "ttf-jetbrains-mono-nerd"     # JetBrains Mono with Nerd Font icons
install_pkg "ttf-fira-code"               # Fira Code programming font

# --- MULTIMEDIA & VIEWERS ---
install_pkg "mpv"                         # Video player
install_pkg "kodi"                        # Media center application
install_pkg "helvum"                      # PipeWire patchbay/mixer
install_pkg "yt-dlp"                      # YouTube/video downloader
install_pkg "zathura"                     # Lightweight PDF viewer
install_pkg "zathura-pdf-mupdf"           # PDF backend for Zathura
install_pkg "imv"                         # Image viewer
install_pkg "loupe"                       # GNOME Image viewer
install_pkg "sox"                         # GNOME Image viewer
install_pkg "ffmpeg"                       # GNOME Image viewer

# --- NETWORKING & CONNECTIVITY ---
install_pkg "qbittorrent"                 # BitTorrent client
install_pkg "syncthing"                   # Self-hosted data syncthings
install_aur_pkg "ookla-speedtest-bin"     # Network speed tester
install_pkg "nm-connection-editor"        # GUI network connection editor

# --- MUSIC ---
install_pkg "spotifyd"                    # Spotify daemon

# --- PRODUCTIVITY APPLICATIONS ---
install_pkg "libreoffice-fresh"           # Office suite
install_aur_pkg "obsidian"                # Note-taking application
install_pkg "calibre"                     # E-book management
install_pkg "libqalculate"                # Calculator library

# --- CREATIVE APPLICATIONS ---
install_pkg "krita"                       # Full-fledged raster image editor
install_pkg "obs-studio"                  # Video streaming software

# --- GAMING ---
install_pkg "steam"                       # Gaming platform
install_pkg "vulkan-radeon"               # AMD Vulkan graphics drivers
install_pkg "lib32-vulkan-radeon"         # 32-bit AMD Vulkan drivers for games
install_pkg "vulkan-tools"                # Vulkan utilities and diagnostics

# --- VIRTUALIZATION ---
install_pkg "virt-manager"                # GUI for managing VMs
install_pkg "qemu-full"                   # Virtual machines
install_pkg "dnsmasq"                     # Lightweight DNS/DHCP for VM networking
install_pkg "ebtables"                    # Ethernet bridge filtering (for VM networking)
install_pkg "iptables-nft"                # Network packet filtering

# --- SYSTEM TOOLS ---
install_pkg "corectrl"                    # AMD GPU control panel

# --- AUR PACKAGES (Third-party/Community) ---
install_aur_pkg "code"                    # Visual Studio Code
install_aur_pkg "tmatrix"                 # Matrix-like screensaver
install_aur_pkg "dragon-drop"             # Creates a widget to drag files from
install_aur_pkg "ferdium-nightly-bin"     # Multi-platform messaging app
install_aur_pkg "spotify"                 # Music streaming
install_aur_pkg "spotify-player"          # Terminal Spotify client
install_aur_pkg "sublime-text-4"          # GUI text editor
install_aur_pkg "helium-browser-bin"      # Fast, minimal, private, Chrome-based browser
install_aur_pkg "adw-gtk-theme-git"       # Adwaita GTK theme (development version)
install_aur_pkg "hyprpicker"              # Wayland color picker utility
install_aur_pkg "wlogout"                 # Wayland logout utility
install_aur_pkg "rustdesk-bin"            # Remote system control utility
install_aur_pkg "satty"                   # Screenshot annotation
install_aur_pkg "beyondallreason-appimage"  # Best game ever
install_aur_pkg "fzf-tab-git"
