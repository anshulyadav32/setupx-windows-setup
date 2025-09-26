Write-Host "SETUPX - Modular Windows Development Environment Setup" -ForegroundColor Green
Write-Host ""
Write-Host "Available modules:" -ForegroundColor Magenta

$modules = Get-ChildItem -Path "modules" -Directory
foreach ($module in $modules) {
    Write-Host "  • $($module.Name)" -ForegroundColor White
}

Write-Host ""
Write-Host "Status: Ready to install development tools" -ForegroundColor Green
Write-Host "Package managers supported: WinGet, Chocolatey, Scoop" -ForegroundColor Yellow