#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"
source "$SCRIPT_DIR/post-install-scripts/setup-services.sh"
bash "$SCRIPT_DIR/post-install-scripts/setup-default-browser.sh"

CURRENT_STEP_MESSAGE="Setting up default programs"
status_msg
bash "$SCRIPT_DIR/post-install-scripts/set-default-programs.sh"
status_ok

CURRENT_STEP_MESSAGE="Updating desktop database"
status_msg
if update-desktop-database ~/.local/share/applications/ 2>/dev/null; then
    status_ok
else
    status_skip
fi

CURRENT_STEP_MESSAGE="Applying the XDG home folders"
status_msg
rmdir $HOME/Desktop $HOME/Downloads $HOME/Documents $HOME/Templates $HOME/Pictures $HOME/Videos $HOME/Public 
xdg-user-dirs-update
status_ok

echo "Setting up dictionaries..."
bash "$SCRIPT_DIR/post-install-scripts/setup-dictionary.sh"
