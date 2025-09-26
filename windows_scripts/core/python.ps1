# Python Installation Script
# Installs Python with pip and essential packages

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

function Install-Python {
    Write-ColorOutput "`n=== Installing Python ===" $Cyan

    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges." $Red
        exit 1
    }

    # Check if already installed
    if (Get-Command "python" -ErrorAction SilentlyContinue) {
        $version = python --version
        Write-ColorOutput "✓ Python is already installed: $version" $Green

        $update = Read-Host "Do you want to update Python? (y/n)"
        if ($update -ne "y" -and $update -ne "Y") {
            return
        }
    }

    Write-ColorOutput "Installing Python..." $Yellow

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            winget install --id Python.Python.3.12 --silent --accept-source-agreements --accept-package-agreements
            Write-ColorOutput "✓ Python installed via WinGet" $Green
        } catch {
            Write-ColorOutput "! WinGet installation failed, trying Chocolatey..." $Yellow

            # Fallback to Chocolatey
            if (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install python -y
                Write-ColorOutput "✓ Python installed via Chocolatey" $Green
            } else {
                Write-ColorOutput "✗ Failed to install Python" $Red
                return
            }
        }
    } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
        choco install python -y
        Write-ColorOutput "✓ Python installed via Chocolatey" $Green
    } else {
        Write-ColorOutput "✗ No package manager available. Please install Chocolatey or WinGet first." $Red
        return
    }

    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # Wait a moment for installation to complete
    Start-Sleep -Seconds 5

    # Verify installation
    Write-ColorOutput "`n=== Verifying Installation ===" $Cyan
    if (Get-Command "python" -ErrorAction SilentlyContinue) {
        $pythonVersion = python --version
        Write-ColorOutput "✓ Python installed successfully: $pythonVersion" $Green
    } else {
        Write-ColorOutput "✗ Python installation verification failed" $Red
        return
    }

    if (Get-Command "pip" -ErrorAction SilentlyContinue) {
        $pipVersion = pip --version
        Write-ColorOutput "✓ pip installed successfully: $pipVersion" $Green
    } else {
        Write-ColorOutput "✗ pip installation verification failed" $Red
        return
    }

    # Update pip
    Write-ColorOutput "`n=== Updating pip ===" $Cyan
    try {
        python -m pip install --upgrade pip
        Write-ColorOutput "✓ pip updated to latest version" $Green
    } catch {
        Write-ColorOutput "! Failed to update pip" $Yellow
    }

    # Install essential Python packages
    Write-ColorOutput "`n=== Installing Essential Python Packages ===" $Cyan

    $packages = @(
        "virtualenv",
        "pipenv",
        "requests",
        "beautifulsoup4",
        "lxml",
        "selenium",
        "pandas",
        "numpy",
        "matplotlib",
        "seaborn",
        "jupyter",
        "ipython",
        "pytest",
        "black",
        "flake8",
        "autopep8"
    )

    foreach ($package in $packages) {
        try {
            Write-ColorOutput "Installing $package..." $Yellow
            pip install $package --quiet
            Write-ColorOutput "✓ $package installed" $Green
        } catch {
            Write-ColorOutput "! Failed to install $package" $Red
        }
    }

    # Install development tools
    Write-ColorOutput "`n=== Installing Development Tools ===" $Cyan

    $devPackages = @(
        "pylint",
        "mypy",
        "bandit",
        "safety",
        "pre-commit",
        "cookiecutter",
        "poetry"
    )

    foreach ($package in $devPackages) {
        try {
            Write-ColorOutput "Installing $package..." $Yellow
            pip install $package --quiet
            Write-ColorOutput "✓ $package installed" $Green
        } catch {
            Write-ColorOutput "! Failed to install $package" $Red
        }
    }

    Write-ColorOutput "`n=== Installation Complete ===" $Green
    Write-ColorOutput "Python has been installed with essential packages!" $Green

    Write-ColorOutput "`n=== Installed Packages ===" $Cyan
    Write-ColorOutput "Core packages:" $White
    Write-ColorOutput "• virtualenv, pipenv - Virtual environment management" $White
    Write-ColorOutput "• requests, beautifulsoup4 - Web scraping and HTTP" $White
    Write-ColorOutput "• pandas, numpy - Data analysis and scientific computing" $White
    Write-ColorOutput "• matplotlib, seaborn - Data visualization" $White
    Write-ColorOutput "• jupyter, ipython - Interactive development" $White
    Write-ColorOutput "• pytest - Testing framework" $White

    Write-ColorOutput "`nDevelopment tools:" $White
    Write-ColorOutput "• black, flake8, autopep8 - Code formatting and linting" $White
    Write-ColorOutput "• pylint, mypy - Static analysis" $White
    Write-ColorOutput "• bandit, safety - Security analysis" $White
    Write-ColorOutput "• poetry - Dependency management" $White

    Write-ColorOutput "`n=== Next Steps ===" $Cyan
    Write-ColorOutput "Try these commands:" $White
    Write-ColorOutput "  python --version" $Yellow
    Write-ColorOutput "  pip --version" $Yellow
    Write-ColorOutput "  python -c \"import pandas; print('Pandas version:', pandas.__version__)\"" $Yellow
    Write-ColorOutput "  jupyter --version" $Yellow
}

Install-Python
Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")