# AWS CLI Installation Script
# Installs Amazon Web Services CLI tools

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

function Install-AWSCLI {
    Write-ColorOutput "`n=== Installing AWS CLI ===" $Cyan

    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges." $Red
        exit 1
    }

    # Check if already installed
    if (Get-Command "aws" -ErrorAction SilentlyContinue) {
        $version = aws --version 2>&1
        Write-ColorOutput "✓ AWS CLI is already installed: $version" $Green

        # Ask if user wants to update
        $update = Read-Host "Do you want to update AWS CLI? (y/n)"
        if ($update -eq "y" -or $update -eq "Y") {
            Write-ColorOutput "Updating AWS CLI..." $Yellow
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                winget upgrade Amazon.AWSCLI --silent
            } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco upgrade awscli -y
            }
        }
        return
    }

    Write-ColorOutput "Installing AWS CLI..." $Yellow

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            winget install --id Amazon.AWSCLI --silent --accept-source-agreements --accept-package-agreements
            Write-ColorOutput "✓ AWS CLI installed via WinGet" $Green
        } catch {
            Write-ColorOutput "! WinGet installation failed, trying Chocolatey..." $Yellow

            # Fallback to Chocolatey
            if (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install awscli -y
                Write-ColorOutput "✓ AWS CLI installed via Chocolatey" $Green
            } else {
                Write-ColorOutput "✗ Failed to install AWS CLI" $Red
                return
            }
        }
    } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
        choco install awscli -y
        Write-ColorOutput "✓ AWS CLI installed via Chocolatey" $Green
    } else {
        Write-ColorOutput "✗ No package manager available. Please install Chocolatey or WinGet first." $Red
        return
    }

    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # Verify installation
    Write-ColorOutput "`n=== Verifying Installation ===" $Cyan
    if (Get-Command "aws" -ErrorAction SilentlyContinue) {
        $version = aws --version 2>&1
        Write-ColorOutput "✓ AWS CLI installed successfully: $version" $Green

        Write-ColorOutput "`n=== Next Steps ===" $Cyan
        Write-ColorOutput "To configure AWS CLI, run:" $White
        Write-ColorOutput "  aws configure" $Yellow
        Write-ColorOutput "`nYou'll need:" $White
        Write-ColorOutput "• AWS Access Key ID" $White
        Write-ColorOutput "• AWS Secret Access Key" $White
        Write-ColorOutput "• Default region (e.g., us-east-1)" $White
        Write-ColorOutput "• Default output format (json recommended)" $White
    } else {
        Write-ColorOutput "✗ Installation verification failed" $Red
    }
}

Install-AWSCLI
Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")