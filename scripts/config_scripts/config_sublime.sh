#!/usr/bin/env bash

set -e

CURRENT_STEP_MESSAGE="Checking for Sublime Text installation"
status_msg
command -v subl > /dev/null 2>&1 || status_error "Sublime Text is not installed."
status_ok

# 2. Set up paths
SUBLIME_DIR="$HOME/.config/sublime-text"
INSTALLED_PACKAGES="$SUBLIME_DIR/Installed Packages"
USER_PACKAGES="$SUBLIME_DIR/Packages/User"
PACKAGE_CONTROL="$INSTALLED_PACKAGES/Package Control.sublime-package"
SETTINGS="$USER_PACKAGES/Package Control.sublime-settings"
PREFS="$USER_PACKAGES/Preferences.sublime-settings"

# 3. Install Package Control
CURRENT_STEP_MESSAGE="Installing Sublime Text Package Control"
status_msg
if [ ! -f "$PACKAGE_CONTROL" ]; then
    mkdir -p "$INSTALLED_PACKAGES"
    if ! command -v wget > /dev/null 2>&1; then
        status_error "wget is not installed."
    fi
    wget -O "$PACKAGE_CONTROL" \
        "https://packagecontrol.io/Package%20Control.sublime-package"
fi
status_ok

# 4. Install Enki Theme
CURRENT_STEP_MESSAGE="Installing Enki Theme"
status_msg
mkdir -p "$USER_PACKAGES"
if [ ! -f "$SETTINGS" ]; then
    echo '{ "installed_packages": ["Enki Theme"] }' > "$SETTINGS"
else
    grep -q "Enki Theme" "$SETTINGS" || \
    sed -i 's/"installed_packages": \[/"installed_packages": \["Enki Theme", /' "$SETTINGS"
fi
status_ok

# 5. Set theme and color scheme
CURRENT_STEP_MESSAGE="Setting the theme and color scheme"
status_msg
cat > "$PREFS" <<EOF
{
    "theme": "Enki.sublime-theme",
    "color_scheme": "Packages/Enki Theme/Tokyo Night.sublime-color-scheme"
}
EOF
status_ok