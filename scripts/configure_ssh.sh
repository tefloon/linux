#!/usr/bin/env bash

set -e

SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"
ZSHRC="$HOME/.zshrc"

# Ensure the .ssh directory exists and has correct permissions
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Generate a new SSH key pair if it doesn't exist
if [ ! -f "$KEY_FILE" ]; then
    if ! command -v ssh-keygen >/dev/null 2>&1; then
        echo "ssh-keygen not found! Please install OpenSSH."
        exit 1
    fi
    ssh-keygen -t ed25519 -C "tefloon@gmail.com" -f "$KEY_FILE" -N ""
    echo "New SSH key generated."
    echo "Add this public key to GitHub:"
    cat "$KEY_FILE.pub"
else
    echo "SSH key already exists."
fi

# Set up SSH config for GitHub
cat > "$SSH_DIR/config" << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
EOF
chmod 600 "$SSH_DIR/config"

# Check for keychain and install if missing (optional)
if ! command -v keychain >/dev/null 2>&1; then
    echo "keychain not found! Please install it before continuing."
    exit 1
fi

# Start keychain and add the key for the current session
eval "$(keychain --eval id_ed25519 2>/dev/null)"
echo "Keychain has been initialized for id_ed25519."

# Add keychain initialization to ~/.zshrc if not already present
if ! grep -q 'keychain --eval id_ed25519' "$ZSHRC"; then
    echo 'eval $(keychain --eval id_ed25519 2>/dev/null)' >> "$ZSHRC"
    echo "Added keychain initialization to $ZSHRC"
else
    echo "Keychain initialization already present in $ZSHRC"
fi