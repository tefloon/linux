#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

TEST_MODE=0
if [[ "$1" == "--test" ]]; then
    TEST_MODE=1
    echo "Running in TEST MODE: secrets will NOT be written to disk."
fi

CURRENT_STEP_MESSAGE="Checking for Bitwarden CLI"
status_msg
command -v bw >/dev/null || status_error
status_ok

CURRENT_STEP_MESSAGE="Checking for jq CLI"
status_msg
command -v jq >/dev/null || status_error
status_ok


CURRENT_STEP_MESSAGE="Checking status of BW authentication"
status_msg
BW_STATUS=$(bw status | jq -r .status)

if [[ "$BW_STATUS" == "unauthenticated" ]]; then
    echo "\nLogging in to Bitwarden..."
    bw login
    BW_STATUS=$(bw status | jq -r .status)
fi

if [[ "$BW_STATUS" == "locked" ]]; then
    echo "\nUnlocking Bitwarden vault..."
    BW_SESSION=$(bw unlock --raw)
elif [[ "$BW_STATUS" == "unlocked" ]]; then
    # Try to get session from environment, or unlock again if not set
    if [[ -z "$BW_SESSION" ]]; then
        BW_SESSION=$(bw unlock --raw)
    fi
else
    status_error "Unknown Bitwarden status"
fi

# Retrieve the secret from the note field
SPOTIPY_CLIENT_SECRET=$(bw get item spotipy_secret --session "$BW_SESSION" | jq -r '.notes')

if [[ $TEST_MODE -eq 1 ]]; then
    echo "SPOTIPY_CLIENT_SECRET='$SPOTIPY_CLIENT_SECRET'"
else
    echo "export SPOTIPY_CLIENT_SECRET='$SPOTIPY_CLIENT_SECRET'" >> "$HOME/.zsh_secrets"
fi

ITEM_JSON=$(bw get item "Raspberry Pi" --session "$BW_SESSION")

PRIVATE_KEY=$(echo "$ITEM_JSON" | jq -r '.sshKey.privateKey')
PUBLIC_KEY=$(echo "$ITEM_JSON" | jq -r '.sshKey.publicKey')

if [[ $TEST_MODE -eq 1 ]]; then
    echo "Raspberry Pi PRIVATE_KEY:"
    echo "$PRIVATE_KEY"
    echo "Raspberry Pi PUBLIC_KEY:"
    echo "$PUBLIC_KEY"
else
    mkdir -p ~/.ssh
    echo "$PRIVATE_KEY" > ~/.ssh/id_ed25519_pi
    echo "$PUBLIC_KEY" > ~/.ssh/id_ed25519_pi.pub
    chmod 600 ~/.ssh/id_ed25519_pi
    chmod 644 ~/.ssh/id_ed25519_pi.pub
fi

ITEM_JSON=$(bw get item "Github_ssh" --session "$BW_SESSION")

PRIVATE_KEY=$(echo "$ITEM_JSON" | jq -r '.sshKey.privateKey')
PUBLIC_KEY=$(echo "$ITEM_JSON" | jq -r '.sshKey.publicKey')

if [[ $TEST_MODE -eq 1 ]]; then
    echo "GitHub PRIVATE_KEY:"
    echo "$PRIVATE_KEY"
    echo "GitHub PUBLIC_KEY:"
    echo "$PUBLIC_KEY"
else
    mkdir -p ~/.ssh
    echo "$PRIVATE_KEY" > ~/.ssh/id_ed25519
    echo "$PUBLIC_KEY" > ~/.ssh/id_ed25519.pub
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub
fi