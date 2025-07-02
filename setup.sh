#!/usr/bin/env bash

source ./status.sh

# Example usage:

CURRENT_STEP_MESSAGE="Checking for root privileges"
status_msg
if [[ $EUID -ne 0 ]]; then
    status_error "Please run as root (use sudo)"
fi
status_ok

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