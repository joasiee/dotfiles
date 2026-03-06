#Requires -Version 5.1
<#
.SYNOPSIS
    Removes the PowerShell profile symlink/stub and restores the latest backup.
.EXAMPLE
    .\pwsh\uninstall.ps1
#>
[CmdletBinding()] param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir  = Split-Path $PSScriptRoot -Parent
$profileSrc = "$scriptDir\pwsh\Microsoft.PowerShell_profile.ps1"

function Restore-Backup {
    param([string]$Path)
    $backup = Get-ChildItem -Path (Split-Path $Path -Parent) -Filter "$(Split-Path $Path -Leaf).bak.*" -Force -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        Select-Object -First 1
    if ($backup) {
        Move-Item $backup.FullName $Path -Force
        Write-Host "Restored backup: $($backup.Name)"
    }
}

function Remove-ProfileLink {
    param([string]$Src, [string]$Dest)
    if (-not (Test-Path $Dest -PathType Leaf)) { return }

    $item = Get-Item $Dest -Force

    # Remove symlink pointing at our file
    if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $Src) {
        Remove-Item $Dest -Force
        Write-Host "Removed symlink: $Dest"
        Restore-Backup -Path $Dest
        return
    }

    # Remove dot-source stub created as fallback
    $content = Get-Content $Dest -Raw -ErrorAction SilentlyContinue
    if ($content -and $content.Trim() -eq ". '$Src'") {
        Remove-Item $Dest -Force
        Write-Host "Removed stub: $Dest"
        Restore-Backup -Path $Dest
        return
    }

    Write-Host "Skipping $Dest (not managed by dotfiles)."
}

Remove-ProfileLink -Src $profileSrc -Dest $PROFILE
