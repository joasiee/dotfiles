# Pick up PATH entries added by installers without discarding session-only entries.
# Environment changes are shared with the calling session even when run with &.
foreach ($target in 'Machine', 'User') {
    $savedPath = [Environment]::GetEnvironmentVariable('Path', $target)
    foreach ($entry in ($savedPath -split ';')) {
        if ([string]::IsNullOrWhiteSpace($entry)) { continue }
        $entry = [Environment]::ExpandEnvironmentVariables($entry)
        if (($env:PATH -split ';') -notcontains $entry) {
            $env:PATH = "$env:PATH;$entry"
        }
    }
}
