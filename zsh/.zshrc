# User-installed commands, including Codex.
typeset -U path
path=("$HOME/.local/bin" $path)
# fzf installed by install.sh lives in ~/.fzf/bin
[[ -d "$HOME/.fzf/bin" ]] && path=("$HOME/.fzf/bin" $path)
export PATH

alias codex='codex --yolo'

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

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

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
  alias cd='z'
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

# --- Alt+S = fuzzy pick an earlier Claude session, cd to its folder and resume it ---
if command -v fzf >/dev/null 2>&1 && [[ -x /mnt/z/dev/.claude/wt/bin/wt-index-linux ]]; then
  claude_resume_session() {
    local picked id dir
    picked=$(/mnt/z/dev/.claude/wt/bin/wt-index-linux -cache /mnt/z/dev/.claude/wt/cache/linux -fzf |
      fzf --ansi --tiebreak=index --reverse --height 60% --prompt 'session> ' --delimiter $'\t' --with-nth 1 --query "$*") || return 0
    id=${${picked#*$'\t'}%%$'\t'*}
    dir=${picked##*$'\t'}
    print -P "%F{green}${dir//\%/%%}%f"
    (( $+commands[zoxide] )) && zoxide add -- "$dir"
    builtin cd -- "$dir" && claude --resume "$id"
  }
  _claude_resume_widget() { BUFFER="claude_resume_session"; zle accept-line }
  zle -N _claude_resume_widget
  bindkey '^[s' _claude_resume_widget
fi

# --- Alt+R = fuzzy pick a running background Claude session and move it into this terminal ---
if command -v fzf >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  # Prints one tab-separated line per background session, newest first: display, id, sessionId, cwd, status, pid, name
  _claude_background_lines() {
    claude agents --json | python3 -c '
import json, os, sys, time
now = time.time() * 1000
bg = [a for a in json.load(sys.stdin) if a.get("kind") == "background"]
for a in sorted(bg, key=lambda a: a.get("startedAt", 0), reverse=True):
    minutes = int((now - a.get("startedAt", now)) // 60000)
    age = "%dh" % (minutes // 60) if minutes >= 60 else "%dm" % minutes
    # Yellow waits for you, green is working, grey is idle
    color = 33 if a.get("state") == "blocked" else 32 if a.get("status") == "busy" else 90
    state = str(a.get("state") or "").ljust(8)
    name = a.get("name") or ""
    leaf = os.path.basename(a["cwd"].rstrip("/"))
    shown = "\x1b[%dm%s\x1b[0m  %s  \x1b[36m%s\x1b[0m  \x1b[90m%s  %s\x1b[0m" % (color, state, name, leaf, age, a["id"])
    print(shown, a["id"], a["sessionId"], a["cwd"], a.get("status") or "", a.get("pid") or "", name, sep="\t")
'
  }
  claude_resume_background() {
    local lines picked answer transcript
    local -a f
    lines=$(_claude_background_lines) || return
    if [[ -z $lines ]]; then print -P '%F{8}No background sessions are running%f'; return 0; fi
    picked=$(print -r -- "$lines" | fzf --ansi --reverse --height 40% --prompt 'background> ' --delimiter $'\t' --with-nth 1) || return 0
    f=("${(@ps:\t:)picked}")
    local id=$f[2] sid=$f[3] dir=$f[4] sess_status=$f[5] pid=$f[6] name=$f[7]
    if [[ $sess_status == busy ]]; then
      read -r "answer?$name is mid-turn: [s]top the turn and take it over, [a]ttach and keep it in the background: "
      if [[ $answer == a ]]; then claude attach "$id"; return; fi
      [[ $answer == s ]] || return 0
    fi
    # A session that never got a prompt has no transcript to resume, so attach to keep its launch flags
    transcript="$HOME/.claude/projects/${dir//[^A-Za-z0-9]/-}/$sid.jsonl"
    if [[ ! -f $transcript ]]; then claude attach "$id"; return; fi
    claude stop "$id" >/dev/null
    # Resuming while the background process still runs would start a second copy of the session
    local deadline=$(( SECONDS + 15 ))
    while [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null && (( SECONDS < deadline )); do sleep 0.2; done
    print -P "%F{green}${name//\%/%%}  [${dir//\%/%%}]%f"
    (( $+commands[zoxide] )) && zoxide add -- "$dir"
    builtin cd -- "$dir" && claude --resume "$sid"
  }
  _claude_background_widget() { BUFFER="claude_resume_background"; zle accept-line }
  zle -N _claude_background_widget
  bindkey '^[r' _claude_background_widget
fi

if [[ -r "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Bun (preserve a custom installation directory).
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
path=("$BUN_INSTALL/bin" $path)

# Bun completions.
if [[ -s "$BUN_INSTALL/_bun" ]]; then
  source "$BUN_INSTALL/_bun"
fi

# Background auto-mode Claude orchestrator with a slim context: instructions.md only, no skills, tickr the only MCP
so() {
  (builtin cd ~/dev/.claude/orchestrator && claude --bg --permission-mode auto -n orchestrator --settings settings.json --setting-sources user --mcp-config mcp.json --strict-mcp-config --disable-slash-commands --append-system-prompt-file instructions.md "$@")
}
