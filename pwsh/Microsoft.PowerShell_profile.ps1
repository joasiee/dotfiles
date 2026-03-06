# --- Core Helpers -----------------------------------------------------------

function Open-Solution {
    param(
        [Parameter(Mandatory = $true)][string]$MainPath,
        [Parameter(Mandatory = $true)][string]$DefaultPath
    )
    if (Test-Path $MainPath) { Start-Process $MainPath }
    elseif (Test-Path $DefaultPath) { Start-Process $DefaultPath }
    else { Write-Error "Solution not found at either path: $MainPath or $DefaultPath" }
}

function Open-Folder {
    param(
        [Parameter(Mandatory = $true)][string]$MainPath,
        [Parameter(Mandatory = $true)][string]$DefaultPath
    )
    if (Test-Path $MainPath) { code $MainPath }
    elseif (Test-Path $DefaultPath) { code $DefaultPath }
    else { Write-Error "Folder not found at either path: $MainPath or $DefaultPath" }
}

function Start-NpmProject {
    param(
        [Parameter(Mandatory = $true)][string]$MainPath,
        [Parameter(Mandatory = $true)][string]$DefaultPath
    )
    if (Test-Path $MainPath) { Set-Location $MainPath }
    elseif (Test-Path $DefaultPath) { Set-Location $DefaultPath }
    else { Write-Error "Folder not found: $MainPath or $DefaultPath"; return }
    npm install
    npm start
}

function Start-BunProject {
    param(
        [Parameter(Mandatory = $true)][string]$MainPath,
        [Parameter(Mandatory = $true)][string]$DefaultPath
    )
    if (Test-Path $MainPath) { Set-Location $MainPath }
    elseif (Test-Path $DefaultPath) { Set-Location $DefaultPath }
    else { Write-Error "Folder not found: $MainPath or $DefaultPath"; return }
    bun install
    bun start
}

# --- Project Specifics ------------------------------------------------------

# .NET Solutions
function Open-ZenzAirSolution {
    Open-Solution -MainPath ".\Main\ZenzAir\ZenzAir\ZenzAir.sln" -DefaultPath ".\ZenzAir\ZenzAir\ZenzAir.sln"
}

function Open-ZenzAirProcessorSolution {
    Open-Solution -MainPath ".\Main\ZenzAir\ZenzAirProcessor\ZenzAirProcessor.sln" -DefaultPath ".\ZenzAir\ZenzAirProcessor\ZenzAirProcessor.sln"
}

# Web - New (ZenzAirWeb - Bun)
function Open-ZenzWeb-New { Open-Folder -MainPath ".\Main\ZenzAirWeb" -DefaultPath ".\ZenzAirWeb" }
function Start-ZenzWeb-New { Start-BunProject -MainPath ".\Main\ZenzAirWeb" -DefaultPath ".\ZenzAirWeb" }

# Web - Legacy (ZenzWeb - NPM)
function Open-ZenzWeb-Legacy { Open-Folder -MainPath ".\Main\ZenzWeb\zenz_web" -DefaultPath ".\ZenzWeb\zenz_web" }
function Start-ZenzWeb-Legacy { Start-NpmProject -MainPath ".\Main\ZenzWeb\zenz_web" -DefaultPath ".\ZenzWeb\zenz_web" }

# --- Git & System Utilities -------------------------------------------------

function Add-GitWorktree {
    param([Parameter(Mandatory = $true)][string]$BranchName)
    $curdirname = Split-Path -Path (Get-Location) -Leaf
    git worktree add -b $BranchName "../$BranchName/$curdirname" && z "../$BranchName/$curdirname"
}

function Add-GitWorktreeExisting {
    param([Parameter(Mandatory = $true)][string]$BranchName)
    $curdirname = Split-Path -Path (Get-Location) -Leaf
    git worktree add "../$BranchName/$curdirname" $BranchName && z "../$BranchName/$curdirname"
}

function zg {
    param([Parameter(Position = 0)][string]$SubCommand)
    switch ($SubCommand) {
        "amend" { git commit --amend --no-edit }
        default { Write-Host "Unknown subcommand: $SubCommand" }
    }
}

function Enable-MSVC {
    [CmdletBinding()] param([string]$Version, [string]$Arch = "x64")
    $vsPath = & vswhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if (-not $vsPath) { Write-Error "Visual Studio installation not found"; return $false }
    $vcvarsPath = Join-Path $vsPath "VC\Auxiliary\Build\vcvarsall.bat"
    if (-not (Test-Path $vcvarsPath)) { Write-Error "vcvarsall.bat not found"; return $false }

    Push-Location (Split-Path $vcvarsPath)
    $cmd = if ($Version) { "vcvarsall.bat $Arch -vcvars_ver=$Version" } else { "vcvarsall.bat $Arch" }
    cmd /c "$cmd & set" | ForEach-Object {
        if ($_ -match "(.+)=(.+)") { Set-Item -Force "env:\$($matches[1])" $matches[2] }
    }
    Pop-Location
    return $true
}

function vccode {
    param([Parameter(Position = 0, ValueFromRemainingArguments = $true)][string[]]$Args)
    if (Enable-MSVC) { & "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd" $Args }
    else { Write-Error "Failed to initialize MSVC." }
}

function rmrf { rm -Recurse -Force $args }

# --- Version Jumping & Navigation -------------------------------------------

