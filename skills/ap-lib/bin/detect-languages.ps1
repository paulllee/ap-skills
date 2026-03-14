# Detect project languages from file extensions and manifest files.
# Usage: detect-languages.ps1 [project_dir]
# Output: one line per language — "language | confidence | evidence"
param([string]$Dir = '.')

$ErrorActionPreference = 'Stop'
$Found = @{}
$ExcludeDirs = @('node_modules', '.git', 'vendor', 'venv', '__pycache__', 'bin', 'obj')

function Test-Manifest {
    param([string]$File, [string]$Lang)
    if ($Found.ContainsKey($Lang)) { return }
    if (Test-Path (Join-Path $Dir $File)) {
        $Found[$Lang] = "high | $File"
    }
}

function Test-Extensions {
    param([string]$Ext, [string]$Lang)
    if ($Found.ContainsKey($Lang)) { return }
    $files = Get-ChildItem -Path $Dir -Filter "*.$Ext" -Recurse -Depth 3 -ErrorAction SilentlyContinue |
        Where-Object { $skip = $false; foreach ($d in $ExcludeDirs) { if ($_.FullName -match [regex]::Escape($d)) { $skip = $true; break } }; -not $skip } |
        Select-Object -First 5
    if ($files) {
        $Found[$Lang] = "medium | *.$Ext files found"
    }
}

# Manifests (high confidence)
Test-Manifest 'pyproject.toml' 'python'
Test-Manifest 'setup.py' 'python'
Test-Manifest 'requirements.txt' 'python'
Test-Manifest 'Pipfile' 'python'
Test-Manifest 'package.json' 'javascript'
Test-Manifest 'tsconfig.json' 'typescript'
Test-Manifest 'go.mod' 'go'
Test-Manifest 'Cargo.toml' 'rust'
Test-Manifest 'Gemfile' 'ruby'
Test-Manifest 'composer.json' 'php'
Test-Manifest 'build.gradle' 'java'
Test-Manifest 'pom.xml' 'java'
Test-Manifest 'mix.exs' 'elixir'
Test-Manifest 'pubspec.yaml' 'dart'
Test-Manifest 'Package.swift' 'swift'

# Check for csproj/sln via wildcard
if (-not $Found.ContainsKey('csharp')) {
    $csproj = Get-ChildItem -Path $Dir -Filter '*.csproj' -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1
    $sln = Get-ChildItem -Path $Dir -Filter '*.sln' -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($csproj -or $sln) { $Found['csharp'] = 'high | *.csproj/*.sln found' }
}

# Extensions (medium confidence)
Test-Extensions 'py' 'python'
Test-Extensions 'js' 'javascript'
Test-Extensions 'ts' 'typescript'
Test-Extensions 'go' 'go'
Test-Extensions 'rs' 'rust'
Test-Extensions 'rb' 'ruby'
Test-Extensions 'php' 'php'
Test-Extensions 'java' 'java'
Test-Extensions 'cs' 'csharp'
Test-Extensions 'fs' 'fsharp'
Test-Extensions 'ex' 'elixir'
Test-Extensions 'dart' 'dart'
Test-Extensions 'swift' 'swift'
Test-Extensions 'kt' 'kotlin'
Test-Extensions 'scala' 'scala'
Test-Extensions 'cpp' 'cpp'
Test-Extensions 'c' 'c'
Test-Extensions 'zig' 'zig'
Test-Extensions 'lua' 'lua'

if ($Found.Count -eq 0) {
    Write-Output '(no languages detected)'
    exit 0
}

foreach ($lang in $Found.Keys | Sort-Object) {
    Write-Output "$lang | $($Found[$lang])"
}
