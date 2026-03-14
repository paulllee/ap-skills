# List documentation files in the project.
# Usage: list-docs.ps1 [project_dir]
# Output: one line per doc file — "path | size_lines"
param([string]$Dir = '.')

$ErrorActionPreference = 'Stop'

if ($Dir -eq '.') {
    try { $Root = git rev-parse --show-toplevel 2>$null } catch { $Root = $null }
    if (-not $Root) { $Root = Get-Location }
} else {
    $Root = $Dir
}

$Found = $false
$RootFiles = @(
    'README.md', 'README.rst', 'AGENTS.md', 'CLAUDE.md', 'CLAUDE.local.md',
    'CHANGELOG.md', 'CONTRIBUTING.md', 'API.md', 'LICENSE.md'
)

foreach ($name in $RootFiles) {
    $path = Join-Path $Root $name
    if (Test-Path $path) {
        $Found = $true
        $lines = (Get-Content $path).Count
        Write-Output "$path | $lines lines"
    }
}

$DocsDir = Join-Path $Root 'docs'
if (Test-Path $DocsDir) {
    Get-ChildItem -Path $DocsDir -Filter '*.md' -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch [regex]::Escape((Join-Path 'docs' 'plans')) } |
        Sort-Object FullName |
        ForEach-Object {
            $Found = $true
            $lines = (Get-Content $_.FullName).Count
            Write-Output "$($_.FullName) | $lines lines"
        }
}

if (-not $Found) {
    Write-Output '(no documentation files found)'
}
