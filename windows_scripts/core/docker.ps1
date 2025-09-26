# Docker Installation Script
# Installs Docker Desktop for Windows

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

function Test-WindowsFeature {
    param([string]$FeatureName)

    try {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName
        return $feature.State -eq "Enabled"
    } catch {
        return $false
    }
}

function Enable-WindowsFeature {
    param([string]$FeatureName, [string]$DisplayName)

    Write-ColorOutput "Enabling $DisplayName..." $Yellow
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart
        Write-ColorOutput "✓ $DisplayName enabled" $Green
        return $true
    } catch {
        Write-ColorOutput "✗ Failed to enable $DisplayName" $Red
        return $false
    }
}

function Install-Docker {
    Write-ColorOutput "`n=== Installing Docker Desktop ===" $Cyan

    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges." $Red
        exit 1
    }

    # Check if already installed
    if (Get-Command "docker" -ErrorAction SilentlyContinue) {
        $version = docker --version
        Write-ColorOutput "✓ Docker is already installed: $version" $Green

        $update = Read-Host "Do you want to update Docker Desktop? (y/n)"
        if ($update -eq "y" -or $update -eq "Y") {
            Write-ColorOutput "Updating Docker Desktop..." $Yellow
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                winget upgrade Docker.DockerDesktop --silent
            } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco upgrade docker-desktop -y
            }
        }
        return
    }

    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Write-ColorOutput "✗ Docker Desktop requires Windows 10 or later" $Red
        return
    }

    # Enable required Windows features
    Write-ColorOutput "`n=== Enabling Windows Features ===" $Cyan

    $featuresEnabled = $true

    # Check and enable Hyper-V (for Windows 10 Pro/Enterprise)
    if (-not (Test-WindowsFeature "Microsoft-Hyper-V-All")) {
        $featuresEnabled = Enable-WindowsFeature "Microsoft-Hyper-V-All" "Hyper-V" -and $featuresEnabled
    } else {
        Write-ColorOutput "✓ Hyper-V already enabled" $Green
    }

    # Check and enable Windows Subsystem for Linux
    if (-not (Test-WindowsFeature "Microsoft-Windows-Subsystem-Linux")) {
        $featuresEnabled = Enable-WindowsFeature "Microsoft-Windows-Subsystem-Linux" "WSL" -and $featuresEnabled
    } else {
        Write-ColorOutput "✓ WSL already enabled" $Green
    }

    # Check and enable Virtual Machine Platform
    if (-not (Test-WindowsFeature "VirtualMachinePlatform")) {
        $featuresEnabled = Enable-WindowsFeature "VirtualMachinePlatform" "Virtual Machine Platform" -and $featuresEnabled
    } else {
        Write-ColorOutput "✓ Virtual Machine Platform already enabled" $Green
    }

    Write-ColorOutput "`n=== Installing Docker Desktop ===" $Cyan

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            winget install --id Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements
            Write-ColorOutput "✓ Docker Desktop installed via WinGet" $Green
        } catch {
            Write-ColorOutput "! WinGet installation failed, trying Chocolatey..." $Yellow

            # Fallback to Chocolatey
            if (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install docker-desktop -y
                Write-ColorOutput "✓ Docker Desktop installed via Chocolatey" $Green
            } else {
                Write-ColorOutput "✗ Failed to install Docker Desktop" $Red
                return
            }
        }
    } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
        choco install docker-desktop -y
        Write-ColorOutput "✓ Docker Desktop installed via Chocolatey" $Green
    } else {
        Write-ColorOutput "✗ No package manager available. Please install Chocolatey or WinGet first." $Red
        return
    }

    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    Write-ColorOutput "`n=== Installation Complete ===" $Green
    Write-ColorOutput "Docker Desktop has been installed successfully." $Green

    Write-ColorOutput "`n=== Important Notes ===" $Cyan
    Write-ColorOutput "• You may need to restart your computer for all features to work properly" $White
    Write-ColorOutput "• Docker Desktop will start automatically after restart" $White
    Write-ColorOutput "• Sign in to Docker Desktop and accept the license agreement" $White
    Write-ColorOutput "• Configure Docker Desktop settings as needed" $White

    Write-ColorOutput "`n=== Next Steps ===" $Cyan
    Write-ColorOutput "After restart, verify installation with:" $White
    Write-ColorOutput "  docker --version" $Yellow
    Write-ColorOutput "  docker run hello-world" $Yellow

    $restart = Read-Host "`nDo you want to restart your computer now? (y/n)"
    if ($restart -eq "y" -or $restart -eq "Y") {
        Write-ColorOutput "Restarting computer in 10 seconds..." $Yellow
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}

Install-Docker
Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")