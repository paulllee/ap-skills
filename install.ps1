$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dest = Join-Path $env:USERPROFILE '.claude\skills'
New-Item -ItemType Directory -Force -Path $Dest | Out-Null
Get-ChildItem (Join-Path $ScriptDir 'skills') -Directory | ForEach-Object {
    $target = Join-Path $Dest $_.Name
    if (Test-Path $target) {
        Remove-Item $target -Recurse
        Write-Host "Updating $($_.Name)" -ForegroundColor Yellow
    } else {
        Write-Host "Installing $($_.Name)" -ForegroundColor Green
    }
    Copy-Item $_.FullName $target -Recurse
}
$count = (Get-ChildItem $Dest -Directory).Count
Write-Host "Done. Installed $count skills."
