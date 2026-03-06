#!/usr/bin/env sh
set -eu

REPO_URL="https://github.com/joasiee/dotfiles.git"
FZF_REPO_URL="https://github.com/junegunn/fzf.git"
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
  $SUDO apt-get install -y zsh curl git

  if ! command -v zoxide >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
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

fzf_version() {
  fzf --version 2>/dev/null | awk '{print $1}'
}

version_ge() {
  [ "$1" = "$2" ] && return 0
  printf '%s\n%s\n' "$2" "$1" | sort -V | head -n 1 | grep -qx "$2"
}

install_fzf_latest() {
  if [ -d "$HOME/.fzf/.git" ]; then
    git -C "$HOME/.fzf" pull --ff-only
  else
    git clone --depth 1 "$FZF_REPO_URL" "$HOME/.fzf"
  fi

  "$HOME/.fzf/install" --bin --no-update-rc --no-bash --no-fish --key-bindings --completion
}

ensure_fzf() {
  if command -v fzf >/dev/null 2>&1; then
    if version_ge "$(fzf_version)" "0.48.0"; then
      return 0
    fi
  fi

  if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
    if ! install_deps_ubuntu; then
      echo "Error: git and curl are required to install fzf."
      return 1
    fi
  fi

  install_fzf_latest
}

ensure_repo

ensure_fzf || true

if [ -d "$HOME/.fzf/bin" ]; then
  PATH="$HOME/.fzf/bin:$PATH"
  export PATH
fi

link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"

echo "Linked Zsh dotfiles."

missing=""
if ! command -v zsh >/dev/null 2>&1; then
  missing="${missing} zsh"
fi
if ! command -v fzf >/dev/null 2>&1; then
  missing="${missing} fzf"
fi
if ! command -v zoxide >/dev/null 2>&1; then
  missing="${missing} zoxide"
fi

if [ -n "$missing" ]; then
  echo ""
  echo "Missing tools:${missing}"
  echo "Attempting Ubuntu install..."
  if install_deps_ubuntu; then
    echo "Installed dependencies (Ubuntu)."
  else
    echo "Ubuntu install not available. Install the missing tools manually:"
    echo "  zoxide: curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
    echo "  fzf:    https://github.com/junegunn/fzf#installation"
  fi
fi

if command -v zsh >/dev/null 2>&1; then
  if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo ""
    echo "To set zsh as your login shell:"
    echo "  chsh -s \"$(command -v zsh)\""
  fi
fi
