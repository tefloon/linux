#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"
source "$SCRIPT_DIR/post-install-scripts/setup_services.sh"
source "$SCRIPT_DIR/post-install-scripts/setup_default_browser.sh"

CURRENT_STEP_MESSAGE="Setting up default programs"
status_msg
source "$SCRIPT_DIR/post-install-scripts/set-default-programs.sh"
status_ok

CURRENT_STEP_MESSAGE="Updating desktop database"
status_msg
update-desktop-database ~/.local/share/applications/ 2>/dev/null || status_skip
status_ok