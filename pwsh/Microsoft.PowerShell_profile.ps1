# --- Core Helpers -----------------------------------------------------------

function Open-Solution {
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    $root = git rev-parse --show-toplevel
    $path = Join-Path $root $RelativePath
    if (Test-Path $path) { Start-Process $path }
    else { Write-Error "Solution not found: $path" }
}

function Open-Folder {
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    $root = git rev-parse --show-toplevel
    $path = Join-Path $root $RelativePath
    if (Test-Path $path) { code $path }
    else { Write-Error "Folder not found: $path" }
}

function Start-NpmProject {
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    $root = git rev-parse --show-toplevel
    $path = Join-Path $root $RelativePath
    if (-not (Test-Path $path)) { Write-Error "Folder not found: $path"; return }
    Set-Location $path
    npm install
    npm start
}

function Start-BunProject {
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    $root = git rev-parse --show-toplevel
    $path = Join-Path $root $RelativePath
    if (-not (Test-Path $path)) { Write-Error "Folder not found: $path"; return }
    Set-Location $path
    bun install
    bun start
}

# --- Project Specifics ------------------------------------------------------

# .NET Solutions
function Open-ZenzAirSolution {
    Open-Solution "ZenzAir/ZenzAir/ZenzAir.sln"
}

function Open-ZenzAirProcessorSolution {
    Open-Solution "ZenzAir/ZenzAirProcessor/ZenzAirProcessor.sln"
}

# Web - New (ZenzAirWeb - Bun)
function Open-ZenzWeb-New { Open-Folder "ZenzAirWeb" }
function Start-ZenzWeb-New { Start-BunProject "ZenzAirWeb" }

# Web - Legacy (ZenzWeb - NPM)
function Open-ZenzWeb-Legacy { Open-Folder "ZenzWeb/zenz_web" }
function Start-ZenzWeb-Legacy { Start-NpmProject "ZenzWeb/zenz_web" }

# --- Git & System Utilities -------------------------------------------------

function Add-GitWorktree {
    param(
        [Parameter(Mandatory = $true)][string]$BranchName,
        [Parameter(Mandatory = $true)][string]$Version,
        [switch]$Main
    )
    if ($Main) { $BranchName = "$BranchName/Main" }
    $baseBranch = "origin/PRD/Release_$Version"
    $worktreePath = "Z:/dev/" + $BranchName.ToLower()
    git worktree add -b $BranchName $worktreePath $baseBranch
    if ($LASTEXITCODE -eq 0) { z $worktreePath }
}

function Add-GitWorktreeExisting {
    param(
        [Parameter(Mandatory = $true)][string]$BranchName,
        [switch]$Main
    )
    if ($Main) { $BranchName = "$BranchName/Main" }
    $worktreePath = "Z:/dev/" + $BranchName.ToLower()
    git worktree add $worktreePath $BranchName
    if ($LASTEXITCODE -eq 0) {
        git -C $worktreePath branch --set-upstream-to=origin/$BranchName $BranchName
        z $worktreePath
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

function lsh { Get-ChildItem -Force @args }

function Start-DevEnv { Start-Process devenv . }

# --- Version Jumping & Navigation -------------------------------------------


function Set-MainDirectory { Set-Location "Z:\zenz\main" }
function Set-DevDirectory { Set-Location "Z:\dev" }
function Set-Dev1Directory { z "Z:\dev\dev1" }
function Set-Dev2Directory { z "Z:\dev\dev2" }
function Set-Dev3Directory { z "Z:\dev\dev3" }

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
Set-Alias gwa   Add-GitWorktree
Set-Alias gwae  Add-GitWorktreeExisting
Set-Alias main Set-MainDirectory
Set-Alias dev  Set-DevDirectory
Set-Alias dev1 Set-Dev1Directory
Set-Alias dev2 Set-Dev2Directory
Set-Alias dev3 Set-Dev3Directory
Set-Alias gs   Get-GitStatus
Set-Alias gpb  Switch-GitPreviousBranch # git checkout -
Set-Alias -Force gm Invoke-GitCommitAll  # git commit -a -m
Set-Alias grep Select-String
Set-Alias dv   Start-DevEnv

function Get-GitStatus { git status }
function Switch-GitPreviousBranch { git checkout - }
function Invoke-GitCommitAll {
    param([Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)][string[]]$Message)
    git commit -a -m ($Message -join ' ')
}

function prompt {
  $loc = $executionContext.SessionState.Path.CurrentLocation;

$out = ""
  if ($loc.Provider.Name -eq "FileSystem") {
    $out += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
  }
  $out += "PS $loc$('>' * ($nestedPromptLevel + 1)) ";
  return $out
}

# ---- Dependencies ----
$env:_ZO_EXCLUDE_DIRS = "\\*"

# Cache zoxide init to avoid spawning an external process on every session.
# Regenerates automatically when the zoxide binary is updated.
$_zCache = "$env:TEMP\zoxide_ps_init.ps1"
$_zExe   = (Get-Command zoxide -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue)
if ($_zExe -and (-not (Test-Path $_zCache) -or
        (Get-Item $_zExe).LastWriteTime -gt (Get-Item $_zCache).LastWriteTime)) {
    zoxide init powershell | Set-Content $_zCache -Encoding UTF8
}
if (Test-Path $_zCache) { . $_zCache }
Remove-Variable _zCache, _zExe -ErrorAction SilentlyContinue

# Good defaults
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -HistoryNoDuplicates

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

# 1) Ctrl+R = fzf history search (BEST version: reads PSReadLine history file)
# - Works across sessions
# - Much bigger history than Get-History
Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
    try {
        $histPath = (Get-PSReadLineOption).HistorySavePath
        if (-not (Test-Path $histPath)) { return }

        # Deduplicate keeping most recent occurrence, then pipe newest-first to fzf
        $lines = Get-Content -Path $histPath -ErrorAction Stop | Where-Object { $_ -and $_.Trim() }
        $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        $deduped = [System.Collections.Generic.List[string]]::new()
        for ($i = $lines.Count - 1; $i -ge 0; $i--) {
            if ($seen.Add($lines[$i])) { $deduped.Add($lines[$i]) }
        }
        $picked = $deduped | fzf --no-sort --scheme=history

        if ($picked) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($picked)
        }
    } catch {
        # silently ignore
    }
}

