# Azure CLI Installation Script
# Installs Microsoft Azure CLI tools

#Requires -RunAsAdministrator

param([switch]$Verbose)

$ErrorActionPreference = "Continue"
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

function Write-ColorOutput($Message, $Color = "White") {
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-AzureCLI {
    Write-ColorOutput "`n=== Installing Azure CLI ===" $Cyan

    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges." $Red
        exit 1
    }

    # Check if already installed
    if (Get-Command "az" -ErrorAction SilentlyContinue) {
        $version = az --version | Select-Object -First 1
        Write-ColorOutput "✓ Azure CLI is already installed: $version" $Green

        $update = Read-Host "Do you want to update Azure CLI? (y/n)"
        if ($update -eq "y" -or $update -eq "Y") {
            Write-ColorOutput "Updating Azure CLI..." $Yellow
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                winget upgrade Microsoft.AzureCLI --silent
            } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco upgrade azure-cli -y
            }
        }
        return
    }

    Write-ColorOutput "Installing Azure CLI..." $Yellow

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            winget install --id Microsoft.AzureCLI --silent --accept-source-agreements --accept-package-agreements
            Write-ColorOutput "✓ Azure CLI installed via WinGet" $Green
        } catch {
            Write-ColorOutput "! WinGet installation failed, trying Chocolatey..." $Yellow

            # Fallback to Chocolatey
            if (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install azure-cli -y
                Write-ColorOutput "✓ Azure CLI installed via Chocolatey" $Green
            } else {
                Write-ColorOutput "✗ Failed to install Azure CLI" $Red
                return
            }
        }
    } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
        choco install azure-cli -y
        Write-ColorOutput "✓ Azure CLI installed via Chocolatey" $Green
    } else {
        Write-ColorOutput "✗ No package manager available. Please install Chocolatey or WinGet first." $Red
        return
    }

    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # Verify installation
    Write-ColorOutput "`n=== Verifying Installation ===" $Cyan
    if (Get-Command "az" -ErrorAction SilentlyContinue) {
        $version = az --version | Select-Object -First 1
        Write-ColorOutput "✓ Azure CLI installed successfully: $version" $Green

        Write-ColorOutput "`n=== Next Steps ===" $Cyan
        Write-ColorOutput "To sign in to Azure, run:" $White
        Write-ColorOutput "  az login" $Yellow
        Write-ColorOutput "`nCommon commands:" $White
        Write-ColorOutput "• az account list - List subscriptions" $White
        Write-ColorOutput "• az group list - List resource groups" $White
        Write-ColorOutput "• az vm list - List virtual machines" $White
    } else {
        Write-ColorOutput "✗ Installation verification failed" $Red
    }
}

Install-AzureCLI
Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")