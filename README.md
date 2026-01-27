# dotfiles

Minimal Zsh setup inspired by Rushter's Zsh article.

## Quick start

Copy/paste to install:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/joasiee/dotfiles/main/install.sh)"
```

## What it does

- Symlinks `zsh/.zshrc` to `~/.zshrc`
- Symlinks `zsh/.config/starship.toml` to `~/.config/starship.toml`
- Installs missing dependencies on Ubuntu (via `apt-get` + Starship installer)
- Installs or upgrades `fzf` from the official git repo if it's missing or older
- Prints a warning if dependencies are missing and Ubuntu install isn't available

## Layout

- `zsh/.zshrc`
- `zsh/.config/starship.toml`
- `install.sh`

## Dependencies

- `zsh`
- `starship`
- `fzf`

Set your login shell to zsh after installing dependencies.

## fzf shortcuts

- `Ctrl+R` history search
- `Ctrl+T` file search
- `Alt+C` change directory
