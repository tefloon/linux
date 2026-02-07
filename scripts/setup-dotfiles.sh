#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(readlink -f "$SCRIPT_DIR/..")"
source "$SCRIPT_DIR/status.sh"

# Stow all packages
CURRENT_STEP_MESSAGE="Stowing dotfiles"
status_msg
cd "$REPO_ROOT" || { status_error "Failed to enter repo root"; }
if stow -R dotfiles -t "$HOME" 2>/dev/null; then
    status_ok
else
    status_skip "Failed to stow dotfiles"
fi
