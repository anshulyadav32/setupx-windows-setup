#!/usr/bin/env powershell
# SetupX One-Liner Download and Install
# Usage: Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/windows_scripts/setupx-oneliner.ps1")

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Banner {
    Write-ColorOutput ""
    Write-ColorOutput "╔══════════════════════════════════════════════════════════════╗" "Cyan"
    Write-ColorOutput "║                SETUPX ONE-LINER INSTALLER                ║" "Cyan"
    Write-ColorOutput "║              Windows Development Environment Setup         ║" "Cyan"
    Write-ColorOutput "╚══════════════════════════════════════════════════════════════╝" "Cyan"
    Write-ColorOutput ""
}

function Install-SetupX {
    Show-Banner
    Write-ColorOutput "🚀 Setting up Windows Development Environment..." "Green"
    Write-ColorOutput ""
    
    # Set execution policy
    Write-ColorOutput "Setting execution policy..." "Yellow"
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    
    # Install Chocolatey
    Write-ColorOutput "Installing Chocolatey..." "Yellow"
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-ColorOutput "  ✓ Chocolatey installed" "Green"
    }
    catch {
        Write-ColorOutput "  ⚠ Chocolatey: $($_.Exception.Message)" "Yellow"
    }
    
    # Install Scoop
    Write-ColorOutput "Installing Scoop..." "Yellow"
    try {
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Write-ColorOutput "  ✓ Scoop installed" "Green"
    }
    catch {
        Write-ColorOutput "  ⚠ Scoop: $($_.Exception.Message)" "Yellow"
    }
    
    # Check WinGet
    Write-ColorOutput "Checking WinGet..." "Yellow"
    try {
        $wingetVersion = winget --version 2>$null
        Write-ColorOutput "  ✓ WinGet available: $wingetVersion" "Green"
    }
    catch {
        Write-ColorOutput "  ⚠ WinGet not found - install from Microsoft Store" "Yellow"
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "🎉 SetupX Installation Complete!" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "Test your package managers:" "Cyan"
    Write-ColorOutput "  choco --version" "White"
    Write-ColorOutput "  scoop --version" "White"
    Write-ColorOutput "  winget --version" "White"
    Write-ColorOutput ""
    Write-ColorOutput "📦 Install software with:" "Cyan"
    Write-ColorOutput "  choco install [package]" "White"
    Write-ColorOutput "  scoop install [package]" "White"
    Write-ColorOutput "  winget install [package]" "White"
}

# Execute installation
Install-SetupX
