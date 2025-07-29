#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

ASSETS_DIR="$SCRIPT_DIR/../assets"

# Extract archives
# Find only files with common archive extensions.
# The -iname flag is for case-insensitive matching (e.g., .zip and .ZIP).
# The parentheses \( ... \) are crucial for grouping the "-o" (OR) conditions.
find "$ASSETS_DIR" -type f \( \
     -iname "*.zip"    -o \
     -iname "*.tar.gz" -o \
     -iname "*.tgz"    -o \
     -iname "*.tar.bz2" -o \
     -iname "*.tbz2"   -o \
     -iname "*.tar.xz" -o \
     -iname "*.txz"    -o \
     -iname "*.rar"    -o \
     -iname "*.7z"      \
\) -print0 | while IFS= read -r -d '' src; do
    # Compute the path relative to the assets directory
    relpath="${src#$ASSETS_DIR/}"

    # Determine the destination directory for extraction
    dest_dir="$HOME/.local/share/$(dirname "$relpath")"

    CURRENT_STEP_MESSAGE="Extracting '$relpath'"
    status_msg

    # Ensure the destination directory exists
    mkdir -p "$dest_dir"

    # Extract the archive
    if atool -X "$dest_dir" "$src"; then
        status_ok
    else
        status_skip
    fi
done

# Symlink images
# Finds all image files and symlinks them to their relative folder in $HOME/.local/share/
# so /assets/wallpaper/image.png will be symlinked to $HOME/.local/share/wallpaper/image.png
find "$ASSETS_DIR" -type f \( \
     -iname "*.png"    -o \
     -iname "*.jpg"    -o \
     -iname "*.jpeg"   -o \
     -iname "*.webp"   \
\) -print0 | while IFS= read -r -d '' src; do
    # Compute the path relative to the assets directory
    relpath="${src#$ASSETS_DIR/}"

    # Determine the destination directory for extraction
    dest="$HOME/.local/share/$relpath"  # Better XDG compliance

    CURRENT_STEP_MESSAGE="Symlinking '$relpath'"
    status_msg

    # Ensure the destination directory exists
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