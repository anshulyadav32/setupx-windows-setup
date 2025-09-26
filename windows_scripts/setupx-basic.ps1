#!/usr/bin/env powershell

Write-Host "`n" -ForegroundColor White
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                           setupx                              ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     Modular Windows Development Environment Setup CLI        ║" -ForegroundColor White
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "Transform your Windows machine into a complete development environment." -ForegroundColor Gray
Write-Host ""

Write-Host "SETUPX is working!" -ForegroundColor Green
Write-Host ""
Write-Host "Available modules:" -ForegroundColor Magenta

$ScriptRoot = $PSScriptRoot
$ModulesPath = Join-Path $ScriptRoot "modules"

if (Test-Path $ModulesPath) {
    $moduleDirectories = Get-ChildItem -Path $ModulesPath -Directory
    if ($moduleDirectories.Count -gt 0) {
        foreach ($moduleDir in $moduleDirectories) {
            Write-Host "  • $($moduleDir.Name)" -ForegroundColor White
        }
    } else {
        Write-Host "  No modules found." -ForegroundColor Yellow
    }
} else {
    Write-Host "  Modules directory not found: $ModulesPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "This is a basic working version of setupx." -ForegroundColor Yellow
Write-Host "The full interactive menu and installation functionality will be available once the syntax issues are resolved." -ForegroundColor Gray