#!/usr/bin/env bash

# Get the absolute path to the directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions to track progress/errors
source "$SCRIPT_DIR/scripts/status.sh"

CURRENT_STEP_MESSAGE="Checking for root privileges"
status_msg
if [[ $EUID -ne 0 ]]; then
    status_error "Please run as root (use sudo)"
    exit 1
fi
status_ok

# --- Define user variables early ---
USERNAME="${SUDO_USER:-$USER}"
USER_HOME="/home/$USERNAME"

CURRENT_STEP_MESSAGE="Updating packages"
status_msg
pacman -Syu --noconfirm > /dev/null 2>&1 || status_error
status_ok

if ! command -v yay >/dev/null 2>&1; then
    CURRENT_STEP_MESSAGE="Installing yay (AUR helper)"
    status_msg
    sudo -u "$USERNAME" bash -c '
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
    ' || status_error "Failed to install yay."
    rm -rf /tmp/yay
    status_ok
fi

source "$SCRIPT_DIR/scripts/install_packages.sh"
# source "$SCRIPT_DIR/scripts/install_gui.sh"  # <-- Needed only with install on pure Arch

CURRENT_STEP_MESSAGE="Copying custom scripts"
status_msg
sudo -u "$USERNAME" mkdir -p "$USER_HOME/.local/bin"
for script in "$SCRIPT_DIR/bin/"*; do
    [ -e "$script" ] || continue
    sudo -u "$USERNAME" ln -sf "$script" "$USER_HOME/.local/bin/"
done
status_ok

CURRENT_STEP_MESSAGE="Symlinking selected dotfiles and config folders"
status_msg

DOTFILES_TO_LINK=(
    ".zshrc"
    ".config/openbox/rc.xml"
    ".ssh/config"
)
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

for item in "${DOTFILES_TO_LINK[@]}"; do
    src="$DOTFILES_DIR/$item"
    dest="$USER_HOME/$item"
    sudo -u "$USERNAME" mkdir -p "$(dirname "$dest")"
    sudo -u "$USERNAME" rm -rf "$dest"
    sudo -u "$USERNAME" ln -s "$src" "$dest" || status_error "Failed to link $src to $dest"
done
status_ok

add_fstab_entry() {
    local line="$1"
    grep -qxF "$line" /etc/fstab || echo "$line" | sudo tee -a /etc/fstab > /dev/null
}

CURRENT_STEP_MESSAGE="Adding drives to /etc/fstab"
add_fstab_entry "UUID=3ECEEACFCEEA7F11 /mnt/backups ntfs-3g uid=1000,gid=1000,fmask=133,dmask=022 0 0"
add_fstab_entry "UUID=243C543D3C540BE4 /mnt/chmury ntfs-3g uid=1000,gid=1000,fmask=133,dmask=022 0 0"
status_ok

CURRENT_STEP_MESSAGE="Retrieving secrets from Bitwarden"
sudo -u "$USERNAME" env HOME="$USER_HOME" bash "$SCRIPT_DIR/scripts/retrieve_secrets.sh"
status_ok

echo -e "\nAll done! You may want to restart your shell to use new commands."