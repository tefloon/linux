#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

# Symlink dotfiles from the dotfiles folder
DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"

find "$DOTFILES_DIR" -type f | while read -r src; do

    # if [[ "$relpath" == "Packages/User" ]]; then
    #     ln -s "$src" "$dest"
    #     continue
    # fi

    # Compute the relative path from $DOTFILES_DIR
    relpath="${src#$DOTFILES_DIR/}"
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