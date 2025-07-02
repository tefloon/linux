#!/usr/bin/env bash

install_pkg "xorg-server xorg-apps xorg-xinit xterm"
install_pkg "sddm"
install_pkg "openbox"


CURRENT_STEP_MESSAGE="Enabling sddm"
status_msg
systemctl enable sddm > /dev/null 2>&1 || status_error
status_ok