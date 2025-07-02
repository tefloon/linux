#!/usr/bin/env bash

source ./scripts/status.sh

# Example usage:
CURRENT_STEP_MESSAGE="Checking for root privileges"
status_msg
if [[ $EUID -ne 0 ]]; then
    status_error "Please run as root (use sudo)"
fi
status_ok

# Update
CURRENT_STEP_MESSAGE="Updating packages"
status_msg
pacman -S --noconfirm $pkg > /dev/null 2>&1 || status_error
status_ok

source ./scripts/setup_shell_utils.sh
source ./scripts/setup_gui.sh
