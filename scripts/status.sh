#!/usr/bin/env bash

STATUS_COL=60
LOG_FILE="${LOG_FILE:-/tmp/setup-$(date +%Y%m%d-%H%M%S).log}"

# ANSI colors — defined once, shared by all status_* functions
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Initialize log file
if [[ ! -f "$LOG_FILE" ]]; then
    echo "=== Setup Log Started: $(date) ===" > "$LOG_FILE"
fi

# Render the right-aligned status badge for the current step.
#   $1 = color   $2 = 7-char status label
_status_badge() {
    local padlen=$(( STATUS_COL - ${#CURRENT_STEP_MESSAGE} - 4 ))
    printf "\r%s... %*s[%b%s%b]\n" \
        "$CURRENT_STEP_MESSAGE" "$padlen" "" "$1" "$2" "$NC"
}

status_msg() {
    printf "%s" "$CURRENT_STEP_MESSAGE... "
    echo "[$(date '+%H:%M:%S')] MSG: $CURRENT_STEP_MESSAGE" >> "$LOG_FILE"
}

status_ok() {
    _status_badge "$GREEN" "  OK   "
    echo "[$(date '+%H:%M:%S')] OK: $CURRENT_STEP_MESSAGE" >> "$LOG_FILE"
}

status_skip() {
    _status_badge "$YELLOW" "SKIPPED"

    local reason="${1:-No reason provided}"
    echo -e "${YELLOW}Skipped: $reason${NC}" >&2
    echo "[$(date '+%H:%M:%S')] SKIP: $CURRENT_STEP_MESSAGE - $reason" >> "$LOG_FILE"

}

status_error() {
    _status_badge "$RED" " ERROR "

    local reason="${1:-Unknown error}"
    echo -e "${RED}Error: $reason${NC}" >&2
    echo "[$(date '+%H:%M:%S')] ERROR: $CURRENT_STEP_MESSAGE - $reason" >> "$LOG_FILE"

    exit 1
}

status_summary() {
    local skips errors
    skips=$(grep -c "] SKIP:"  "$LOG_FILE" || true)
    errors=$(grep -c "] ERROR:" "$LOG_FILE" || true)

    echo -e "\n=== Summary ===  ${YELLOW}${skips} skipped${NC}, ${RED}${errors} errored${NC}"

    if (( skips > 0 )); then
        echo -e "${YELLOW}Skipped:${NC}"
        grep "] SKIP:"  "$LOG_FILE" | sed 's/^[^]]*] SKIP: /  - /'
    fi
    if (( errors > 0 )); then
        echo -e "${RED}Errored:${NC}"
        grep "] ERROR:" "$LOG_FILE" | sed 's/^[^]]*] ERROR: /  - /'
    fi
    echo -e "\nFull log: $LOG_FILE"
    echo
}
