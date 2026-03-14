$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Destinations = @(
    (Join-Path $env:USERPROFILE '.claude\skills'),
    (Join-Path $env:USERPROFILE '.cursor\skills')
)
foreach ($Dest in $Destinations) {
    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    Write-Host "`n$Dest" -ForegroundColor White
    Get-ChildItem (Join-Path $ScriptDir 'skills') -Directory | ForEach-Object {
        $target = Join-Path $Dest $_.Name
        if (Test-Path $target) {
            Remove-Item $target -Recurse
            Write-Host "  Updating $($_.Name)" -ForegroundColor Yellow
        } else {
            Write-Host "  Installing $($_.Name)" -ForegroundColor Green
        }
        Copy-Item $_.FullName $target -Recurse
    }
}
Write-Host "`nDone. Skills installed to ~/.claude/skills/ and ~/.cursor/skills/."
