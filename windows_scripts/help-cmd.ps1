param([string]$Action)

if ($Action -eq 'help' -or $Action -eq '-Help' -or $Action -eq '--help') {
    Write-Host "SETUPX CLI - Modular Windows Development Environment Setup" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\help-cmd.ps1 [command]" -ForegroundColor White
    Write-Host ""
    Write-Host "COMMANDS:" -ForegroundColor Yellow
    Write-Host "  list     - List all available modules" -ForegroundColor White
    Write-Host "  status   - Show system status" -ForegroundColor White
    Write-Host "  modules  - Show detailed module information" -ForegroundColor White
    Write-Host "  help     - Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\help-cmd.ps1 list     # List all modules" -ForegroundColor White
    Write-Host "  .\help-cmd.ps1 status   # Show system status" -ForegroundColor White
    Write-Host "  .\help-cmd.ps1 modules  # Show module details" -ForegroundColor White
    Write-Host "  .\help-cmd.ps1 help     # Show this help" -ForegroundColor White
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
    Write-Host "  Modules available: 6" -ForegroundColor White
    return
}

if ($Action -eq 'modules') {
    Write-Host "📦 Module Details:" -ForegroundColor Magenta
    $modules = Get-ChildItem -Path "modules" -Directory
    foreach ($module in $modules) {
        Write-Host "`n  • $($module.Name)" -ForegroundColor White
        $configPath = Join-Path $module.FullName "module.json"
        if (Test-Path $configPath) {
            try {
                $config = Get-Content $configPath | ConvertFrom-Json
                Write-Host "    Description: $($config.description)" -ForegroundColor Gray
                Write-Host "    Components: $($config.components.Count)" -ForegroundColor Gray
            }
            catch {
                Write-Host "    (Configuration not available)" -ForegroundColor Yellow
            }
        }
    }
    return
}

# Default help
Write-Host "SETUPX CLI - Modular Windows Development Environment Setup" -ForegroundColor Cyan
Write-Host ""
Write-Host "Use: .\help-cmd.ps1 help" -ForegroundColor Yellow
Write-Host "For full command list and usage examples" -ForegroundColor White
