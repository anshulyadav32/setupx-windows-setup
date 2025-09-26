param([string]$Action)

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

Write-Host "SETUPX CLI - Modular Windows Development Environment Setup" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 Available Modules:" -ForegroundColor Magenta
Get-ChildItem -Path "modules" -Directory | ForEach-Object { Write-Host "  • $($_.Name)" -ForegroundColor White }
Write-Host ""
Write-Host "🔧 Usage:" -ForegroundColor Yellow
Write-Host "  .\cli-demo.ps1 list     # List modules" -ForegroundColor White
Write-Host "  .\cli-demo.ps1 status   # System status" -ForegroundColor White

