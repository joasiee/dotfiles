# Minimal Zsh config inspired by https://rushter.com/blog/zsh-shell/
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt autocd

autoload -U compinit; compinit

# Prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# History search
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# Vim mode
set -o vi
# Fix for backspace in vi mode
bindkey -v '^?' backward-delete-char