function Set-ZenzVersionDirectory {
    param([Parameter(Mandatory = $true)][string]$Version)
    $path = "Z:\$Version"
    if (Test-Path $path) { Set-Location $path }
    else { Write-Error "Directory not found: $path" }
}

function v {
    param([Parameter(Mandatory=$true)][string]$Version)
    if ($Version -notmatch '^v?\d{3,}$') { Write-Error "Use v###"; return }
    $ver = if ($Version.StartsWith('v')) { $Version } else { 'v' + $Version }
    Set-ZenzVersionDirectory -Version $ver
}

# Auto-generate v001, v002 commands
if (Test-Path 'Z:\') {
    Get-ChildItem -Path 'Z:\' -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^v\d{3,}$' } |
        ForEach-Object {
            $ver = $_.Name
            Set-Item -Path "Function:\$ver" -Value ([scriptblock]::Create("Set-ZenzVersionDirectory -Version '$ver'")) -Force
        }
}

function Set-MainDirectory { Set-Location "Z:\zenz\main" }

# --- Aliases & Initialization -----------------------------------------------

# Solutions
Set-Alias za Open-ZenzAirSolution
Set-Alias zp Open-ZenzAirProcessorSolution

# Web Opening
Set-Alias zw  Open-ZenzWeb-New      # New (Bun/ZenzAirWeb)
Set-Alias zwo Open-ZenzWeb-Legacy   # Old (Npm/ZenzWeb)

# Web Starting
Set-Alias zwx  Start-ZenzWeb-New    # New (Bun/ZenzAirWeb)
Set-Alias zwxo Start-ZenzWeb-Legacy # Old (Npm/ZenzWeb)

# Git & Nav
Set-Alias gwa  Add-GitWorktree
Set-Alias gwae Add-GitWorktreeExisting
Set-Alias main Set-MainDirectory
Set-Alias gs   Get-GitStatus
Set-Alias gpb  Switch-GitPreviousBranch
Set-Alias grep Select-String

function Get-GitStatus { git status }
function Switch-GitPreviousBranch { git checkout - }

# ---- Dependencies ----
Import-Module PSReadLine
$env:_ZO_EXCLUDE_DIRS = "\\*"
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Good defaults
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

# Helper: pick one item with fzf, returning string or $null
function Invoke-FzfPick {
    param(
        [Parameter(Mandatory=$true)]
        [string[]] $Items,
        [string[]] $FzfArgs = @()
    )
    if (-not $Items -or $Items.Count -eq 0) { return $null }
    $picked = $Items | fzf @FzfArgs
    if ([string]::IsNullOrWhiteSpace($picked)) { return $null }
    return $picked
}

# 1) Ctrl+R = fzf history search (reads PSReadLine history file, works across sessions)
Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
    try {
        $histPath = (Get-PSReadLineOption).HistorySavePath
        if (-not (Test-Path $histPath)) { return }

        $picked = Get-Content -Path $histPath -ErrorAction Stop |
            Where-Object { $_ -and $_.Trim() } |
            fzf --tac --no-sort

        if ($picked) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($picked)
        }
    } catch {
        # silently ignore
    }
}

# 2) Alt+J = zoxide interactive jump
Set-PSReadLineKeyHandler -Key Alt+j -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("zi")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# 3) Ctrl+T = fuzzy file picker (fd if available, fallback to Get-ChildItem)
Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock {
    try {
        $hasFd = (Get-Command fd -ErrorAction SilentlyContinue) -ne $null
        if ($hasFd) {
            $picked = & fd --type f --hidden --follow --exclude .git 2>$null | fzf
        } else {
            $picked = Get-ChildItem -File -Recurse -Force -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty FullName |
                fzf
        }

        if ($picked) {
            $toInsert = if ($picked -match '\s') { '"' + $picked + '"' } else { $picked }
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($toInsert)
        }
    } catch {
        # silently ignore
    }
}

# 4) Ctrl+F = fuzzy directory picker (within current tree)
Set-PSReadLineKeyHandler -Key Ctrl+f -ScriptBlock {
    try {
        $hasFd = (Get-Command fd -ErrorAction SilentlyContinue) -ne $null
        if ($hasFd) {
            $picked = & fd --type d --hidden --follow --exclude .git 2>$null | fzf
        } else {
            $picked = Get-ChildItem -Directory -Recurse -Force -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty FullName |
                fzf
        }

        if ($picked) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            Set-Location $picked
            [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        }
    } catch {
        # silently ignore
    }
}

# 5) Alt+G = fuzzy git branch checkout (local + remote, de-duped)
Set-PSReadLineKeyHandler -Key Alt+g -ScriptBlock {
    try {
        & git rev-parse --is-inside-work-tree *> $null
        if ($LASTEXITCODE -ne 0) { return }

        $refs = & git for-each-ref --format="%(refname:short)" refs/heads refs/remotes 2>$null |
            Where-Object { $_ -and ($_ -notmatch '^origin/HEAD$') } |
            Sort-Object -Unique

        $picked = $refs | fzf --prompt "git checkout> " --no-sort
        if (-not $picked) { return }

        if ($picked -match '^[^/]+/.+') {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("git checkout -t $picked")
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("git checkout $picked")
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        }
    } catch {
        # silently ignore
    }
}

# Up/Down = substring history search
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Ctrl+L = clear screen
Set-PSReadLineKeyHandler -Key Ctrl+l -Function ClearScreen
