#!/usr/bin/env bash
set -e

# === CONFIGURATION ===
REPO_NAME="your-dotfiles-repo"  # <-- Change to your repo name
REPO_URL="https://github.com/yourusername/$REPO_NAME.git"  # <-- Change to your repo URL

# === 1. Configure Wired Network ===
echo "Configuring wired network..."
interface=$(ip link | awk -F: '/enp/ {print $2; exit}' | xargs)
if [[ -z "$interface" ]]; then
    echo "No wired interface found! Exiting."
    exit 1
fi

cat > /etc/systemd/network/20-wired.network <<EOF
[Match]
Name="$interface"

[Network]
DHCP=yes
EOF

systemctl enable --now systemd-networkd
systemctl enable --now systemd-resolved
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# === 2. Install git if needed ===
if ! command -v git >/dev/null 2>&1; then
    echo "Installing git..."
    pacman -Sy --noconfirm git
fi

# === 3. Clone repo to user's home directory ===
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