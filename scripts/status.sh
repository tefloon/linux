#!/usr/bin/env bash

STATUS_COL=60
LOG_FILE="${LOG_FILE:-/tmp/setup-$(date +%Y%m%d-%H%M%S).log}"

# Initialize log file
if [[ ! -f "$LOG_FILE" ]]; then
    echo "=== Setup Log Started: $(date) ===" > "$LOG_FILE"
fi

status_msg() {
    printf "%s" "$CURRENT_STEP_MESSAGE... "
    echo "[$(date '+%H:%M:%S')] MSG: $CURRENT_STEP_MESSAGE" >> "$LOG_FILE"
}

status_ok() {
    local GREEN='\033[0;32m'
    local NC='\033[0m'
    local padlen=$(( STATUS_COL - ${#CURRENT_STEP_MESSAGE} - 4 ))
    printf "\r%s... %*s[%b  OK   %b]\n" \
        "$CURRENT_STEP_MESSAGE" "$padlen" "" "$GREEN" "$NC"
    echo "[$(date '+%H:%M:%S')] OK: $CURRENT_STEP_MESSAGE" >> "$LOG_FILE"
}

status_skip() {
    local YELLOW='\033[0;33m'
    local NC='\033[0m'
    local padlen=$(( STATUS_COL - ${#CURRENT_STEP_MESSAGE} - 4 ))
    printf "\r%s... %*s[%bSKIPPED%b]\n" \
        "$CURRENT_STEP_MESSAGE" "$padlen" "" "$YELLOW" "$NC"
    
    local reason="${1:-No reason provided}"
    echo -e "${YELLOW}Skipped: $reason${NC}" >&2
    echo "[$(date '+%H:%M:%S')] SKIP: $CURRENT_STEP_MESSAGE - $reason" >> "$LOG_FILE"
    
    sleep 2
}

status_error() {
    local RED='\033[0;31m'
    local NC='\033[0m'
    local padlen=$(( STATUS_COL - ${#CURRENT_STEP_MESSAGE} - 4 ))
    printf "\r%s... %*s[%b ERROR %b]\n" \
        "$CURRENT_STEP_MESSAGE" "$padlen" "" "$RED" "$NC"
    
    local reason="${1:-Unknown error}"
    echo -e "${RED}Error: $reason${NC}" >&2
    echo "[$(date '+%H:%M:%S')] ERROR: $CURRENT_STEP_MESSAGE - $reason" >> "$LOG_FILE"
    
    exit 1
}
