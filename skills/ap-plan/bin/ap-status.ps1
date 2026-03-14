# Print a summary of all AP-N plans: path | title | date | status | current_phase
# Usage: ap-status.ps1 [plans_dir]
param([string]$PlansDir)

$ErrorActionPreference = 'Stop'

if (-not $PlansDir) {
    try { $Root = git rev-parse --show-toplevel 2>$null } catch { $Root = $null }
    if (-not $Root) { $Root = Get-Location }
    $PlansDir = Join-Path $Root 'docs' 'plans'
}

if (-not (Test-Path $PlansDir)) {
    Write-Output "No plans directory found at $PlansDir"
    exit 0
}

$Plans = Get-ChildItem -Path $PlansDir -Filter 'AP-*.md' -ErrorAction SilentlyContinue
if (-not $Plans -or $Plans.Count -eq 0) {
    Write-Output "No AP plans found in $PlansDir"
    exit 0
}

foreach ($f in $Plans | Sort-Object Name) {
    $Title = '(untitled)'; $Date = '(no date)'; $Status = '(no status)'; $Phase = '(none)'
    foreach ($line in Get-Content $f.FullName) {
        if ($line -match '^# AP-\d+:\s*(.+)$') { $Title = $Matches[1] }
        if ($line -match '^\*\*Date:\*\*\s*(.+)$') { $Date = $Matches[1] }
        if ($line -match '^\*\*Status:\*\*\s*(.+)$') { $Status = $Matches[1] }
        if ($line -match '^\*\*Current Phase:\*\*\s*(.+)$') { $Phase = $Matches[1] }
        if ($Title -ne '(untitled)' -and $Date -ne '(no date)' -and $Status -ne '(no status)' -and $Phase -ne '(none)') { break }
    }
    Write-Output "$($f.FullName) | $Title | $Date | $Status | $Phase"
}
