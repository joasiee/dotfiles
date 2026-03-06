#!/usr/bin/env sh
set -eu

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
DEFAULT_DIR="$HOME/.dotfiles"
REPO_URL="https://github.com/joasiee/dotfiles.git"

restore_backup() {
  dest="$1"
  backup=$(ls -1t "${dest}.bak."* 2>/dev/null | head -n 1 || true)
  if [ -n "$backup" ]; then
    mv "$backup" "$dest"
    echo "Restored backup for $dest"
  fi
}

unlink_if_ours() {
  src="$1"
  dest="$2"

  if [ -L "$dest" ]; then
    current=$(readlink "$dest")
    if [ "$current" = "$src" ]; then
      rm "$dest"
      echo "Removed symlink $dest"
      restore_backup "$dest"
    fi
  fi
}

unlink_if_ours "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
unlink_if_ours "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"

if [ -d "$HOME/.fzf" ]; then
  rm -rf "$HOME/.fzf"
  echo "Removed ~/.fzf"
fi

if [ -d "$DEFAULT_DIR/.git" ]; then
  origin_url=$(git -C "$DEFAULT_DIR" config --get remote.origin.url 2>/dev/null || true)
  if [ "$origin_url" = "$REPO_URL" ]; then
    rm -rf "$DEFAULT_DIR"
    echo "Removed $DEFAULT_DIR"
  else
    echo "Skipping $DEFAULT_DIR (different git remote)."
  fi
elif [ -d "$DEFAULT_DIR" ]; then
  echo "Skipping $DEFAULT_DIR (not a git repo)."
fi
