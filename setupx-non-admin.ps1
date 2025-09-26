# SetupX Non-Admin Installation
# Run this script as a regular user (not Administrator) for best results

Write-Host "SetupX Non-Admin Installation" -ForegroundColor Cyan
Write-Host "This script should be run as a regular user, not Administrator" -ForegroundColor Yellow
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if ($isAdmin) {
    Write-Host "WARNING: You are running as Administrator!" -ForegroundColor Red
    Write-Host "For best results, please run this script as a regular user." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To run as regular user:" -ForegroundColor Cyan
    Write-Host "1. Open PowerShell as regular user (not 'Run as Administrator')" -ForegroundColor White
    Write-Host "2. Run: iwr https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1 | iex" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to continue anyway (not recommended)"
}

# Download and run the main installer
Write-Host "Downloading SetupX installer..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/install.ps1" | Invoke-Expression
} catch {
    Write-Host "Failed to download installer: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
}
