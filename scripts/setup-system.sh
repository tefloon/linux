#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTS_FILE="$(readlink -f "$SCRIPT_DIR/../dotfiles/hosts")"
source "$SCRIPT_DIR/status.sh"

CURRENT_STEP_MESSAGE="Setting zsh as default shell"
status_msg
if [[ "$SHELL" != */zsh ]]; then
    if chsh -s /usr/bin/zsh; then
        status_ok
    else
        status_skip "Failed to change shell to zsh"
    fi
else
    status_skip "Already using zsh"
fi

CURRENT_STEP_MESSAGE="Setting system dark theme preference"
status_msg
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null
    status_ok
else
    status_skip "gsettings not available"
fi

CURRENT_STEP_MESSAGE="Setting cursor fallback for X11"
status_msg
if [[ -d "$HOME/.local/share/icons/Bibata-Modern-Classic" ]]; then
    ln -sf "$HOME/.local/share/icons/Bibata-Modern-Classic" "$HOME/.local/share/icons/default"
    sudo ln -sf /usr/share/icons/Bibata-Modern-Classic /usr/share/icons/default 2>/dev/null
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null
    status_ok
else
    status_skip "Bibata cursor theme not found"
fi

CURRENT_STEP_MESSAGE="Symlinking /etc/hosts"
status_msg
sudo ln -sf "$HOSTS_FILE" /etc/hosts && status_ok || status_skip