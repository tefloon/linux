#!/usr/bin/env bash

SUBSCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SUBSCRIPT_DIR/../status.sh"

REPO_URL="https://github.com/tefloon/dictionary"
SRC_DIR="$HOME/.local/src"
REPO_DIR="$SRC_DIR/dictionary"
BIN_DIR="$HOME/.local/bin"

# --- Dependencies -------------------------------------------------------
check_command() {
    local cmd="$1"
    CURRENT_STEP_MESSAGE="Checking for $cmd"
    status_msg
    if command -v "$cmd" >/dev/null 2>&1; then
        status_ok
    else
        status_error "$cmd is required but not installed"
    fi
}

check_command "git"
check_command "python3"

# --- Directories --------------------------------------------------------
CURRENT_STEP_MESSAGE="Ensuring directories exist"
status_msg
if mkdir -p "$SRC_DIR" "$BIN_DIR"; then
    status_ok
else
    status_error "Could not create target directories"
fi

# --- Clone or update ----------------------------------------------------
if [[ -d "$REPO_DIR/.git" ]]; then
    CURRENT_STEP_MESSAGE="Updating dictionary repo"
    status_msg
    if git -C "$REPO_DIR" pull --ff-only >>"$LOG_FILE" 2>&1; then
        status_ok
    else
        status_skip "Could not fast-forward $REPO_DIR, keeping local copy"
    fi
else
    CURRENT_STEP_MESSAGE="Cloning dictionary repo"
    status_msg
    if git clone "$REPO_URL" "$REPO_DIR" >>"$LOG_FILE" 2>&1; then
        status_ok
    else
        status_error "git clone failed - see $LOG_FILE"
    fi
fi

# --- Build the dictionary DB --------------------------------------------
# setup-dict.sh downloads ~700MB and imports it, so let its output through
# instead of hiding it behind a spinnerless status line.
SETUP_SCRIPT="$REPO_DIR/scripts/setup-dict.sh"

CURRENT_STEP_MESSAGE="Building dict-pl database"
if [[ ! -f "$SETUP_SCRIPT" ]]; then
    status_msg
    status_error "setup-dict.sh not found at $SETUP_SCRIPT"
fi

echo "Running setup-dict.sh..."
chmod +x "$SETUP_SCRIPT"
set -o pipefail
(cd "$REPO_DIR" && ./scripts/setup-dict.sh) 2>&1 | tee -a "$LOG_FILE"
setup_rc=$?
set +o pipefail

status_msg
if (( setup_rc == 0 )); then
    status_ok
else
    status_error "setup-dict.sh failed - see $LOG_FILE"
fi

# --- Symlink the CLI ----------------------------------------------------
CURRENT_STEP_MESSAGE="Linking dict-pl into $BIN_DIR"
status_msg
if [[ ! -f "$REPO_DIR/dict-pl" ]]; then
    status_error "dict-pl not found in $REPO_DIR"
fi
chmod +x "$REPO_DIR/dict-pl"
if ln -sfn "$REPO_DIR/dict-pl" "$BIN_DIR/dict-pl"; then
    status_ok
else
    status_error "Could not symlink dict-pl into $BIN_DIR"
fi

# --- PATH sanity check --------------------------------------------------
CURRENT_STEP_MESSAGE="Checking $BIN_DIR is on PATH"
status_msg
case ":$PATH:" in
    *":$BIN_DIR:"*) status_ok ;;
    *) status_skip "$BIN_DIR is not on your PATH" ;;
esac

echo ""
echo "Note: aliases 'ten' / 'tpl' are not set by this script - add them to your"
echo "      shell rc if you want them:"
echo "        alias ten='dict-pl en'"
echo "        alias tpl='dict-pl pl'"
