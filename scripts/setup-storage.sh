#!/usr/bin/env bash
#
# setup-storage.sh: mount the data disk at /mnt/chmury and link the home
# folders that live on it.
#
# The disk is found by its filesystem label, and the fstab line mounts it by
# label too, so no UUID is hard-coded anywhere. Safe to re-run. Never moves
# data: a home folder that already exists as a non-empty directory is
# reported and left alone.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

DISK_LABEL="chmury"
MOUNT_POINT="/mnt/chmury"
FSTAB_LINE="LABEL=$DISK_LABEL   $MOUNT_POINT   ext4   defaults,nofail   0  2"
LINKED_DIRS=(documents downloads music photos videos projects)

CURRENT_STEP_MESSAGE="Looking for the disk labelled $DISK_LABEL"
status_msg
if [[ ! -e "/dev/disk/by-label/$DISK_LABEL" ]]; then
    status_skip "No disk labelled $DISK_LABEL on this machine"
    exit 0
fi
status_ok

CURRENT_STEP_MESSAGE="Adding $MOUNT_POINT to /etc/fstab"
status_msg
if grep -qE "^[^#]*[[:space:]]$MOUNT_POINT[[:space:]]" /etc/fstab; then
    status_skip "Already in fstab"
elif printf '%s\n' "$FSTAB_LINE" | sudo tee -a /etc/fstab >/dev/null; then
    # systemd generates mount units from fstab; make it see the new line
    sudo systemctl daemon-reload
    status_ok
else
    status_error "Could not write /etc/fstab"
fi

CURRENT_STEP_MESSAGE="Mounting $MOUNT_POINT"
status_msg
if mountpoint -q "$MOUNT_POINT"; then
    status_skip "Already mounted"
elif sudo mkdir -p "$MOUNT_POINT" && sudo mount "$MOUNT_POINT"; then
    status_ok
else
    status_error "Could not mount $MOUNT_POINT"
fi

for name in "${LINKED_DIRS[@]}"; do
    target="$MOUNT_POINT/$name"
    link="$HOME/$name"
    CURRENT_STEP_MESSAGE="Linking ~/$name"
    status_msg

    if [[ ! -d "$target" ]]; then
        status_skip "$target does not exist"
        continue
    fi
    if [[ -L "$link" ]]; then
        if [[ "$(readlink "$link")" == "$target" ]]; then
            status_skip "Already linked"
        else
            status_skip "~/$name points to $(readlink "$link"), left alone"
        fi
        continue
    fi
    # An empty directory (e.g. made by xdg-user-dirs) is replaced, anything
    # with content is left for a human to sort out
    if [[ -d "$link" ]] && ! rmdir "$link" 2>/dev/null; then
        status_skip "~/$name is a non-empty directory, left alone"
        continue
    fi
    if [[ -e "$link" ]]; then
        status_skip "~/$name exists and is not a directory, left alone"
        continue
    fi

    if ln -s "$target" "$link"; then
        status_ok
    else
        status_skip "Could not create the link"
    fi
done
