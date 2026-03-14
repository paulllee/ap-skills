# Summarize recent git changes: diff stats and recent commits.
# Usage: summarize-changes.ps1 [commit_range]
#   commit_range  defaults to HEAD~1 (last commit)
# Output: DIFF section then LOG section, machine-readable.
param([string]$Range = 'HEAD~1')

$ErrorActionPreference = 'Stop'

try { $null = git rev-parse --is-inside-work-tree 2>$null } catch {
    Write-Output 'ERROR | not a git repository'; exit 1
}

$CommitCount = git rev-list --count HEAD 2>$null
if (-not $CommitCount -or [int]$CommitCount -eq 0) {
    Write-Output 'ERROR | no commits yet'; exit 1
}

if ([int]$CommitCount -eq 1) {
    $Range = (git rev-list --max-parents=0 HEAD)
}

Write-Output '=== DIFF ==='
$diff = git diff --stat $Range 2>$null
if ($diff) { $diff | ForEach-Object { Write-Output $_ } } else { Write-Output '(no diff available)' }

Write-Output ''
Write-Output '=== CHANGED FILES ==='
$files = git diff --name-only $Range 2>$null
if ($files) { $files | ForEach-Object { Write-Output $_ } } else { Write-Output '(none)' }

Write-Output ''
Write-Output '=== CATEGORIES ==='
$docs = 0; $code = 0; $config = 0; $tests = 0
if ($files) {
    foreach ($f in $files) {
        if ($f -match '\.(md)$' -or $f -match '^docs/' -or $f -match '^README' -or $f -match '^CHANGELOG') { $docs++ }
        elseif ($f -match 'test|spec|_test\.|\.test\.') { $tests++ }
        elseif ($f -match '\.(json|yml|yaml|toml|ini|cfg)$' -or $f -match '(Dockerfile|docker-compose|\.git)') { $config++ }
        else { $code++ }
    }
}
Write-Output "docs=$docs code=$code config=$config tests=$tests"

Write-Output ''
Write-Output '=== LOG ==='
$log = git log --oneline -5 2>$null
if ($log) { $log | ForEach-Object { Write-Output $_ } } else { Write-Output '(no log)' }
