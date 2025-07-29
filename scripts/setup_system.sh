#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

CURRENT_STEP_MESSAGE="Symlinking /etc/hosts"
status_msg
sudo ln -sf "$SCRIPT_DIR/../dotfiles/hosts" /etc/hosts && status_ok || status_error