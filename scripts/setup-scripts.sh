#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$(readlink -f "$SCRIPT_DIR/../bin")"
source "$SCRIPT_DIR/status.sh"

CURRENT_STEP_MESSAGE="Setting script permissions"
status_msg
find "$BIN_DIR" -type f -exec chmod +x {} \;
status_ok

CURRENT_STEP_MESSAGE="Copying custom scripts"
status_msg
mkdir -p "$HOME/.local/bin"
for script in "$BIN_DIR"/*; do
    [ -e "$script" ] || continue
    ln -sf "$script" "$HOME/.local/bin/"
done
status_ok