#!/usr/bin/env sh
set -eu

REPO_URL="https://github.com/joasiee/dotfiles.git"
DEFAULT_DIR="$HOME/.dotfiles"

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd 2>/dev/null || printf "%s" "$DEFAULT_DIR")

install_deps_ubuntu() {
  if ! command -v apt-get >/dev/null 2>&1; then
    return 1
  fi

  if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
  else
    SUDO="sudo"
  fi

  $SUDO apt-get update
  $SUDO apt-get install -y zsh fzf curl git

  # Prefer official starship installer on Linux
  if ! command -v starship >/dev/null 2>&1; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  fi
}

ensure_repo() {
  if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
    return 0
  fi

  DOTFILES_DIR="$DEFAULT_DIR"

  if [ -e "$DOTFILES_DIR" ] && [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "Error: $DOTFILES_DIR exists but is not a git repo."
    exit 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    if ! install_deps_ubuntu; then
      echo "Error: git is required to clone the repo."
      exit 1
    fi
  fi

  if [ -d "$DOTFILES_DIR/.git" ]; then
    git -C "$DOTFILES_DIR" pull --ff-only
  else
    git clone --depth 1 "$REPO_URL" "$DOTFILES_DIR"
  fi
}

link_file() {
  src="$1"
  dest="$2"

  if [ -L "$dest" ]; then
    current=$(readlink "$dest")
    if [ "$current" = "$src" ]; then
      return 0
    fi
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    ts=$(date +%Y%m%d%H%M%S)
    mv "$dest" "${dest}.bak.${ts}"
  fi

  dest_dir=$(dirname "$dest")
  if [ ! -d "$dest_dir" ]; then
    mkdir -p "$dest_dir"
  fi

  ln -s "$src" "$dest"
}

ensure_repo

link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.config/starship.toml" "$HOME/.config/starship.toml"

echo "Linked Zsh dotfiles."

missing=""
if ! command -v zsh >/dev/null 2>&1; then
  missing="${missing} zsh"
fi
if ! command -v starship >/dev/null 2>&1; then
  missing="${missing} starship"
fi
if ! command -v fzf >/dev/null 2>&1; then
  missing="${missing} fzf"
fi

if [ -n "$missing" ]; then
  echo ""
  echo "Missing tools:${missing}"
  echo "Attempting Ubuntu install..."
  if install_deps_ubuntu; then
    echo "Installed dependencies (Ubuntu)."
  else
    echo "Ubuntu install not available. Install the missing tools manually."
  fi
fi

if command -v zsh >/dev/null 2>&1; then
  if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo ""
    echo "To set zsh as your login shell:"
    echo "  chsh -s \"$(command -v zsh)\""
  fi
fi
