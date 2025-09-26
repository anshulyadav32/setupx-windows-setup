# SetupX Flutter Application Launcher
# Version: 1.0.0
# Platform: Windows x64

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                SETUPX FLUTTER APPLICATION                  ║" -ForegroundColor Cyan
Write-Host "║              Windows Development Environment Setup         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Starting SetupX Application..." -ForegroundColor Green
Write-Host "📦 Version: 1.0.0" -ForegroundColor Yellow
Write-Host "🖥️  Platform: Windows x64" -ForegroundColor Yellow
Write-Host "🔧 Flutter: 3.35.1" -ForegroundColor Yellow
Write-Host ""

# Check if setupx.exe exists
if (-not (Test-Path "setupx.exe")) {
    Write-Host "❌ Error: setupx.exe not found in current directory" -ForegroundColor Red
    Write-Host "Please ensure you're running this script from the release directory" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check system requirements
Write-Host "🔍 Checking system requirements..." -ForegroundColor Cyan

# Check Windows version
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Host "⚠️  Warning: Windows 10 or later recommended" -ForegroundColor Yellow
}

# Check if Visual C++ Redistributable is likely installed
$vcRedist = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*Visual C++*" }
if (-not $vcRedist) {
    Write-Host "⚠️  Warning: Visual C++ Redistributable may be required" -ForegroundColor Yellow
}

Write-Host "✅ System check complete" -ForegroundColor Green
Write-Host ""

# Launch the application
Write-Host "🎯 Launching SetupX..." -ForegroundColor Green
Write-Host ""

try {
    & ".\setupx.exe"
    Write-Host ""
    Write-Host "✅ SetupX application completed successfully" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "❌ Error launching SetupX: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check the system requirements and try again" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 For support and documentation:" -ForegroundColor Cyan
Write-Host "   GitHub: https://github.com/anshulyadav32/setupx-windows-setup" -ForegroundColor White
Write-Host "   Issues: https://github.com/anshulyadav32/setupx-windows-setup/issues" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
