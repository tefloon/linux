#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"
source "$SCRIPT_DIR/post-install-scripts/setup-services.sh"
bash "$SCRIPT_DIR/post-install-scripts/setup-default-browser.sh"

CURRENT_STEP_MESSAGE="Setting up default programs"
status_msg
bash "$SCRIPT_DIR/post-install-scripts/set-default-programs.sh"
status_ok

CURRENT_STEP_MESSAGE="Updating desktop database"
status_msg
if update-desktop-database ~/.local/share/applications/ 2>/dev/null; then
    status_ok
else
    status_skip
fi

# The XDG folders themselves are set by the user-dirs.dirs dotfile; the
# symlinked ones come from setup-storage.sh, ~/claude from setup-syncthing.sh
CURRENT_STEP_MESSAGE="Setting up home folders"
status_msg
# Defaults made by xdg-user-dirs at the first login; rmdir only removes empty ones
rmdir "$HOME"/{Desktop,Downloads,Documents,Music,Pictures,Videos,Templates,Public,Projects} 2>/dev/null
mkdir -p "$HOME/games" "$HOME/mnt"
expected=" claude documents downloads games linux mnt music photos projects videos "
unexpected=()
for entry in "$HOME"/*; do
    name="${entry##*/}"
    [[ "$expected" == *" $name "* ]] || unexpected+=("$name")
done
if (( ${#unexpected[@]} )); then
    status_skip "Unexpected in ~ (left alone): ${unexpected[*]}"
else
    status_ok
fi

echo "Setting up dictionaries..."
bash "$SCRIPT_DIR/post-install-scripts/setup-dictionary.sh"
