param([string]$Action)

if ($Action -eq 'help') {
    Write-Host "SETUPX CLI - Help Commands" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "COMMANDS:" -ForegroundColor Yellow
    Write-Host "  .\simple-help.ps1 list     # List all modules" -ForegroundColor White
    Write-Host "  .\simple-help.ps1 status    # Show system status" -ForegroundColor White
    Write-Host "  .\simple-help.ps1 help     # Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "PACKAGE MANAGERS:" -ForegroundColor Cyan
    Write-Host "  • WinGet (Microsoft Official)" -ForegroundColor White
    Write-Host "  • Chocolatey (Community)" -ForegroundColor White
    Write-Host "  • Scoop (Portable Apps)" -ForegroundColor White
    return
}

if ($Action -eq 'list') {
    Write-Host "📦 Available Modules:" -ForegroundColor Magenta
    Get-ChildItem -Path "modules" -Directory | ForEach-Object { Write-Host "  • $($_.Name)" -ForegroundColor White }
    return
}

if ($Action -eq 'status') {
    Write-Host "📊 System Status:" -ForegroundColor Cyan
    Write-Host "  Status: Ready to install development tools" -ForegroundColor Green
    Write-Host "  Package managers: WinGet, Chocolatey, Scoop" -ForegroundColor Yellow
    return
}

Write-Host "SETUPX CLI - Use: .\simple-help.ps1 help" -ForegroundColor Cyan
