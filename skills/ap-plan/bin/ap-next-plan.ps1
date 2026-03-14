# Create the next AP-N plan file and print its path to stdout.
# Usage: ap-next-plan.ps1 [plans_dir]
#   plans_dir  defaults to docs/plans relative to repo root (git) or cwd.
param([string]$PlansDir)

$ErrorActionPreference = 'Stop'

if (-not $PlansDir) {
    try { $Root = git rev-parse --show-toplevel 2>$null } catch { $Root = $null }
    if (-not $Root) { $Root = Get-Location }
    $PlansDir = Join-Path $Root 'docs' 'plans'
}

if (-not (Test-Path $PlansDir)) { New-Item -ItemType Directory -Path $PlansDir -Force | Out-Null }

$Next = 1
Get-ChildItem -Path $PlansDir -Filter 'AP-*.md' -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.BaseName -match '^AP-(\d+)$') {
        $Num = [int]$Matches[1]
        if ($Num -ge $Next) { $Next = $Num + 1 }
    }
}

$File = Join-Path $PlansDir "AP-$Next.md"
New-Item -ItemType File -Path $File -Force | Out-Null
Write-Output $File
