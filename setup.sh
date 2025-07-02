#!/usr/bin/env bash

status_msg() {
    echo -n "$CURRENT_STEP_MESSAGE... "
}

status_ok() {
    local GREEN='\033[0;32m'
    local NC='\033[0m'
    echo -e "\r$CURRENT_STEP_MESSAGE... [${GREEN}OK${NC}]"
}

status_error() {
    local RED='\033[0;31m'
    local NC='\033[0m'
    echo -e "\r$CURRENT_STEP_MESSAGE... [${RED}ERROR${NC}]"
    if [[ -n "$1" ]]; then
        echo -e "${RED}Error: $1${NC}" >&2
    fi
    exit 1
}

CURRENT_STEP_MESSAGE="Checking for root privileges"
status_msg
if [[ $EUID -ne 0 ]]; then
    status_error "Please run as root (use sudo)"
fi

CURRENT_STEP_MESSAGE="Configuring Ethernet interfaces"
status_msg
interface=$(ip link | awk -F: '/enp/ {print $2; exit}' | xargs)
if [[ -z "$interface" ]]; then
    status_error "No wired interface found!"
fi

echo "Your interface is: $interface"

cat > /etc/systemd/network/20-wired.network <<EOF
[Match]
Name="$interface"

[Network]
DHCP=yes
EOF

systemctl enable --now systemd-networkd || status_error "Failed to enable systemd-networkd"
systemctl enable --now systemd-resolved || status_error "Failed to enable systemd-resolved"
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || status_error "Failed to link resolv.conf"

status_ok