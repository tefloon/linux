#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

CURRENT_STEP_MESSAGE="Symlinking /etc/hosts"
status_msg
sudo ln -sf "$SCRIPT_DIR/../dotfiles/hosts" /etc/hosts && status_ok || status_error