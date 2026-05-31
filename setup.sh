#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOG_FILE="/tmp/setup-$(date +%Y%m%d-%H%M%S).log"
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
    if ! git clone https://aur.archlinux.org/yay.git /tmp/yay; then
        status_error "Failed to clone yay repository"
    fi
    pushd /tmp/yay > /dev/null || status_error "Failed to enter yay directory"
    if ! makepkg -si --noconfirm; then
        popd > /dev/null
        rm -rf /tmp/yay
        status_error "Failed to build yay"
    fi
    popd > /dev/null
    rm -rf /tmp/yay
    status_ok
fi

# Run individual setup scripts
echo "=== Installing packages ==="
bash "$SCRIPT_DIR/scripts/install-packages.sh"

echo "=== Setting up custom scripts ==="
bash "$SCRIPT_DIR/scripts/setup-scripts.sh"

echo "=== Setting up dotfiles ==="
bash "$SCRIPT_DIR/scripts/setup-dotfiles.sh"

echo "=== Setting up launch scripts ==="
bash "$SCRIPT_DIR/scripts/setup-launch-scripts.sh"

echo "=== Setting up assets ==="
bash "$SCRIPT_DIR/scripts/setup-assets.sh"

echo "=== Setting up system configurations ==="
bash "$SCRIPT_DIR/scripts/setup-system.sh"

echo "=== Running post-install configuration ==="
bash "$SCRIPT_DIR/scripts/post-install.sh"

# echo "=== Retrieving secrets ==="
# bash "$SCRIPT_DIR/scripts/retrieve-secrets.sh"

status_summary

echo "All done!"
echo "============================"
echo "Next steps:"
echo " -> reboot"
echo " -> sudo tailscale up"
echo " -> run retrieve-secrets.sh"
echo "============================"
