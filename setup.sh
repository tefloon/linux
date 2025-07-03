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

CURRENT_STEP_MESSAGE="Updating system packages"
status_msg
sudo pacman -Syu --noconfirm > /dev/null 2>&1 || status_error
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
# source "$SCRIPT_DIR/scripts/install_gui.sh"  # Uncomment if needed

CURRENT_STEP_MESSAGE="Copying custom scripts"
status_msg
mkdir -p "$HOME/.local/bin"
for script in "$SCRIPT_DIR/bin/"*; do
    [ -e "$script" ] || continue
    ln -sf "$script" "$HOME/.local/bin/"
done
status_ok

DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
DOTFILES_TO_LINK=(
    ".zshrc"
    ".config/openbox/rc.xml"
    ".ssh/config"
)
for item in "${DOTFILES_TO_LINK[@]}"; do
    CURRENT_STEP_MESSAGE="Symlinking $item"
    status_msg
    src="$DOTFILES_DIR/$item"
    dest="$HOME/$item"
    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    if ln -s "$src" "$dest"; then
        status_ok
    else
        status_skip "Failed to link $src to $dest"
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

echo -e "\nAll done! You may want to restart your shell to use new commands."