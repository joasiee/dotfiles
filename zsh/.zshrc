export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS

# --- Up/Down = substring history search ------------------------------------
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# --- Ctrl+R = fzf history search (cross-session) ---------------------------
if command -v fzf >/dev/null 2>&1; then
  _fzf_history_widget() {
    local selected
    selected=$(fc -rl 1 | sed 's/^ *[0-9]* *//' | fzf --tac --no-sort)
    if [[ -n $selected ]]; then
      BUFFER=$selected
      CURSOR=${#BUFFER}
    fi
    zle redisplay
  }
  zle -N _fzf_history_widget
  bindkey '^R' _fzf_history_widget
fi

# --- Ctrl+T = fuzzy file picker --------------------------------------------
if command -v fzf >/dev/null 2>&1; then
  _fzf_file_widget() {
    local picked
    if command -v fd >/dev/null 2>&1; then
      picked=$(fd --type f --hidden --follow --exclude .git 2>/dev/null | fzf)
    else
      picked=$(find . -type f 2>/dev/null | fzf)
    fi
    if [[ -n $picked ]]; then
      LBUFFER+=$picked
    fi
    zle redisplay
  }
  zle -N _fzf_file_widget
  bindkey '^T' _fzf_file_widget
fi

# --- Ctrl+F = fuzzy directory picker ---------------------------------------
if command -v fzf >/dev/null 2>&1; then
  _fzf_dir_widget() {
    local picked
    if command -v fd >/dev/null 2>&1; then
      picked=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf)
    else
      picked=$(find . -type d 2>/dev/null | fzf)
    fi
    if [[ -n $picked ]]; then
      cd "$picked"
      zle reset-prompt
    fi
  }
  zle -N _fzf_dir_widget
  bindkey '^F' _fzf_dir_widget
fi

# --- Alt+J = zoxide interactive jump (zi) ----------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  _zi_widget() {
    zi
    zle reset-prompt
  }
  zle -N _zi_widget
  bindkey '^[j' _zi_widget
fi

# --- Alt+G = fuzzy git branch checkout -------------------------------------
if command -v fzf >/dev/null 2>&1; then
  _fzf_git_branch_widget() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then return; fi
    local picked
    picked=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null |
      grep -v '^origin/HEAD$' | sort -u | fzf --prompt 'git checkout> ' --no-sort)
    if [[ -z $picked ]]; then return; fi
    if [[ $picked == */* ]]; then
      BUFFER="git checkout -t $picked"
    else
      BUFFER="git checkout $picked"
    fi
    CURSOR=${#BUFFER}
    zle accept-line
  }
  zle -N _fzf_git_branch_widget
  bindkey '^[g' _fzf_git_branch_widget
fi
