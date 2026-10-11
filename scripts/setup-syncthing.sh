#!/usr/bin/env bash
#
# setup-syncthing.sh: bring this machine's Syncthing back after a reinstall,
# or keep the backup that makes that possible up to date.
#
# Usage:
#   setup-syncthing.sh            restore; run after setup.sh, a reboot,
#                                 setup-storage.sh and retrieve-secrets.sh
#   setup-syncthing.sh --backup   copy config.xml and the .stignore files to
#                                 the backups folder; syncthing-backup.path
#                                 runs this whenever the config changes
#
# What lives where:
#   - Device identity (cert.pem + key.pem): the Vaultwarden secure note named
#     in IDENTITY_ITEM, cert first, then key. Keeping the identity means the
#     peers recognise this machine and nothing has to be re-approved on them.
#   - config.xml and each folder's .stignore (saved as <folder-id>.stignore):
#     BACKUP_DIR, a synced folder on the data disk, so it survives a wipe and
#     is also on ct100 and in its borg backup.
#   - The database (index-v2) is not backed up; Syncthing rebuilds it.
#
# The restore relies on behaviour tested on 2026-10-11 (Syncthing 2.1.5):
#   - A folder with no database records and no directory: Syncthing creates
#     the directory and .stfolder itself and pulls from the peers, without
#     deleting anything on them.
#   - A directory that exists without .stfolder: the folder stops with
#     "folder marker missing" instead of syncing. Safe, but needs a human.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
STATE_DIR="$HOME/.local/state/syncthing"
BACKUP_DIR="$HOME/documents/private/backups/syncthing"
IDENTITY_ITEM="Syncthing identity (hyprland-new)"
BACKUP_UNIT="syncthing-backup.path"

MODE=restore
for arg in "$@"; do
    case "$arg" in
        --backup) MODE=backup ;;
        -h|--help)
            sed -n '3,/^$/{/^#/s/^# \{0,1\}//p}' "$0"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg (try --help)" >&2
            exit 2
            ;;
    esac
done

# config.xml holds the API key, keep every copy private
umask 077

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
folder_count() {
    xmllint --xpath 'count(/configuration/folder)' "$1"
}

# One "id<TAB>path" line per folder, with a leading ~ expanded
list_folders() {
    local cfg="$1" n i id path
    n=$(folder_count "$cfg")
    for (( i = 1; i <= n; i++ )); do
        id=$(xmllint --xpath "string(/configuration/folder[$i]/@id)" "$cfg")
        path=$(xmllint --xpath "string(/configuration/folder[$i]/@path)" "$cfg")
        printf '%s\t%s\n' "$id" "${path/#\~/$HOME}"
    done
}

# Copy only when the content differs, so an unchanged config doesn't make
# Syncthing send the backup around again
copy_if_changed() {
    local src="$1" dest="$2"
    cmp -s "$src" "$dest" && return 1
    cp "$src" "$dest.tmp" && mv "$dest.tmp" "$dest"
}

