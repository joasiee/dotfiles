export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
autoload -U colors && colors
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS
setopt PROMPT_SUBST

prompt_git_info() {
  local repo_root repo_name branch

  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  repo_name=${repo_root:t}
  repo_name=${repo_name#.}
  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || \
    branch=$(git rev-parse --short HEAD 2>/dev/null) || return

  print -r -- " %F{cyan}[$repo_name:$branch]%f"
}

prompt_nix_info() {
  [[ -n "${IN_NIX_SHELL:-}" ]] || return
  print -r -- " %F{magenta}[nix]%f"
}

PROMPT='%F{green}%n%f %F{blue}%~%f$(prompt_git_info)$(prompt_nix_info) %# '

eval "$(direnv hook zsh)"

# --- Windows Terminal: emit OSC 9;9 so Duplicate Pane inherits cwd ---------
if [[ -n "${WT_SESSION:-}" ]]; then
  _wt_set_cwd() { printf '\e]9;9;%s\e\\' "$PWD" }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _wt_set_cwd
  _wt_set_cwd
fi

# --- Word Navigation (Ctrl+Left / Ctrl+Right) ---
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# --- Up/Down = substring history search ------------------------------------
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
# Same widgets for application-keypad-mode escape sequences (WSL/xterm)
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# --- Ctrl+R = fzf history search (cross-session) ---------------------------
if command -v fzf >/dev/null 2>&1; then
  _fzf_history_widget() {
    local selected
    selected=$(fc -ln 1 | tac | awk '!seen[$0]++' | fzf --no-sort --scheme=history)
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
      picked=$(fd --type f --hidden --follow --no-ignore-vcs --exclude .git --exclude '*.o' --exclude '*.obj' --exclude '*.d' --exclude '*.cmake' 2>/dev/null | fzf)
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
    # Local branches can contain '/' (e.g. pbi/foo), so check the ref, not the slash
    if git show-ref --verify --quiet "refs/heads/$picked"; then
      BUFFER="git checkout $picked"
    else
      BUFFER="git checkout -t $picked"
    fi
    CURSOR=${#BUFFER}
    zle accept-line
  }
  zle -N _fzf_git_branch_widget
  bindkey '^[g' _fzf_git_branch_widget
fi

# --- Alt+T = fuzzy file picker, unrestricted (ignores .gitignore) ----------
if command -v fzf >/dev/null 2>&1; then
  _fzf_file_all_widget() {
    local picked
    if command -v fd >/dev/null 2>&1; then
      picked=$(fd --type f --hidden --follow --no-ignore --exclude .git 2>/dev/null | fzf)
    else
      picked=$(find . -type f 2>/dev/null | fzf)
    fi
    if [[ -n $picked ]]; then
      LBUFFER+=$picked
    fi
    zle redisplay
  }
  zle -N _fzf_file_all_widget
  bindkey '^[t' _fzf_file_all_widget
fi

# --- Alt+W = fuzzy worktree switcher ---------------------------------------
if command -v fzf >/dev/null 2>&1; then
  _fzf_worktree_widget() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then return; fi
    local picked
    picked=$(git worktree list --porcelain | sed -n 's/^worktree //p' | fzf --prompt 'worktree> ')
    if [[ -n $picked ]]; then
      cd "$picked"
      zle reset-prompt
    fi
  }
  zle -N _fzf_worktree_widget
  bindkey '^[w' _fzf_worktree_widget
fi

# --- Alt+S = pick a Claude session and resume it; Alt+R = take over a background session ---
_wt_session_widget() { BUFFER="wt -s"; zle accept-line }
_wt_running_widget() { BUFFER="wt -r"; zle accept-line }
zle -N _wt_session_widget
zle -N _wt_running_widget
bindkey '^[s' _wt_session_widget
bindkey '^[r' _wt_running_widget

# --- wt = open/create a ~/dev/wt worktree and start Claude (same script as Windows) ---
wt() {
  local cdfile dir
  cdfile=$(mktemp)
  WT_CD_FILE=$cdfile pwsh -NoProfile -File /mnt/z/dev/.claude/wt/Open-DevWorktree.ps1 "$@"
  dir=$(<"$cdfile")
  rm -f "$cdfile"
  [[ -n $dir ]] && z "$dir"
}

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
