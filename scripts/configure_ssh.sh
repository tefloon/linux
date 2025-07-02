#!/usr/bin/env bash


# Ensure the .ssh directory exists and has correct permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate a new SSH key pair if it doesn't exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "tefloon@gmail.com" -f ~/.ssh/id_ed25519 -N ""
    echo "New SSH key generated."
    echo "Add this public key to GitHub:"
    cat ~/.ssh/id_ed25519.pub
else
    echo "SSH key already exists."
fi

# Set up SSH config for GitHub
cat > ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
EOF
chmod 600 ~/.ssh/config

# Start keychain and add the key for the current session
eval $(keychain --eval id_ed25519 2>/dev/null)
echo "Keychain has been initialized for id_ed25519."

# Add keychain initialization to ~/.zshrc if not already present
if ! grep -q 'keychain --eval id_ed25519' ~/.zshrc; then
    echo 'eval $(keychain --eval id_ed25519 2>/dev/null)' >> ~/.zshrc
    echo "Added keychain initialization to ~/.zshrc"
else
    echo "Keychain initialization already present in ~/.zshrc"
fi
