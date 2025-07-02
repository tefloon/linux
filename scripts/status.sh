#!/usr/bin/env bash

STATUS_COL=60

status_msg() {
    printf "%s" "$CURRENT_STEP_MESSAGE... "
}

status_ok() {
    local GREEN='\033[0;32m'
    local NC='\033[0m'
    local padlen=$(( STATUS_COL - ${#CURRENT_STEP_MESSAGE} - 4 ))
    printf "\r%s... %*s[%b  OK   %b]\n" \
        "$CURRENT_STEP_MESSAGE" "$padlen" "" "$GREEN" "$NC"
}

status_error() {
    local RED='\033[0;31m'
    local NC='\033[0m'
    local padlen=$(( STATUS_COL - ${#CURRENT_STEP_MESSAGE} - 4 ))
    printf "\r%s... %*s[%b ERROR %b]\n" \
        "$CURRENT_STEP_MESSAGE" "$padlen" "" "$RED" "$NC"
    if [[ -n "$1" ]]; then
        echo -e "${RED}Error: $1${NC}" >&2
    fi
    exit 1
}

install_pkg() {
    local pkg="$1"
    CURRENT_STEP_MESSAGE="Installing $pkg"
    status_msg
    if pacman -S --noconfirm "$pkg" > /tmp/pacman.log 2>&1; then
        status_ok
    else
        status_error "Failed to install $pkg."
    fi
}

INSTALL_USER="${SUDO_USER:-$USER}"

install_aur_pkg() {
    local pkg="$1"
    CURRENT_STEP_MESSAGE="Installing AUR package $pkg"
    status_msg
    if sudo -u "$INSTALL_USER" yay -S --noconfirm "$pkg" > /tmp/yay.log 2>&1; then
        status_ok
    else
        status_error "Failed to install $pkg."
    fi
}