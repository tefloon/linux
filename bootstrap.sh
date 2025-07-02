#!/usr/bin/env bash
set -e

# === CONFIGURATION ===
REPO_NAME="linux"  # <-- Change to your repo name
REPO_URL="https://github.com/tefloon/$REPO_NAME.git"  # <-- Change to your repo URL

# === 1. Install git if needed ===
if ! command -v git >/dev/null 2>&1; then
    echo "Installing git..."
    pacman -Sy --noconfirm git
fi

# === 2. Clone repo to user's home directory ===
USERNAME=$(ls /home | head -n 1)  # Or set manually if needed
cd /home/$USERNAME
git clone "$REPO_URL"

# === 4. Set correct ownership and permissions ===
chown -R $USERNAME:$USERNAME "$REPO_NAME"

# Make all scripts executable
chmod +x "$REPO_NAME/scripts/"*
chmod +x "$REPO_NAME/setup.sh"

# Make dotfiles and configs readable/writable, not executable
find "$REPO_NAME/dotfiles" -type f -exec chmod 644 {} \;
find "$REPO_NAME/configs" -type f -exec chmod 644 {} \;

# === 5. Run the main setup as the user ===
cd "$REPO_NAME"
sudo -u $USERNAME ./setup.sh