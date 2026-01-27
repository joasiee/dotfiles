# Minimal Zsh config inspired by https://rushter.com/blog/zsh-shell/
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt autocd

autoload -U compinit; compinit

# Vim mode
set -o vi
# Fix for backspace in vi mode
bindkey -v '^?' backward-delete-char

# Prompt
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
if command -v starship >/dev/null 2>&1; then
  eval "$(STARSHIP_CONFIG="$HOME/.config/starship.toml" starship init zsh)"
fi

# History search (compat: older fzf lacks --zsh)
if command -v fzf >/dev/null 2>&1; then
  if [ -f "$HOME/.fzf.zsh" ]; then
    # fzf installer-generated script
    source "$HOME/.fzf.zsh"
  elif fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  elif [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
  elif [ -f /etc/profile.d/fzf.zsh ]; then
    source /etc/profile.d/fzf.zsh
  fi

  # Ensure Ctrl-R is bound in vi insert mode
  bindkey -M viins '^R' fzf-history-widget 2>/dev/null || true
  bindkey -M emacs '^R' fzf-history-widget 2>/dev/null || true
fi

# Fallback history widget when fzf key-bindings are unavailable
if command -v fzf >/dev/null 2>&1; then
  if ! typeset -f fzf-history-widget >/dev/null 2>&1; then
    fzf-history-widget() {
      local selected
      selected=$(
        fc -rl 1 | awk '{$1=""; sub(/^ /,""); print }' | \
          fzf --tac --no-sort --query="$LBUFFER" \
              --height=40% --layout=reverse --prompt="History> " \
              --bind=ctrl-r:toggle-sort
      )
      if [ -n "$selected" ]; then
        LBUFFER="$selected"
      fi
      zle redisplay
    }
    zle -N fzf-history-widget
    bindkey -M viins '^R' fzf-history-widget
    bindkey -M emacs '^R' fzf-history-widget
  fi
fi
