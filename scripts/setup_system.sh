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
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
status_ok

CURRENT_STEP_MESSAGE="Setting cursor fallback for X11"
status_msg
    sudo ln -sf $HOME/.local/share/icons/Bibata-Modern-Classic $HOME/.local/share/icons/default
    sudo ln -sf /usr/share/icons/Bibata-Modern-Classic /usr/share/icons/default
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'
status_ok

CURRENT_STEP_MESSAGE="Symlinking /etc/hosts"
status_msg
sudo ln -sf "$HOSTS_FILE" /etc/hosts && status_ok || status_skip