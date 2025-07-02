#!/usr/bin/env bash

source ./status.sh

# Example usage:

CURRENT_STEP_MESSAGE="Checking for root privileges"
status_msg
if [[ $EUID -ne 0 ]]; then
    status_error "Please run as root (use sudo)"
fi
status_ok

CURRENT_STEP_MESSAGE="TADA!"
status_ok