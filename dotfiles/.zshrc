# ~/.zshrc 
# zmodload zsh/zprof

# --- Early Performance Optimizations ---
# Skip global compinit (we'll do it ourselves later)
skip_global_compinit=1

# Source default browser configuration (auto-generated)
[ -f "$HOME/.config/default-apps/generated-env.sh" ] && source "$HOME/.config/default-apps/generated-env.sh"

# --- ZSH Configuration ---
autoload -Uz zmv zln

# Remove forward slash and maybe dot
WORDCHARS=${WORDCHARS//[\/]}

# History Configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt APPEND_HISTORY             # Append rather than overwrite
setopt HIST_IGNORE_SPACE          # Don't save commands starting with space
setopt HIST_VERIFY                # Show command before executing from history

# --- Keybindings ---
# Word jumping with Ctrl+Arrow keys
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[OC" forward-word
bindkey "^[OD" backward-word
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word

# Home and End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line

# Delete key
bindkey "^[[3~" delete-char
bindkey "^[3;5~" delete-char

# --- Completion System (OPTIMIZED for speed) ---
# Only regenerate compdump once per day
autoload -Uz compinit
compinit -C -u  # Always skip security checks

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Enable menu selection
zstyle ':completion:*' menu select

# Simple completion colors - no bold
zstyle ':completion:*:default' list-colors 'di=34:ln=36:ex=33:fi=90'

# Remove group names/descriptions entirely
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format ''

# Cache completion results
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# --- Environment Variables (set early) ---
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='subl -w'
export PAGER="bat"
export BAT_PAGER="less -RF"

# --- Colors & LS Configuration ---
# Conditional eza setup (only if installed)
if (( $+commands[eza] )); then
  # eza (modern ls replacement)
  alias ls='eza --color=always --group-directories-first --icons'
  alias ll='eza -lh --color=always --group-directories-first --icons'
  alias la='eza -lah --sort=size --color=always --group-directories-first --icons'
  alias l='eza -lah --color=always --group-directories-first --icons'
  alias lt='eza -T --color=always --group-directories-first --icons --level=2 --git-ignore -I "node_modules|.npm|__pycache__"'
  alias l.='eza -lah --color=always --group-directories-first --icons | grep "^\."'
  alias lg='eza -lah --git --color=always --group-directories-first --icons'
  alias lm='eza -lah --sort=modified --color=always --group-directories-first --icons'

else
  # Fallback to standard ls/tree with colors
  alias ls='ls --color=auto'
  alias ll='ls -lh --color=auto'
  alias la='ls -lAh --color=auto'
  alias l='ls -CF --color=auto'
  alias tree='tree -aI ".git|node_modules|.npm|__pycache__" -L 3'
fi

# Colored command output
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# --- Plugins (lazy load for performance) ---
# Load syntax highlighting last (as recommended)
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1  # Faster rebinding
fi

if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # Defer highlighting, reduce work
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
  ZSH_HIGHLIGHT_MAXLENGTH=300  # Don't highlight very long commands
fi

# --- Tool Initializations (lazy where possible) ---
# Zoxide
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# FZF
# Load keybindings immediately (they're fast)
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
  
  # Defer completion loading in background
  [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh &!
  
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  export FZF_ALT_C_COMMAND='ls -1d */'
  export FZF_DEFAULT_COMMAND='fd --type f'
  export FZF_CTRL_T_COMMAND='fd --type f --max-depth 2 --exclude .config --exclude Chmury --exclude Backups --no-follow'
fi

# Load secrets (if exists)
[ -f "$HOME/.zsh_secrets" ] && source "$HOME/.zsh_secrets"

# --- Aliases ---
alias sdn='shutdown now'
alias dgd='dragon-drop -x'
alias cd..='cd ..'
alias q='qalc'
alias ncdu='ncdu --color dark'
alias bm='bat -l man --plain'

s() {
  xdg-open "$@" &!
}

man() {
  command man "$@" | col -bx | bat --language=man --plain
}

# Rehash and compinit after package installation
yay() {
  command yay "$@" && rehash
}

pacman() {
  command pacman "$@" && rehash
}

git() {
    if [[ $1 == "log" ]]; then
        command git log "${@:2}" | bat --style=plain --paging=always
    else
        command git "$@"
    fi
}

# Track if this is the first prompt
typeset -g FIRST_PROMPT=1

# Custom precmd to add newline before prompt (except first)
add_newline_before_prompt() {
  if [[ $FIRST_PROMPT -eq 1 ]]; then
    FIRST_PROMPT=0
  else
    print ""  # Add blank line before subsequent prompts
  fi
}
precmd_functions+=(add_newline_before_prompt)

# --- Starship Prompt (must be at the end) ---
(( $+commands[starship] )) && eval "$(starship init zsh)"

# Ensure clean exit status for first prompt
true

# zprof