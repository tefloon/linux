#!/usr/bin/env bash

set -e

# Parse arguments
TEST_MODE=0
if [[ "$1" == "--test" ]]; then
    TEST_MODE=1
    echo "Running in TEST MODE: secrets will NOT be written to disk."
fi

# Ensure Bitwarden CLI is installed and jq is available
command -v bw >/dev/null || { echo "Bitwarden CLI not found!"; exit 1; }
command -v jq >/dev/null || { echo "jq not found!"; exit 1; }

# Log in and unlock Bitwarden
bw login
BW_SESSION=$(bw unlock --raw)

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