#!/usr/bin/env bash

SUBSCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SUBSCRIPT_DIR/../status.sh"

# Prompt for sudo password upfront (silent, no output mess)
sudo -v

# Enable and start system services
enable_service() {
    local service="$1"
    CURRENT_STEP_MESSAGE="Enabling $service"
    status_msg
    if sudo systemctl enable --now "$service" 2>/dev/null; then
        status_ok
    else
        status_skip "Service $service not found or already enabled"
    fi
}

# Core networking & system services
enable_service "NetworkManager"        # Network management
enable_service "systemd-timesyncd"     # Time synchronization
enable_service "tailscaled"            # Tailscale VPN

# Hardware support
# enable_service "bluetooth"             # Bluetooth

# Remote access
# enable_service "sshd"                  # SSH server

# Virtualization
enable_service "libvirtd"              # VM management

# Optional services (uncomment if needed)
# enable_service "ufw"                 # Firewall
# enable_service "cups"                # Printing
# enable_service "avahi-daemon"        # Local network discovery
# enable_service "ollama"              # Local AI models

# Add user to groups
add_to_group() {
    local group="$1"
    CURRENT_STEP_MESSAGE="Adding $USER to $group group"
    status_msg
    if sudo usermod -aG "$group" "$USER" 2>/dev/null; then
        status_ok
    else
        status_skip "Group $group not found or user already in group"
    fi
}

add_to_group "libvirt"                 # VM management without sudo

echo ""
echo "Note: You may need to log out and back in for group changes to take effect."