# ---------------------------------------------------------------------------
# Backup
# ---------------------------------------------------------------------------
do_backup() {
    local live="$STATE_DIR/config.xml" saved="$BACKUP_DIR/config.xml"
    local live_n saved_n=0 id path f
    local -A has_ignore=()

    CURRENT_STEP_MESSAGE="Checking the backups folder"
    status_msg
    [[ -d "$(dirname "$BACKUP_DIR")" ]] \
        || status_error "$(dirname "$BACKUP_DIR") not found. Is the data disk mounted?"
    mkdir -p "$BACKUP_DIR"
    status_ok

    # A fresh install writes a config without folders. Never let that replace
    # the backup it is about to be restored from.
    CURRENT_STEP_MESSAGE="Checking the live config"
    status_msg
    [[ -f "$live" ]] || status_error "$live not found"
    live_n=$(folder_count "$live")
    [[ -f "$saved" ]] && saved_n=$(folder_count "$saved")
    if (( live_n == 0 && saved_n > 0 )); then
        status_error "Live config has no folders, the backup has $saved_n. Not overwriting it; restore first."
    fi
    status_ok

    CURRENT_STEP_MESSAGE="Backing up config.xml"
    status_msg
    if copy_if_changed "$live" "$saved"; then
        status_ok
    else
        status_skip "Unchanged"
    fi

    CURRENT_STEP_MESSAGE="Backing up .stignore files"
    status_msg
    while IFS=$'\t' read -r id path; do
        [[ -f "$path/.stignore" ]] || continue
        has_ignore[$id]=1
        copy_if_changed "$path/.stignore" "$BACKUP_DIR/$id.stignore"
    done < <(list_folders "$live")
    # Drop saved ignores of folders that no longer have one
    for f in "$BACKUP_DIR"/*.stignore; do
        [[ -e "$f" ]] || continue
        id=$(basename "$f" .stignore)
        [[ -n "${has_ignore[$id]}" ]] || rm -f "$f"
    done
    status_ok
}

# ---------------------------------------------------------------------------
# Restore
# ---------------------------------------------------------------------------
check_tools() {
    local tool
    for tool in syncthing bw jq xmllint openssl curl; do
        CURRENT_STEP_MESSAGE="Checking for $tool"
        status_msg
        command -v "$tool" >/dev/null || status_error "$tool not found"
        status_ok
    done
}

# Sets BW_SESSION, the same way retrieve-secrets.sh does
unlock_vault() {
    CURRENT_STEP_MESSAGE="Unlocking Vaultwarden"
    status_msg
    case "$(bw status | jq -r .status)" in
        unauthenticated)
            status_error "Not logged in to Vaultwarden. Run retrieve-secrets.sh first."
            ;;
        locked)
            echo
            BW_SESSION=$(bw unlock --raw) || status_error "Unlock failed"
            ;;
        unlocked)
            if [[ -z "$BW_SESSION" ]]; then
                echo
                BW_SESSION=$(bw unlock --raw) || status_error "Unlock failed"
            fi
            ;;
    esac
    bw sync --session "$BW_SESSION" >/dev/null 2>&1 || status_error "Vault sync failed"
    status_ok
}

# Writes cert.pem and key.pem from the vault into $1, checks they belong
# together and that the backed-up config knows the device. Sets DEVICE_ID.
fetch_identity() {
    local dir="$1" notes

    CURRENT_STEP_MESSAGE="Fetching the device identity"
    status_msg
    notes=$(bw get notes "$IDENTITY_ITEM" --session "$BW_SESSION" 2>/dev/null) \
        || status_error "No vault item named \"$IDENTITY_ITEM\""
    printf '%s\n' "$notes" | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > "$dir/cert.pem"
    printf '%s\n' "$notes" | sed -n '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/p' > "$dir/key.pem"
    [[ -s "$dir/cert.pem" && -s "$dir/key.pem" ]] \
        || status_error "The note needs a certificate and a private key block"
    status_ok

    CURRENT_STEP_MESSAGE="Checking that cert and key match"
    status_msg
    [[ "$(openssl x509 -in "$dir/cert.pem" -pubkey -noout 2>/dev/null)" == \
       "$(openssl pkey -in "$dir/key.pem" -pubout 2>/dev/null)" ]] \
        || status_error "The key does not belong to the certificate"
    status_ok

    CURRENT_STEP_MESSAGE="Checking the device ID against the backup"
    status_msg
    DEVICE_ID=$(syncthing device-id --home "$dir") || status_error "Could not compute the device ID"
    [[ "$(xmllint --xpath "count(/configuration/device[@id='$DEVICE_ID'])" "$BACKUP_DIR/config.xml")" -gt 0 ]] \
        || status_error "Backed-up config does not know device $DEVICE_ID"
    status_ok
}

# Decides per folder what to do before Syncthing starts. The .stignore must
# be in place before the first pull, or a whitelisted folder briefly syncs
# everything. Fills PREPARE (paths to create with marker) and prints a plan.
plan_folders() {
    local id path saved
    PREPARE=()
    PULL=()
    HELD=()
    while IFS=$'\t' read -r id path; do
        saved="$BACKUP_DIR/$id.stignore"
        if [[ ! -e "$path" ]]; then
            PULL+=("$path")
            [[ -f "$saved" ]] && PREPARE+=("$id"$'\t'"$path")
        elif [[ -e "$path/.stfolder" ]]; then
            :   # survived the reinstall (data disk), Syncthing just rescans it
        elif [[ -z "$(ls -A "$path")" ]]; then
            PULL+=("$path")
            PREPARE+=("$id"$'\t'"$path")
        else
            HELD+=("$path")
        fi
    done < <(list_folders "$BACKUP_DIR/config.xml")
}

prepare_folders() {
    local entry id path saved
    for entry in "${PREPARE[@]}"; do
        IFS=$'\t' read -r id path <<< "$entry"
        saved="$BACKUP_DIR/$id.stignore"
        CURRENT_STEP_MESSAGE="Preparing ${path/#$HOME/\~}"
        status_msg
        mkdir -p "$path" || status_error "Could not create $path"
        [[ -f "$saved" ]] && cp "$saved" "$path/.stignore"
        mkdir -p "$path/.stfolder"
        status_ok
    done
}

# Saved ignores for folders that exist already: add when missing, never
# overwrite a different one silently
restore_ignores() {
    local id path saved
    while IFS=$'\t' read -r id path; do
        saved="$BACKUP_DIR/$id.stignore"
        [[ -f "$saved" && -d "$path" ]] || continue
        CURRENT_STEP_MESSAGE="Checking .stignore of ${path/#$HOME/\~}"
        status_msg
        if [[ ! -e "$path/.stignore" ]]; then
            cp "$saved" "$path/.stignore"
            status_ok
        elif cmp -s "$saved" "$path/.stignore"; then
            status_skip "Already in place"
        else
            status_skip "Differs from the backup, left alone"
        fi
    done < <(list_folders "$BACKUP_DIR/config.xml")
}

api() {
    curl -sf --max-time 5 -H "X-API-Key: $API_KEY" "$GUI_URL$1"
}

do_restore() {
    local staging answer p i old

    [[ -t 0 ]] || { echo "The restore is interactive, run it from a terminal." >&2; exit 1; }
    check_tools

    CURRENT_STEP_MESSAGE="Looking for the backup"
    status_msg
    [[ -f "$BACKUP_DIR/config.xml" ]] \
        || status_error "$BACKUP_DIR/config.xml not found. Run setup-storage.sh first?"
    status_ok

    unlock_vault
    mkdir -p "$(dirname "$STATE_DIR")"
    staging=$(mktemp -d "$STATE_DIR.restore.XXXXXX")
    # Don't leave the private key lying around if anything below fails. After
    # a successful restore the staging dir has been moved, so this is a no-op.
    trap 'rm -rf "$staging"' EXIT
    fetch_identity "$staging"
    cp "$BACKUP_DIR/config.xml" "$staging/config.xml"

    plan_folders
    echo
    if (( ${#PULL[@]} > 0 )); then
        echo "These folders don't exist here and will be pulled from the peers:"
        printf '  %s\n' "${PULL[@]}"
        echo "A path that should be on the data disk listed here means a missing"
        echo "mount or symlink: answer no and run setup-storage.sh first."
    fi
    if (( ${#HELD[@]} > 0 )); then
        echo "These folders have content but no .stfolder, Syncthing will hold them"
        echo "with \"folder marker missing\" (nothing gets synced or deleted):"
        printf '  %s\n' "${HELD[@]}"
        echo "Check each one, then 'mkdir <path>/.stfolder' to let it merge with the"
        echo "peers (differing files end up as .sync-conflict copies)."
    fi
    read -rp "Restore Syncthing as device ${DEVICE_ID%%-*}? [y/N] " answer
    if [[ "$answer" != [yY] ]]; then
        echo "Nothing changed."
        exit 0
    fi

    CURRENT_STEP_MESSAGE="Stopping Syncthing"
    status_msg
    systemctl --user stop "$BACKUP_UNIT" syncthing.service 2>/dev/null
    status_ok

    # A first login after the reinstall may have started Syncthing already,
    # with a fresh identity. Keep that state aside instead of deleting it.
    if [[ -e "$STATE_DIR" ]]; then
        old="$STATE_DIR.before-restore-$(date +%Y%m%d-%H%M%S)"
        CURRENT_STEP_MESSAGE="Moving the existing state to ${old/#$HOME/\~}"
        status_msg
        mv "$STATE_DIR" "$old" || status_error "Could not move $STATE_DIR"
        status_ok
    fi
    CURRENT_STEP_MESSAGE="Installing identity and config"
    status_msg
    mv "$staging" "$STATE_DIR" || status_error "Could not create $STATE_DIR"
    status_ok

    prepare_folders
    restore_ignores

    CURRENT_STEP_MESSAGE="Starting Syncthing"
    status_msg
    systemctl --user enable --now syncthing.service >/dev/null 2>&1 \
        || status_error "Could not start syncthing.service"
    API_KEY=$(xmllint --xpath 'string(/configuration/gui/apikey)' "$STATE_DIR/config.xml")
    GUI_URL="http://$(xmllint --xpath 'string(/configuration/gui/address)' "$STATE_DIR/config.xml")"
    for (( i = 0; i < 30; i++ )); do
        [[ "$(api /rest/system/status | jq -r .myID 2>/dev/null)" == "$DEVICE_ID" ]] && break
        sleep 2
    done
    (( i < 30 )) || status_error "API did not come up as $DEVICE_ID within a minute"
    status_ok

    # Give the folders a moment to scan and connect, then report. Big pulls
    # carry on in the background.
    sleep 10
    echo
    echo "Folder states (pulls continue in the background, see $GUI_URL):"
    while IFS=$'\t' read -r id p; do
        api "/rest/db/status?folder=$id" \
            | jq -r --arg p "${p/#$HOME/\~}" '"  \($p): \(.state), \(.needFiles) files to pull\(if .error != "" then ", " + .error else "" end)"'
    done < <(list_folders "$STATE_DIR/config.xml")
    echo

    CURRENT_STEP_MESSAGE="Enabling the automatic config backup"
    status_msg
    systemctl --user daemon-reload
    if systemctl --user enable --now "$BACKUP_UNIT" >/dev/null 2>&1; then
        status_ok
    else
        status_skip "$BACKUP_UNIT not found, run setup-dotfiles.sh"
    fi

    status_summary
}

if [[ "$MODE" == backup ]]; then
    do_backup
else
    do_restore
fi
