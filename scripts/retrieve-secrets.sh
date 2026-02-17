#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

TEST_MODE=0
if [[ "$1" == "--test" ]]; then
    TEST_MODE=1
    echo "Running in TEST MODE: secrets will NOT be written to disk."
fi

# Check Tailscale connection
CURRENT_STEP_MESSAGE="Checking Tailscale connection"
status_msg
if ! tailscale status >/dev/null 2>&1; then
    status_error "Tailscale is not running. Start it with: sudo systemctl start tailscaled"
fi
status_ok

# Configure Vaultwarden server if not set
CURRENT_STEP_MESSAGE="Configuring Vaultwarden server"
status_msg
BW_SERVER=$(bw config server 2>/dev/null || echo "")
if [[ "$BW_SERVER" != *"vault.craftit.work"* ]]; then
    bw config server https://vault.craftit.work >/dev/null
    status_ok
else
    status_skip "Already configured"
fi

# Check Vaultwarden connectivity
CURRENT_STEP_MESSAGE="Checking Vaultwarden connectivity"
status_msg
if ! curl -s --max-time 5 "https://vault.craftit.work/alive" >/dev/null 2>&1; then
    status_error "Cannot reach Vaultwarden at vault.craftit.work. Is Tailscale connected?"
fi
status_ok

CURRENT_STEP_MESSAGE="Checking for Bitwarden CLI"
status_msg
command -v bw >/dev/null || status_error "Bitwarden CLI (bw) not found"
status_ok

CURRENT_STEP_MESSAGE="Checking for jq CLI"
status_msg
command -v jq >/dev/null || status_error "jq not found"
status_ok

CURRENT_STEP_MESSAGE="Checking status of BW authentication"
BW_STATUS=$(bw status | jq -r .status)

if [[ "$BW_STATUS" == "unauthenticated" ]]; then
    echo -e "\nLogging in to Bitwarden..."
    bw login
    BW_STATUS=$(bw status | jq -r .status)
fi

if [[ "$BW_STATUS" == "locked" ]]; then
    echo -e "\nUnlocking Bitwarden vault..."
    BW_SESSION=$(bw unlock --raw)
elif [[ "$BW_STATUS" == "unlocked" ]]; then
    # Try to get session from environment, or unlock again if not set
    if [[ -z "$BW_SESSION" ]]; then
        BW_SESSION=$(bw unlock --raw)
    fi
else
    status_msg
    status_error "Unknown Bitwarden status"
fi

# Fetch all vault items once
CURRENT_STEP_MESSAGE="Fetching vault items"
status_msg
BW_ITEMS=$(bw list items --session "$BW_SESSION")
status_ok

# Retrieve SSH keys
CURRENT_STEP_MESSAGE="Retrieving SSH keys from Bitwarden"
echo "$CURRENT_STEP_MESSAGE"

SSH_ITEMS=$(echo "$BW_ITEMS" | jq -r '.[] | select(.sshKey != null) | .id + ":" + .name')

if [[ -z "$SSH_ITEMS" ]]; then
    status_msg
    status_skip "No SSH keys found in Bitwarden"
else
    if [[ $TEST_MODE -eq 0 ]]; then
        mkdir -p ~/.ssh
    fi

    echo "$SSH_ITEMS" | while IFS=':' read -r item_id item_name; do
        ITEM_JSON=$(bw get item "$item_id" --session "$BW_SESSION")
        PRIVATE_KEY=$(echo "$ITEM_JSON" | jq -r '.sshKey.privateKey')
        PUBLIC_KEY=$(echo "$ITEM_JSON" | jq -r '.sshKey.publicKey')

        if [[ "$PRIVATE_KEY" != "null" && "$PUBLIC_KEY" != "null" ]]; then
            # Create safe filename from item name
            safe_name=$(echo "$item_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')

            if [[ $TEST_MODE -eq 1 ]]; then
                echo "  $item_name → id_ed25519_${safe_name}"
            else
                echo "  $item_name → id_ed25519_${safe_name}"
                echo "$PRIVATE_KEY" > ~/.ssh/id_ed25519_${safe_name}
                echo "$PUBLIC_KEY" > ~/.ssh/id_ed25519_${safe_name}.pub
                chmod 600 ~/.ssh/id_ed25519_${safe_name}
                chmod 644 ~/.ssh/id_ed25519_${safe_name}.pub
            fi
        else
            echo "  $item_name → SKIPPED (invalid key data)"
        fi
    done
    status_msg
    status_ok
fi

# Import PGP private keys from Bitwarden
CURRENT_STEP_MESSAGE="Looking for PGP private keys in secure notes"
echo "$CURRENT_STEP_MESSAGE"

PGP_NOTES=$(echo "$BW_ITEMS" | jq -r '.[] | select(.name | test("(pgp|gpg)"; "i")) | select(.notes != null and .notes != "") | .id + ":" + .name')

if [[ -z "$PGP_NOTES" ]]; then
    status_skip "No PGP keys found in notes"
else
    echo "$PGP_NOTES" | while IFS=':' read -r item_id item_name; do
        ITEM_JSON=$(bw get item "$item_id" --session "$BW_SESSION")
        NOTES=$(echo "$ITEM_JSON" | jq -r '.notes')

        # Check if notes contain PGP private key blocks
        if echo "$NOTES" | grep -q "BEGIN PGP PRIVATE KEY"; then
            if [[ $TEST_MODE -eq 1 ]]; then
                echo "  $item_name → would import PGP private key"
            else
                # Create temporary file for this specific key
                KEY_FILE=$(mktemp)
                echo "$NOTES" > "$KEY_FILE"

                echo -n "  $item_name → "
                if gpg --batch --import "$KEY_FILE" 2>/dev/null; then
                    echo "imported to GPG keyring"
                else
                    echo "FAILED (invalid key format)"
                fi

                # Clean up immediately
                rm -f "$KEY_FILE"
            fi
        else
            echo "  $item_name → SKIPPED (no private key block found)"
        fi
    done
fi

# Look for secrets in secure notes
CURRENT_STEP_MESSAGE="Looking for additional secrets in secure notes"
echo "$CURRENT_STEP_MESSAGE"

SECRET_NOTES=$(echo "$BW_ITEMS" | jq -r '.[] | select(.name | test("secret"; "i")) | select(.notes != null and .notes != "") | .name + ":" + .notes')

ZSH_DIR="$HOME/.zsh"
mkdir -p "$ZSH_DIR"

if [[ -z "$SECRET_NOTES" ]]; then
    status_msg
    status_skip "No secret notes found"
else
    if [[ $TEST_MODE -eq 0 ]]; then
        # Initialize or clear the secrets file
        echo "# Auto-generated secrets from Bitwarden" > "$ZSH_DIR/.zsh_secrets"
    fi

    echo "$SECRET_NOTES" | while IFS=':' read -r item_name notes; do
        # Try to parse notes as environment variables
        if echo "$notes" | grep -q "="; then
            if [[ $TEST_MODE -eq 1 ]]; then
                echo "  $item_name:"
                echo "$notes" | grep "=" | sed 's/^/    /'
            else
                echo "  $item_name → $ZSH_DIR/.zsh_secrets"
                echo "$notes" | grep "=" | sed 's/^/export /' >> "$ZSH_DIR/.zsh_secrets"
            fi
        fi
    done
    status_msg
    status_ok
fi

echo # Final newline for clean output
