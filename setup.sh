#!/usr/bin/env bash

# Parse arguments
VM_MODE=0
if [[ "$1" == "--vm" ]]; then
    VM_MODE=1
    echo "Running in VM MODE: no disk mounting will take place."
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/status.sh"

CURRENT_STEP_MESSAGE="Checking for sudo"
status_msg
if ! command -v sudo >/dev/null 2>&1; then
    status_error "sudo is required. Please install sudo and add your user to the wheel group."
fi
status_ok

# Ensure base-devel is installed (needed for yay and AUR)
install_pkg "base-devel"

# Install yay if not present
if ! command -v yay >/dev/null 2>&1; then
    CURRENT_STEP_MESSAGE="Installing yay (AUR helper)"
    status_msg
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay > /dev/null
    makepkg -si --noconfirm
    popd > /dev/null
    rm -rf /tmp/yay
    status_ok
fi

# Install all packages (system and AUR)
source "$SCRIPT_DIR/scripts/install_packages.sh"

CURRENT_STEP_MESSAGE="Setting script permissions"
status_msg
# Make all scripts in bin/ executable
find "$SCRIPT_DIR/bin/" -type f -exec chmod +x {} \;
# Make the crucial uwsm session script executable
if [ -f "$SCRIPT_DIR/dotfiles/.config/uwsm/session.sh" ]; then
    chmod +x "$SCRIPT_DIR/dotfiles/.config/uwsm/session.sh"
fi
status_ok

CURRENT_STEP_MESSAGE="Copying custom scripts"
status_msg
mkdir -p "$HOME/.local/bin"
for script in "$SCRIPT_DIR/bin/"*; do
    [ -e "$script" ] || continue
    ln -sf "$script" "$HOME/.local/bin/"
done
status_ok

# Symlink dotfiles from the dotfiles folder
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

find "$DOTFILES_DIR" -type f | while read -r src; do
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

CURRENT_STEP_MESSAGE="Symlinking /etc/hosts"
status_msg
sudo ln -sf "$SCRIPT_DIR/dotfiles/hosts" /etc/hosts && status_ok || status_error

# CONFIG_SCRIPTS_DIR="$SCRIPT_DIR/scripts/config_scripts"

# for script in "$CONFIG_SCRIPTS_DIR"/*.sh; do
#     [ -e "$script" ] || continue
#     bash "$script" &
# done

ASSETS_DIR="$SCRIPT_DIR/assets"

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

add_fstab_entry() {
    local line="$1"
    if ! grep -qxF "$line" /etc/fstab; then
        echo "$line" | sudo tee -a /etc/fstab > /dev/null
    fi
}

CURRENT_STEP_MESSAGE="Adding drives to /etc/fstab"
if [[ $VM_MODE -eq 1 ]]; then
    status_skip "Script running in VM_MODE"
else
    add_fstab_entry "UUID=3ECEEACFCEEA7F11 /mnt/backups ntfs-3g uid=1000,gid=1000,fmask=133,dmask=022 0 0"
    add_fstab_entry "UUID=243C543D3C540BE4 /mnt/chmury ntfs-3g uid=1000,gid=1000,fmask=133,dmask=022 0 0"
    status_ok
fi

CURRENT_STEP_MESSAGE="Retrieving secrets from Bitwarden"
bash "$SCRIPT_DIR/scripts/retrieve_secrets.sh"
status_ok

echo -e "All done! Restart your machine."
