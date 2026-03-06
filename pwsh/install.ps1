#Requires -Version 5.1
<#
.SYNOPSIS
    Installs PowerShell dotfiles and required tools.
.DESCRIPTION
    Installs zoxide, fzf, and PSReadLine, then symlinks $PROFILE to the
    repo's profile file. Requires PowerShell 7 (pwsh).
.EXAMPLE
    # From a cloned repo:
    .\pwsh\install.ps1

    # One-liner (downloads and runs):
    irm https://raw.githubusercontent.com/joasiee/dotfiles/main/pwsh/install.ps1 | iex
.NOTES
    Symlink creation requires either Administrator privileges or
    Developer Mode enabled (Windows Settings > Developer Mode).
#>
[CmdletBinding()] param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$REPO_URL   = 'https://github.com/joasiee/dotfiles.git'
$DEFAULT_DIR = "$env:USERPROFILE\.dotfiles"

# ---------------------------------------------------------------------------

function Get-DotfilesDir {
    $scriptDir = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { $null }
    if ($scriptDir -and (Test-Path "$scriptDir\pwsh\Microsoft.PowerShell_profile.ps1")) {
        return $scriptDir
    }

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error 'git is required to clone the repo. Install Git first.'
        exit 1
    }

    if ((Test-Path "$DEFAULT_DIR\.git")) {
        git -C $DEFAULT_DIR pull --ff-only
    } elseif (-not (Test-Path $DEFAULT_DIR)) {
        git clone --depth 1 $REPO_URL $DEFAULT_DIR
    } else {
        Write-Error "$DEFAULT_DIR exists but is not a git repo."
        exit 1
    }

    return $DEFAULT_DIR
}

function Install-WingetPackage {
    param([string]$Id, [string]$Name)
    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-Host "$Name already installed."
        return
    }
    Write-Host "Installing $Id..."
    winget install --id $Id --accept-source-agreements --accept-package-agreements -e
}

function Set-ProfileLink {
    param([string]$Src, [string]$Dest)

    $destDir = Split-Path $Dest -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if (Test-Path $Dest) {
        $item = Get-Item $Dest -Force
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $Src) {
            Write-Host "Profile already linked."
            return
        }
        $ts = Get-Date -Format 'yyyyMMddHHmmss'
        Rename-Item $Dest "$Dest.bak.$ts" -Force
        Write-Host "Backed up existing profile."
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Dest -Target $Src -Force | Out-Null
        Write-Host "Linked: $Dest -> $Src"
    } catch {
        Write-Warning "Could not create symlink (run as Admin or enable Developer Mode)."
        Write-Warning "Falling back to dot-source stub."
        Set-Content -Path $Dest -Value ". '$Src'"
        Write-Host "Created stub: $Dest"
    }
}

# ---------------------------------------------------------------------------

$dotfilesDir = Get-DotfilesDir
$profileSrc  = "$dotfilesDir\pwsh\Microsoft.PowerShell_profile.ps1"

# 1. Install tools via winget
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Install-WingetPackage 'ajeetdsouza.zoxide' 'zoxide'
    Install-WingetPackage 'junegunn.fzf'       'fzf'
} else {
    Write-Warning 'winget not found. Install tools manually:'
    Write-Warning '  zoxide: https://github.com/ajeetdsouza/zoxide#installation'
    Write-Warning '  fzf:    https://github.com/junegunn/fzf#windows'
}

# 2. Ensure PSReadLine >= 2.3
$psrl = Get-Module -ListAvailable -Name PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
if (-not $psrl -or $psrl.Version -lt [version]'2.3.0') {
    Write-Host 'Installing/updating PSReadLine...'
    Install-Module PSReadLine -Scope CurrentUser -Force -AllowClobber
}

# 3. Symlink profile
Set-ProfileLink -Src $profileSrc -Dest $PROFILE

# 4. Report missing tools
Write-Host ''
$missing = @()
if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) { $missing += 'zoxide' }
if (-not (Get-Command fzf    -ErrorAction SilentlyContinue)) { $missing += 'fzf' }
if ($missing.Count -gt 0) {
    Write-Warning "Still missing: $($missing -join ', '). Restart your terminal and re-run, or install manually."
} else {
    Write-Host 'All dependencies installed. Restart your terminal for the profile to take effect.'
}
