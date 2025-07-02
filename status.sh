# status.sh

STATUS_COL=50

status_msg() {
    printf "%s" "$CURRENT_STEP_MESSAGE... "
}

status_ok() {
    local GREEN='\033[0;32m'
    local NC='\033[0m'
    local padlen=$(( STATUS_COL - ${#CURRENT_STEP_MESSAGE} - 4 ))
    printf "\r%s... %*s[%b  OK   %b]\n" \
        "$CURRENT_STEP_MESSAGE" "$padlen" "" "$GREEN" "$NC"
}

status_error() {
    local RED='\033[0;31m'
    local NC='\033[0m'
    local padlen=$(( STATUS_COL - ${#CURRENT_STEP_MESSAGE} - 4 ))
    printf "\r%s... %*s[%b ERROR %b]\n" \
        "$CURRENT_STEP_MESSAGE" "$padlen" "" "$RED" "$NC"
    if [[ -n "$1" ]]; then
        echo -e "${RED}Error: $1${NC}" >&2
    fi
    exit 1
}