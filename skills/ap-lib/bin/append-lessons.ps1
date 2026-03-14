# Append a lesson to the "## Lessons Learned" section of AGENTS.md (dedup).
# Usage: append-lessons.ps1 "lesson text" [agents_file]
# Exit codes: 0=appended, 1=error, 2=duplicate
param(
    [Parameter(Mandatory)][string]$Lesson,
    [string]$AgentsFile
)

$ErrorActionPreference = 'Stop'

if (-not $AgentsFile) {
    $AgentsFile = 'AGENTS.md'
    if (-not (Test-Path $AgentsFile)) {
        try { $Root = git rev-parse --show-toplevel 2>$null } catch { $Root = $null }
        if ($Root) { $AgentsFile = Join-Path $Root 'AGENTS.md' }
    }
}

if (-not (Test-Path $AgentsFile)) {
    Write-Output 'ERROR | AGENTS.md not found'; exit 1
}

$Content = Get-Content $AgentsFile
$Clean = ($Lesson -replace '^- ', '').Trim().ToLower()

# Find section boundaries
$SectionStart = -1
$SectionEnd = $Content.Count
for ($i = 0; $i -lt $Content.Count; $i++) {
    if ($Content[$i] -match '^## Lessons Learned') { $SectionStart = $i; continue }
    if ($SectionStart -ge 0 -and $i -gt $SectionStart -and $Content[$i] -match '^## ') {
        $SectionEnd = $i; break
    }
}

# Check duplicates within section
if ($SectionStart -ge 0) {
    for ($i = $SectionStart + 1; $i -lt $SectionEnd; $i++) {
        if ($Content[$i] -match '^- ') {
            $Existing = ($Content[$i] -replace '^- ', '').Trim().ToLower()
            if ($Existing -eq $Clean) {
                Write-Output "DUPLICATE | $Lesson"; exit 2
            }
        }
    }
}

if ($SectionStart -lt 0) {
    # Append section at end
    Add-Content $AgentsFile "`n## Lessons Learned`n`n- $Lesson"
    Write-Output "ADDED | $Lesson (created section)"
    exit 0
}

# Insert before next section
$NewContent = @()
$NewContent += $Content[0..($SectionEnd - 1)]
$NewContent += "- $Lesson"
if ($SectionEnd -lt $Content.Count) {
    $NewContent += $Content[$SectionEnd..($Content.Count - 1)]
}
$NewContent | Set-Content $AgentsFile

Write-Output "ADDED | $Lesson"
