#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(readlink -f "$SCRIPT_DIR/../dotfiles")"
source "$SCRIPT_DIR/status.sh"

# Symlink dotfiles from the dotfiles folder

find "$DOTFILES_DIR" -type f -print0 | while IFS= read -r -d '' src; do

    # Compute the relative path from $DOTFILES_DIR
    relpath="${src#"$DOTFILES_DIR"/}"
    dest="$HOME/$relpath"

    CURRENT_STEP_MESSAGE="Symlinking $relpath"
    status_msg

    # Ensure the parent directory exists
    mkdir -p "$(dirname "$dest")"

    # Remove any existing file/symlink/directory at the destination
    rm -rf "$dest"

    # Create the symlink
    if ln -s "$src" "$dest"; then
        status_ok
    else
        status_skip "Failed to link $src to $dest"
    fi
done