# 2) Alt+J = zoxide interactive jump (most reliable)
# Uses zoxide's own fzf integration and changes directory correctly.
Set-PSReadLineKeyHandler -Key Alt+j -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("zi")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# 3) Ctrl+T = fuzzy file picker (best: prefer fd if available, fallback to Get-ChildItem)
Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock {
    try {
        if ($null -eq $global:_hasFd) { $global:_hasFd = $null -ne (Get-Command fd -ErrorAction SilentlyContinue) }
        if ($global:_hasFd) {
            $picked = & fd --type f --hidden --follow --exclude .git 2>$null | fzf
        } else {
            $picked = Get-ChildItem -File -Recurse -Force -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty FullName |
                fzf
        }

        if ($picked) {
            # Quote path if it contains spaces
            $toInsert = if ($picked -match '\s') { '"' + $picked + '"' } else { $picked }
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($toInsert)
        }
    } catch {
        # silently ignore
    }
}

# 4) Ctrl+F = fuzzy directory picker (within current tree)
# Great for jumping around inside a big repo without relying on zoxide scoring.
Set-PSReadLineKeyHandler -Key Ctrl+f -ScriptBlock {
    try {
        if ($null -eq $global:_hasFd) { $global:_hasFd = $null -ne (Get-Command fd -ErrorAction SilentlyContinue) }
        if ($global:_hasFd) {
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
        # Ensure we're in a git repo
        & git rev-parse --is-inside-work-tree *> $null
        if ($LASTEXITCODE -ne 0) { return }

        $refs = & git for-each-ref --format="%(refname:short)" refs/heads refs/remotes 2>$null |
            Where-Object { $_ -and ($_ -notmatch '^origin/HEAD$') } |
            Sort-Object -Unique

        $picked = $refs | fzf --prompt "git checkout> " --no-sort
        if (-not $picked) { return }

        # Local branches can contain '/' (e.g. pbi/foo), so check the ref, not the slash.
        & git show-ref --verify --quiet "refs/heads/$picked"
        $isLocal = ($LASTEXITCODE -eq 0)

        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        if ($isLocal) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("git checkout $picked")
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("git checkout -t $picked")
        }
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    } catch {
        # silently ignore
    }
}

# Optional: Up/Down substring history search (pairs nicely with Ctrl+R=fzf)
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Optional: Ctrl+L clear screen
Set-PSReadLineKeyHandler -Key Ctrl+l -Function ClearScreen

# 6) Alt+W = fuzzy worktree switcher
Set-PSReadLineKeyHandler -Key Alt+w -ScriptBlock {
    try {
        & git rev-parse --is-inside-work-tree *> $null
        if ($LASTEXITCODE -ne 0) { return }

        $worktrees = & git worktree list --porcelain |
            Where-Object { $_ -match '^worktree ' } |
            ForEach-Object { $_ -replace '^worktree ', '' }

        $picked = $worktrees | fzf --prompt "worktree> "
        if (-not $picked) { return }

        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        Set-Location $picked
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    } catch {}
}

Write-Host "profile loaded" -ForegroundColor Green