# dotfiles

Shell and terminal setup for Zsh and Ghostty (Linux/macOS), and PowerShell 7 (Windows).

---

## Zsh (Linux / macOS)

### Quick start

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/joasiee/dotfiles/main/install.sh)"
```

### Uninstall

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/joasiee/dotfiles/main/uninstall.sh)"
```

This removes:
- Symlinks created by the installer (and restores latest backups)
- `~/.fzf`
- `~/.tmux/plugins/tpm` and `~/.tmux/plugins/tmux-sensible` if installed from the official repo
- `~/.dotfiles` only if it matches this repo

### What it does

- Symlinks `zsh/.zshrc` to `~/.zshrc`
- Symlinks `tmux/.tmux.conf` to `~/.tmux.conf`
- Symlinks `ghostty/config.ghostty` to `${XDG_CONFIG_HOME:-~/.config}/ghostty/config.ghostty`
- Backs up existing files before linking; uninstall restores the latest backups
- Installs or upgrades `fzf` from the official git repo if it's missing or older
- Installs `tmux` on Ubuntu when available
- Installs Ghostty on Arch/CachyOS via `pacman`, or macOS via Homebrew, if missing
- Installs TPM and the `tmux-sensible` plugin
- Prints a warning if dependencies are missing and Ubuntu install isn't available

### Layout

- `zsh/.zshrc`
- `tmux/.tmux.conf`
- `ghostty/config.ghostty`
- `install.sh`

### Dependencies

- `zsh`
- `fzf`
- `zoxide`
- `tmux`
- `ghostty` (optional graphical terminal)

Set your login shell to zsh after installing dependencies.

The shell adds `~/.local/bin` and `${BUN_INSTALL:-~/.bun}/bin` to PATH without
duplicates, loads Bun completions when present, and uses zoxide for `cd` when
available. Optional `direnv` and `~/.zsh/zsh-autosuggestions` integrations are
loaded only when installed. The `codex` alias runs `codex --yolo`, disabling
approval prompts and sandbox protections.

The WSL-specific `wt` helper and its `Alt+S` / `Alt+R` session shortcuts are
enabled only when `pwsh` and `/mnt/z/dev/.claude/wt/Open-DevWorktree.ps1` exist.
See the [tmux quick start](tmux/QUICKSTART.md) for pane and window controls.

### Key bindings

- `Ctrl+R` fzf history search (cross-session)
- `Ctrl+T` fuzzy file picker (`fd` if available, else `find`)
- `Ctrl+F` fuzzy directory picker
- `Alt+J` zoxide interactive jump (`zi`)
- `Alt+G` fuzzy git branch checkout
- `Alt+T` fuzzy file picker including ignored files
- `Alt+W` fuzzy Git worktree switcher
- `Up/Down` substring history search

### Ghostty

The config preserves the local pane and clipboard shortcuts:

- `Alt+Shift+-` splits below; `Alt+Shift++` splits to the right
- `Alt+Arrow` moves between panes
- `Alt+Shift+Arrow` resizes the focused pane
- `Ctrl+Shift+W` closes the focused pane
- `Ctrl+V` pastes from the clipboard
- New panes inherit the active pane's working directory

Reload with `Ctrl+Shift+,` on Linux or `Cmd+Shift+,` on macOS.
The config uses the `config.ghostty` filename supported since Ghostty 1.2.3.
Existing legacy `ghostty/config` files and macOS configs under
`~/Library/Application Support/com.mitchellh.ghostty/` can override these settings.
See the [Ghostty configuration docs](https://ghostty.org/docs/config).

On other distributions (including Ubuntu), or macOS without Homebrew, install
Ghostty using the [installation docs](https://ghostty.org/docs/install/binary).
The installer still links its config when automatic installation is unavailable.
Uninstall removes the config symlink and restores its backup, leaving the Ghostty
application installed.

---

## PowerShell 7 (Windows)

### Quick start

```powershell
irm https://raw.githubusercontent.com/joasiee/dotfiles/main/pwsh/install.ps1 | iex
```

Or from a cloned repo:

```powershell
.\pwsh\install.ps1
```

> Symlink creation requires **Administrator** privileges or **Developer Mode** enabled
> (Windows Settings > Privacy & security > For developers > Developer Mode).
> Without either, the installer falls back to a dot-source stub.

### Uninstall

```powershell
.\pwsh\uninstall.ps1
```

### What it does

- Installs `zoxide` and `fzf` via `winget`
- Installs/updates `PSReadLine` >= 2.3 via `Install-Module`
- Symlinks `$PROFILE` to `pwsh/Microsoft.PowerShell_profile.ps1`

### Layout

- `pwsh/Microsoft.PowerShell_profile.ps1`
- `pwsh/install.ps1`
- `pwsh/uninstall.ps1`

### Dependencies

- `zoxide`
- `fzf`
- `PSReadLine` >= 2.3

### Key bindings

- `Ctrl+R` fzf history search (cross-session, reads PSReadLine history file)
- `Ctrl+T` fuzzy file picker (`fd` if available, else `Get-ChildItem`)
- `Ctrl+F` fuzzy directory picker (navigate within current tree)
- `Alt+J` zoxide interactive jump (`zi`)
- `Alt+G` fuzzy git branch checkout
- `Up/Down` substring history search
