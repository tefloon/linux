# ~/.zshrc
# zmodload zsh/zprof

# Source default browser configuration (auto-generated)
[ -f "$HOME/.config/default-apps/generated-env.sh" ] && source "$HOME/.config/default-apps/generated-env.sh"

# --- Environment Variables (set early) ---
typeset -U path                   # Drop duplicate PATH entries in nested shells
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR='helix'
export SUDO_EDITOR=micro
export PAGER="bat"
export BAT_PAGER="less -RF"
export LESS='-RFX'
export BAT_THEME="OneHalfDark"
# Prettier man pages. MANROFFOPT=-c keeps groff from emitting SGR codes that col -b can't strip.
export MANPAGER="sh -c 'col -bx | bat --language=man --plain'"
export MANROFFOPT="-c"

# --- ZSH Configuration ---
autoload -Uz zmv
alias zln='zmv -L'
alias zcp='zmv -C'
unsetopt FLOW_CONTROL             # Free up Ctrl+S/Ctrl+Q in the line editor
setopt INTERACTIVE_COMMENTS       # Allow # comments in typed/pasted commands
setopt NO_CASE_GLOB
setopt AUTO_CD                    # Type a directory name alone to cd into it
setopt AUTO_PUSHD                 # cd pushes onto the dir stack: `cd -<TAB>` lists recent dirs
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Named directories: `cd ~p/topschool`, and the prompt shows ~p instead of the full path
hash -d p=/mnt/chmury/projects
hash -d cl=~/claude

# Treat / as a word boundary, so Ctrl+W and word jumps stop at path components
WORDCHARS=${WORDCHARS//[\/]}

# History Configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY         # Write each command immediately, not on exit
setopt EXTENDED_HISTORY           # Save timestamps and durations
setopt HIST_IGNORE_SPACE          # Don't save commands starting with space
setopt HIST_VERIFY                # Show command before executing from history

# --- Keybindings ---
# Word jumping with Ctrl+Arrow keys
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Home and End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

# Delete and Ctrl+Delete
bindkey "^[[3~" delete-char
bindkey "^[[3;5~" kill-word

# Up/Down search history by the prefix already typed (both cursor-key modes)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

# Ctrl+X Ctrl+E: edit the command line in $EDITOR; it comes back to the prompt, not run
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# --- Completion System (OPTIMIZED for speed) ---
# Full compinit (rebuilds the dump) only if it's older than 24h; otherwise -C
# skips the security scan and reuses the existing dump.
# The (#q) glob qualifier needs extendedglob, kept local so ^ and # stay literal at the prompt.
autoload -Uz compinit
() {
  setopt localoptions extendedglob
  if [[ -n ~/.zsh/.zcompdump(#qN.mh+24) ]]; then
    compinit -u -d ~/.zsh/.zcompdump
  else
    compinit -C -u -d ~/.zsh/.zcompdump
  fi
}

[ -f /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh ] && source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh

# Case-insensitive completion, then case-insensitive substring match as a fallback
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'm:{a-z}={A-Za-z} l:|=* r:|=*'

# fzf-tab replaces the completion menu
zstyle ':completion:*' menu no

# Preview directory contents while completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'

# Pick up newly installed commands without a manual rehash
zstyle ':completion:*' rehash true

# Simple completion colors - no bold
zstyle ':completion:*:default' list-colors 'di=34:ln=36:ex=33:fi=90'

# Remove group names/descriptions entirely
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format ''

# Cache completion results
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# --- Colors & LS Configuration ---
# Conditional eza setup (only if installed)
if (( $+commands[eza] )); then
  # eza (modern ls replacement)
  # --icons=auto, not bare --icons: eza takes the next word as its value otherwise
  alias ls='eza --color=auto --group-directories-first --icons=auto'
  alias l='eza -lh --color=auto --group-directories-first --icons=auto'
  alias la='eza -lah --sort=size --color=auto --group-directories-first --icons=auto'
  alias ll='eza -lah --color=auto --group-directories-first --icons=auto'
  alias lt='eza -T --color=auto --group-directories-first --icons=auto --level=2 --git-ignore -I "node_modules|.npm|__pycache__"'
  alias l.='eza -lad --color=auto --group-directories-first --icons=auto .*'
  alias lg='eza -lah --git --color=auto --group-directories-first --icons=auto'
  alias lm='eza -lah --sort=modified --color=auto --group-directories-first --icons=auto'

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

# --- Plugins ---
# Both go after fzf-tab. zsh-syntax-highlighting >= 0.8 on zsh >= 5.9 hooks
# zle-line-pre-redraw instead of wrapping widgets, so it doesn't need to be last.
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1  # Bind widgets once at the first prompt, not on every prompt
fi

if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # Reduce work
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
  ZSH_HIGHLIGHT_MAXLENGTH=300  # Don't highlight very long commands
fi

# --- Tool Initializations ---
# Zoxide
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# FZF (key bindings + ** completion)
if (( $+commands[fzf] )); then
  source <(fzf --zsh)

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

# Launch a throwaway instance of claude in ~/claude/chat (plain chat, no hub)
# Used for conversations, just in the terminal
# Subshell, so the cd doesn't touch OLDPWD or zoxide
c() {
  (cd ~/claude/chat && claude "$@")
}

# Claude project hub: INDEX + recent sessions across all projects
ch() {
  (cd ~/claude/hub && claude "$@")
}

lyr() {
  curl -s -A 'lyr/0.1' --get 'https://lrclib.net/api/search' \
    --data-urlencode "q=$*" \
  | jq -r '.[0] | if .instrumental then "(instrumental)" else .plainLyrics // "no lyrics found" end' \
  | ${PAGER:-less}
}

# Open the file/folder in the default program
s() {
  xdg-open "$@" &!
}

# Create a directory/directory chain and enter them
mkcd() {
  mkdir -p "$1" && cd "$1"
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

# Ensure clean exit status for first prompt
true

# zprof
