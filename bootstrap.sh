#!/usr/bin/env bash
set -e

# === CONFIGURATION ===
REPO_NAME="linux"  # <-- Change to your repo name
REPO_URL="https://github.com/tefloon/$REPO_NAME.git"

# === 1. Install git if needed ===
if ! command -v git >/dev/null 2>&1; then
    echo "Installing git..."
    pacman -Sy --noconfirm git
fi

# === 2. Determine username ===
if [[ -n "$SUDO_USER" && "$SUDO_USER" != "root" ]]; then
    USERNAME="$SUDO_USER"
else
    USERNAME=$(ls /home | head -n 1)
fi

USER_HOME="/home/$USERNAME"

# === 3. Clone repo to user's home directory ===
cd "$USER_HOME"
if [[ ! -d "$REPO_NAME" ]]; then
    git clone "$REPO_URL"
else
    echo "Repository $REPO_NAME already exists in $USER_HOME"
fi

# === 4. Set correct ownership and permissions ===
chown -R $USERNAME:$USERNAME "$REPO_NAME"

# Make all scripts executable if they exist
if compgen -G "$REPO_NAME/scripts/*" > /dev/null; then
    chmod +x "$REPO_NAME/scripts/"*
fi
if [[ -f "$REPO_NAME/setup.sh" ]]; then
    chmod +x "$REPO_NAME/setup.sh"
fi

# Make dotfiles and configs readable/writable, not executable
if [[ -d "$REPO_NAME/dotfiles" ]]; then
    find "$REPO_NAME/dotfiles" -type f -exec chmod 644 {} \;
fi
if [[ -d "$REPO_NAME/configs" ]]; then
    find "$REPO_NAME/configs" -type f -exec chmod 644 {} \;
fi

add_fstab_entry() {
    local line="$1"
    if ! grep -qxF "$line" /etc/fstab; then
        echo "$line" | sudo tee -a /etc/fstab > /dev/null
    fi
}

echo "Adding drives to /etc/fstab"
add_fstab_entry "UUID=3ECEEACFCEEA7F11 /mnt/backups ntfs-3g uid=1000,gid=1000,fmask=133,dmask=022 0 0"
add_fstab_entry "UUID=243C543D3C540BE4 /mnt/chmury ntfs-3g uid=1000,gid=1000,fmask=133,dmask=022 0 0"


# === 5. Run the main setup as the user ===
cd "$REPO_NAME"
sudo -u $USERNAME ./setup.sh

# cd "$SCRIPT_DIR"
# CURRENT_STEP_MESSAGE="Ensuring git remote uses SSH"
# status_msg
# current_url=$(git remote get-url origin)
# if [[ "$current_url" != git@github.com:* ]]; then
#     git remote set-url origin "git@github.com:tefloon/linux.git" && status_ok || status_skip
# else
#     status_ok
# fi
