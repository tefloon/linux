# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
ZSH_THEME="powerlevel10k/powerlevel10k"
source /home/tefloon/.oh-my-zsh/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Auto rehash after pacman installs ---
zshcache_time="$(date +%s%N)"

autoload -Uz add-zsh-hook

rehash_precmd() {
  if [[ -a /var/cache/zsh/pacman ]]; then
    local paccache_time="$(date -r /var/cache/zsh/pacman +%s%N)"
    if (( zshcache_time < paccache_time )); then
      rehash
      zshcache_time="$paccache_time"
    fi
  fi
}

add-zsh-hook -Uz precmd rehash_precmd

# history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS


eval "$(keychain --eval id_ed25519 id_ed25519_pi 2>/dev/null)"
eval "$(zoxide init zsh)"

[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

export FZF_ALT_C_COMMAND='ls -1d */'
export FZF_DEFAULT_COMMAND='fd --type f'  # if you have fd installed
export FZF_CTRL_T_COMMAND='fd --type f --max-depth 2 --exclude .config --exclude Chmury --exclude Backups --no-follow'

export EDITOR='subl -w'

export SPOTIPY_CLIENT_ID='72289e71aafc4e429fc93a96e1414fba'
export SPOTIPY_REDIRECT_URI='http://127.0.0.1:8888/callback'

# Load Spotipy secret if the file exists
[ -f "$HOME/.zsh_secrets" ] && source "$HOME/.zsh_secrets"

export PATH="$HOME/.local/bin:$PATH"

# my aliases
alias sdn='shutdown now'
alias dgd='dragon-drop -x'
alias cd..='cd ..'
alias c='clear'
alias q=qalc
alias tree='tree -aI ".git|node_modules|__pycache__"'


weather() {
  if [ $# -eq 0 ]; then
    curl v2d.wttr.in
  else
    curl "v2d.wttr.in/$*"
  fi
}

# using bat for man pages
batman() {
    man "$@" | col -bx | bat --language=man
}

# yazi working dir workaround
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
