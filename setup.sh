#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/status.sh"

CURRENT_STEP_MESSAGE="Checking for sudo"
status_msg
if ! command -v sudo >/dev/null 2>&1; then
    status_error "sudo is required. Please install sudo and add your user to the wheel group."
fi
status_ok

# Ensure base-devel is installed (needed for yay and AUR)
CURRENT_STEP_MESSAGE="Installing base-devel"
status_msg
if sudo pacman -S --noconfirm --needed base-devel > /tmp/pacman.log 2>&1; then
    status_ok
else
    status_skip "Failed to install base-devel."
fi

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

# Run individual setup scripts
echo "=== Installing packages ==="
source "$SCRIPT_DIR/scripts/install_packages.sh"

echo "=== Setting up shell ==="
bash "$SCRIPT_DIR/scripts/setup_shell.sh"

echo "=== Setting up custom scripts ==="
bash "$SCRIPT_DIR/scripts/setup_scripts.sh"

echo "=== Setting up dotfiles ==="
bash "$SCRIPT_DIR/scripts/setup_dotfiles.sh"

echo "=== Setting up launch scripts ==="
bash "$SCRIPT_DIR/scripts/setup_launch_scripts.sh"

echo "=== Setting up assets ==="
bash "$SCRIPT_DIR/scripts/setup_assets.sh"

echo "=== Setting up system configurations ==="
bash "$SCRIPT_DIR/scripts/setup_system.sh"

echo "=== Running post-install configuration ==="
bash "$SCRIPT_DIR/scripts/post-install.sh"

echo "=== Retrieving secrets ==="
bash "$SCRIPT_DIR/scripts/retrieve_secrets.sh"

echo -e "All done!"