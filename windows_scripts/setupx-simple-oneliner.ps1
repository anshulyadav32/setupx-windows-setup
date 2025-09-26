#!/usr/bin/env powershell
# SetupX Simple One-Liner
# Usage: Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/windows_scripts/setupx-simple-oneliner.ps1")

Write-Host ""
Write-Host "SETUPX - One-Liner Installer" -ForegroundColor Cyan
Write-Host "Setting up Windows Development Environment..." -ForegroundColor Green
Write-Host ""

# Set execution policy
Write-Host "Setting execution policy..." -ForegroundColor Yellow
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Install Chocolatey
Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "  Chocolatey installed" -ForegroundColor Green
}
catch {
    Write-Host "  Chocolatey: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Install Scoop
Write-Host "Installing Scoop..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    Write-Host "  Scoop installed" -ForegroundColor Green
}
catch {
    Write-Host "  Scoop: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Check WinGet
Write-Host "Checking WinGet..." -ForegroundColor Yellow
try {
    $wingetVersion = winget --version 2>$null
    Write-Host "  WinGet available: $wingetVersion" -ForegroundColor Green
}
catch {
    Write-Host "  WinGet not found - install from Microsoft Store" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "SetupX Installation Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Test your package managers:" -ForegroundColor Cyan
Write-Host "  choco --version" -ForegroundColor White
Write-Host "  scoop --version" -ForegroundColor White
Write-Host "  winget --version" -ForegroundColor White
Write-Host ""
Write-Host "Install software with:" -ForegroundColor Cyan
Write-Host "  choco install package-name" -ForegroundColor White
Write-Host "  scoop install package-name" -ForegroundColor White
Write-Host "  winget install package-name" -ForegroundColor White
