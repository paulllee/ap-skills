# Detect build/task tool files and extract their targets/commands.
# Usage: detect-build-tools.ps1 [project_dir]
# Output: one line per tool — "file | tool_name | targets"
param([string]$Dir = '.')

$ErrorActionPreference = 'Stop'

function Detect {
    param([string]$File, [string]$Name)
    $Path = Join-Path $Dir $File
    if (-not (Test-Path $Path)) { return }
    $Targets = '(none detected)'
    $Content = Get-Content $Path -ErrorAction SilentlyContinue
    switch ($Name) {
        'make' {
            $t = $Content | Where-Object { $_ -match '^[a-zA-Z_][a-zA-Z0-9_-]*:' } |
                ForEach-Object { ($_ -split ':')[0] } | Sort-Object -Unique
            if ($t) { $Targets = ($t -join ' ') }
        }
        'just' {
            $t = $Content | Where-Object { $_ -match '^[a-zA-Z_][a-zA-Z0-9_-]*:' } |
                ForEach-Object { ($_ -split ':')[0] } | Sort-Object -Unique
            if ($t) { $Targets = ($t -join ' ') }
        }
        'taskfile' {
            $t = $Content | Where-Object { $_ -match '^\s+[a-zA-Z_][a-zA-Z0-9_-]*:' } |
                ForEach-Object { ($_.Trim() -split ':')[0] } | Sort-Object -Unique
            if ($t) { $Targets = ($t -join ' ') }
        }
        'npm' {
            $json = $Content -join "`n" | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($json.scripts) {
                $t = $json.scripts.PSObject.Properties.Name | Sort-Object
                if ($t) { $Targets = ($t -join ' ') }
            }
        }
        'gradle' {
            $t = $Content | Where-Object { $_ -match '^\s*task\s+' } |
                ForEach-Object { if ($_ -match 'task\s+(\w+)') { $Matches[1] } } | Sort-Object -Unique
            if ($t) { $Targets = ($t -join ' ') }
        }
        'maven' { $Targets = '(maven lifecycle)' }
        'docker' { $Targets = '(docker)' }
        'rake' {
            $t = $Content | Where-Object { $_ -match '^\s*task\s+:' } |
                ForEach-Object { if ($_ -match ':(\w+)') { $Matches[1] } } | Sort-Object -Unique
            if ($t) { $Targets = ($t -join ' ') }
        }
    }
    Write-Output "$File | $Name | $Targets"
}

Detect 'Makefile' 'make'
Detect 'GNUmakefile' 'make'
Detect 'Justfile' 'just'
Detect 'Taskfile.yml' 'taskfile'
Detect 'Taskfile.yaml' 'taskfile'
Detect 'package.json' 'npm'
Detect 'build.gradle' 'gradle'
Detect 'pom.xml' 'maven'
Detect 'Dockerfile' 'docker'
Detect 'docker-compose.yml' 'docker'
Detect 'compose.yml' 'docker'
Detect 'Rakefile' 'rake'
Detect 'Cakefile' 'rake'
Detect 'BUILD' 'bazel'
