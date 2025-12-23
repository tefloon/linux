#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(readlink -f "$SCRIPT_DIR/../dotfiles")"
source "$SCRIPT_DIR/status.sh"

# Stow all packages
CURRENT_STEP_MESSAGE="Stowing dotfiles"
status_msg
cd "$DOTFILES_DIR"
if stow -R . -t "$HOME" 2>/dev/null; then
    status_ok
else
    status_skip "Failed to stow dotfiles"
fi