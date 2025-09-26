#!/usr/bin/env powershell
# Simple SetupX Install Script
param(
    [string]$Module = "package-managers"
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Banner {
    Write-ColorOutput ""
    Write-ColorOutput "SETUPX - Simple Install" "Cyan"
    Write-ColorOutput ""
}

function Install-PackageManagers {
    Show-Banner
    Write-ColorOutput "Installing Package Managers..." "Magenta"
    Write-ColorOutput ""
    
    # Install Chocolatey
    Write-ColorOutput "Installing Chocolatey..." "White"
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-ColorOutput "  ✓ Chocolatey installed successfully" "Green"
    }
    catch {
        Write-ColorOutput "  ✗ Chocolatey installation failed: $($_.Exception.Message)" "Red"
    }
    
    Write-ColorOutput ""
    
    # Install Scoop
    Write-ColorOutput "Installing Scoop..." "White"
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Write-ColorOutput "  ✓ Scoop installed successfully" "Green"
    }
    catch {
        Write-ColorOutput "  ✗ Scoop installation failed: $($_.Exception.Message)" "Red"
    }
    
    Write-ColorOutput ""
    
    # Check WinGet
    Write-ColorOutput "Checking WinGet..." "White"
    try {
        $wingetVersion = winget --version
        Write-ColorOutput "  ✓ WinGet already available: $wingetVersion" "Green"
    }
    catch {
        Write-ColorOutput "  ! WinGet not found - install from Microsoft Store" "Yellow"
    }
    
    Write-ColorOutput ""
    
    # Check npm
    Write-ColorOutput "Checking npm..." "White"
    try {
        $npmVersion = npm --version
        Write-ColorOutput "  ✓ npm already available: $npmVersion" "Green"
    }
    catch {
        Write-ColorOutput "  ! npm not found - install Node.js first" "Yellow"
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "Installation complete!" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "Test your package managers:" "Cyan"
    Write-ColorOutput "  choco --version" "White"
    Write-ColorOutput "  scoop --version" "White"
    Write-ColorOutput "  winget --version" "White"
    Write-ColorOutput "  npm --version" "White"
}

# Main execution
if ($Module -eq "package-managers") {
    Install-PackageManagers
} else {
    Write-ColorOutput "Available modules: package-managers" "Yellow"
    Write-ColorOutput "Usage: .\install-simple.ps1 -Module package-managers" "White"
}
