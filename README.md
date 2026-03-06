# dotfiles

Minimal shell setup for Zsh (Linux/macOS) and PowerShell 7 (Windows).

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
- `~/.dotfiles` only if it matches this repo

### What it does

- Symlinks `zsh/.zshrc` to `~/.zshrc`
- Installs or upgrades `fzf` from the official git repo if it's missing or older
- Prints a warning if dependencies are missing and Ubuntu install isn't available

### Layout

- `zsh/.zshrc`
- `install.sh`

### Dependencies

- `zsh`
- `fzf`
- `zoxide`

Set your login shell to zsh after installing dependencies.

### Key bindings

- `Ctrl+R` fzf history search (cross-session)
- `Ctrl+T` fuzzy file picker (`fd` if available, else `find`)
- `Ctrl+F` fuzzy directory picker
- `Alt+J` zoxide interactive jump (`zi`)
- `Alt+G` fuzzy git branch checkout
- `Up/Down` substring history search

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
