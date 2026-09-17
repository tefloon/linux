#!/usr/bin/env bash
set -e

# Everything this script creates (key files, secrets file, directories) is
# private to the current user by default.
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

TEST_MODE=0
if [[ "$1" == "--test" ]]; then
    TEST_MODE=1
    echo "Running in TEST MODE: secrets will NOT be written to disk."
fi

# Check required tools first, so a missing tool gives a clear error
# instead of failing somewhere further down.
for tool in bw jq curl tailscale; do
    CURRENT_STEP_MESSAGE="Checking for $tool"
    status_msg
    command -v "$tool" >/dev/null || status_error "$tool not found"
    status_ok
done

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

CURRENT_STEP_MESSAGE="Checking status of BW authentication"
BW_STATUS=$(bw status | jq -r .status)

bw_login() {
    echo -e "\nLogging in to Vaultwarden..."
    # --raw returns a session key directly, so no separate unlock is needed
    BW_SESSION=$(bw login --raw)
}

case "$BW_STATUS" in
    unauthenticated)
        bw_login
        ;;
    locked)
        echo -e "\nUnlocking Bitwarden vault..."
        BW_SESSION=$(bw unlock --raw)
        ;;
    unlocked)
        # Reuse a session from the environment, or unlock again if not set
        if [[ -z "$BW_SESSION" ]]; then
            BW_SESSION=$(bw unlock --raw)
        fi
        ;;
    *)
        status_msg
        status_error "Unknown Bitwarden status: $BW_STATUS"
        ;;
esac

# Sync with the server. This refreshes the local cache and is also the first
# call that really talks to the server, so it catches a stored login that
# the server no longer accepts (invalid_grant).
CURRENT_STEP_MESSAGE="Syncing vault"
status_msg
if bw sync --session "$BW_SESSION" >/dev/null 2>&1; then
    status_ok
else
    echo -e "\nServer rejected the stored login, logging in again..."
    bw logout >/dev/null 2>&1 || true
    bw_login
    CURRENT_STEP_MESSAGE="Syncing vault (after fresh login)"
    status_msg
    if ! bw sync --session "$BW_SESSION" >/dev/null 2>&1; then
        status_error "Sync failed even after a fresh login"
    fi
    status_ok
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

            echo "  $item_name → id_ed25519_${safe_name}"
            if [[ $TEST_MODE -eq 0 ]]; then
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
                echo -n "  $item_name → "
                # Pipe the key straight into gpg so it never touches disk.
                # (A here-string would use a temp file on bash < 5.1.)
                if printf '%s\n' "$NOTES" | gpg --batch --import 2>/dev/null; then
                    echo "imported to GPG keyring"
                else
                    echo "FAILED (invalid key format)"
                fi
            fi
        else
            echo "  $item_name → SKIPPED (no private key block found)"
        fi
    done
fi

# Look for secrets in secure notes
CURRENT_STEP_MESSAGE="Looking for additional secrets in secure notes"
echo "$CURRENT_STEP_MESSAGE"

ZSH_DIR="$HOME/.zsh"
SECRETS_FILE="$ZSH_DIR/.zsh_secrets"

# One compact JSON object per item, so multiline notes stay together
SECRET_ITEMS=$(echo "$BW_ITEMS" | jq -c '.[] | select(.name | test("secret"; "i")) | select(.notes != null and .notes != "") | {name, notes}')

if [[ -z "$SECRET_ITEMS" ]]; then
    status_msg
    status_skip "No secret notes found"
else
    if [[ $TEST_MODE -eq 0 ]]; then
        mkdir -p "$ZSH_DIR"
        # Initialize or clear the secrets file
        echo "# Auto-generated secrets from Bitwarden" > "$SECRETS_FILE"
        # umask only applies to new files; fix up a pre-existing one too
        chmod 600 "$SECRETS_FILE"
    fi

    printf '%s\n' "$SECRET_ITEMS" | while IFS= read -r item; do
        item_name=$(printf '%s' "$item" | jq -r '.name')

        # Split the note into lines, drop Windows line endings, strip an
        # existing "export " prefix and keep only KEY=VALUE lines.
        vars=$(printf '%s' "$item" | jq -r '
            .notes
            | split("\n")[]
            | sub("\r$"; "")
            | sub("^\\s*(export\\s+)?"; "")
            | select(test("^[A-Za-z_][A-Za-z0-9_]*="))
        ')

        if [[ -z "$vars" ]]; then
            echo "  $item_name → SKIPPED (no KEY=VALUE lines found)"
        elif [[ $TEST_MODE -eq 1 ]]; then
            echo "  $item_name:"
            printf '%s\n' "$vars" | sed 's/^/    /'
        else
            echo "  $item_name → $SECRETS_FILE"
            printf '%s\n' "$vars" | sed 's/^/export /' >> "$SECRETS_FILE"
        fi
    done
    status_msg
    status_ok
fi

echo # Final newline for clean output
