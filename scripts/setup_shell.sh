SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status.sh"

# Install Oh-My-Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    CURRENT_STEP_MESSAGE="Installing Oh-My-Zsh"
    status_msg
    
    # Install oh-my-zsh non-interactively
    if RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
        status_ok
    else
        status_error "Failed to install Oh-My-Zsh"
    fi
else
    CURRENT_STEP_MESSAGE="Oh-My-Zsh already installed"
    status_msg
    status_skip "Already exists"
fi

# Install Powerlevel10k theme
if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
    CURRENT_STEP_MESSAGE="Installing Powerlevel10k theme"
    status_msg
    
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"; then
        status_ok
    else
        status_error "Failed to install Powerlevel10k"
    fi
else
    CURRENT_STEP_MESSAGE="Powerlevel10k already installed"
    status_msg
    status_skip "Already exists"
fi