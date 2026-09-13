# ~/.zshrc 
# zmodload zsh/zprof

# --- Early Performance Optimizations ---
# Skip global compinit (we'll do it ourselves later)
skip_global_compinit=1

# Source default browser configuration (auto-generated)
[ -f "$HOME/.config/default-apps/generated-env.sh" ] && source "$HOME/.config/default-apps/generated-env.sh"

# --- ZSH Configuration ---
autoload -Uz zmv zln
stty -ixon                        # Disable XOFF with Ctrl+S 

# Remove forward slash and maybe dot
WORDCHARS=${WORDCHARS//[\/]}

# History Configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh/.zsh_history
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
# Full compinit (rebuilds the dump) only if it's older than 24h; otherwise -C
# skips the security scan and reuses the existing dump.
autoload -Uz compinit
if [[ -n ~/.zsh/.zcompdump(#qN.mh+24) ]]; then
  compinit -u -d ~/.zsh/.zcompdump
else
  compinit -C -u -d ~/.zsh/.zcompdump
fi

source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh

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
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR='helix'
export SUDO_EDITOR=micro
export PAGER="bat"
export BAT_PAGER="less -RF"
export LESS='-RFX'
export BAT_THEME="OneHalfDark"

# --- Colors & LS Configuration ---
# Conditional eza setup (only if installed)
if (( $+commands[eza] )); then
  # eza (modern ls replacement)
  alias ls='eza --color=always --group-directories-first --icons'
  alias l='eza -lh --color=always --group-directories-first --icons'
  alias la='eza -lah --sort=size --color=always --group-directories-first --icons'
  alias ll='eza -lah --color=always --group-directories-first --icons'
  alias lt='eza -T --color=always --group-directories-first --icons --level=2 --git-ignore -I "node_modules|.npm|__pycache__"'
  alias l.='eza -lah --color=always --group-directories-first --icons | grep "^\."'
  alias lg='eza -lah --git --color=always --group-directories-first --icons'
  alias lm='eza -lah --sort=modified --color=always --group-directories-first --icons'

else
  # Fallback to standard ls/tree with colors
  alias ls='ls --color=auto'
  alias l='ls -lh --color=auto'
  alias la='ls -lAh --color=auto'
  alias ll='ls -CF --color=auto'
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
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1  # Faster rebinding; re-bound once at the end
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
  # fd, not ls: the eza alias would inject color codes and icons into the
  # directory names that Alt-C then tries to cd into.
  export FZF_ALT_C_COMMAND='fd --type d --max-depth 1'
  export FZF_DEFAULT_COMMAND='fd --type f'
  export FZF_CTRL_T_COMMAND='fd --type f --max-depth 2 --exclude .config --exclude Chmury --exclude Backups --no-follow'
fi

# Load secrets (if exists)
[ -f "$HOME/.zsh/.zsh_secrets" ] && source "$HOME/.zsh/.zsh_secrets"

# --- Aliases ---
# For convenience (shortening) and overwritting defaults
alias sdn='shutdown now'
alias dgd='dragon-drop -x'
alias cd..='cd ..'
alias q='qalc'
alias ncdu='ncdu --color dark'
alias bm='bat --plain'
alias vim='nvim'
alias hx='helix'
alias matrix='tmatrix -c default -s 20'
alias hx.='hx .'
alias urban='urban -m 3'
alias en='dict-pl en'
alias pl='dict-pl pl'
alias dust='dust -i -B -r'

# --- Functions ---
# bat for everything, glow for markdown.
# Name is quoted so a stray `alias cat=...` can't hijack the definition.
'cat'() {
  # no args → reading stdin; -pp = plain style, no paging
  if (( $# == 0 )); then
    command bat -pp
    return
  fi

  # not a terminal → emit raw bytes so redirects and pipes stay clean
  if [[ ! -t 1 ]]; then
    command cat "$@"
    return
  fi

  # any flags present? don't try to be clever, hand it all to bat
  local arg
  for arg in "$@"; do
    [[ "$arg" == -* ]] && { command bat "$@"; return }
  done

  for arg in "$@"; do
    case "${arg:l}" in
      # -s dark: glow falls back to the style-less "notty" theme when its
      # stdout isn't a terminal, which drops the margin and the colors.
      # Piping to less directly sidesteps PAGER=bat; LESS=-RFX handles the rest.
      *.md|*.markdown|*.mdown|*.mkd) glow -s dark "$arg" | command less ;;
      *)                             command bat "$arg" ;;
    esac
  done
}

# Launch a throwaway instance of claude in ~/claude
# Used for conversations, just in the terminal
c() {
  local prev="$PWD"
  cd ~/claude && claude "$@"
  cd "$prev"
}

lyr() {
  curl -s -A 'lyr/0.1' --get 'https://lrclib.net/api/search' \
    --data-urlencode "q=$*" \
  | jq -r '.[0] | if .instrumental then "(instrumental)" else .plainLyrics end' \
  | ${PAGER:-less}
}

# displays the number of characters each filename in the folder has
count-chars(){
  local dir=${1:-.}
  ( cd "$dir" && for f in *; do printf '%s\t%s\n' "$f" "${#f}"; done ) \
    | sort -t$'\t' -k2 -n | column -t -s$'\t' -R2
}

# Open the file/folder in the default program
s() {
  xdg-open "$@" &!
}

# Prettier man pages
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

# Create a directory/directory chain and enter them
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Styling of the git log
git() {
  if [[ $1 == "log" ]]; then
    # color.ui=always because git strips color once it sees a pipe
    command git -c color.ui=always log "${@:2}" | bat --style=plain --paging=always
  else
    command git "$@"
  fi
}

# yazi with a fix to return to the folder that was open
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

fzf-command-search() {
  local selected
  selected=$( { print -l ${(k)aliases}; print -l ${(k)functions}; print -l ${(k)commands} } \
    | sort -u \
    | fzf --height 40% --reverse --border --prompt="cmd> ")
  if [[ -n $selected ]]; then
    LBUFFER="${LBUFFER}${selected}"
  fi
  zle reset-prompt
}
zle -N fzf-command-search
bindkey '^S' fzf-command-search

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

# With MANUAL_REBIND the plugin only wraps widgets that existed when it loaded.
# One rebind here picks up fzf's widgets and fzf-command-search.
(( $+functions[_zsh_autosuggest_bind_widgets] )) && _zsh_autosuggest_bind_widgets

# Ensure clean exit status for first prompt
true

# zprof
