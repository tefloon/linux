#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH_SCRIPTS_DIR="$(readlink -f "$SCRIPT_DIR/../launch-scripts")"
source "$SCRIPT_DIR/status.sh"

CURRENT_STEP_MESSAGE="Symlinking launch scripts"
status_msg
mkdir -p "$HOME/.local/share"
ln -sf "$LAUNCH_SCRIPTS_DIR" "$HOME/.local/share/launch-scripts"
status_ok