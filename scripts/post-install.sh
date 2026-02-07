#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"
source "$SCRIPT_DIR/post-install-scripts/setup-services.sh"
source "$SCRIPT_DIR/post-install-scripts/setup-default-browser.sh"

CURRENT_STEP_MESSAGE="Setting up default programs"
status_msg
source "$SCRIPT_DIR/post-install-scripts/set-default-programs.sh"
status_ok

CURRENT_STEP_MESSAGE="Updating desktop database"
status_msg
if update-desktop-database ~/.local/share/applications/ 2>/dev/null; then
    status_ok
else
    status_skip
fi