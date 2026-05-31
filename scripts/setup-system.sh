#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(readlink -f "$SCRIPT_DIR/..")"
SYSTEM_CONFIGS="$REPO_ROOT/system-configs"
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

CURRENT_STEP_MESSAGE="Copying system configs to /etc/"
status_msg
if [[ -d "$SYSTEM_CONFIGS" ]]; then
    sudo cp -r "$SYSTEM_CONFIGS"/* /etc/
    status_ok
else
    status_skip "No system-configs directory found"
fi
