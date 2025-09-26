# setupx CLI Tools Installation Script
# Installs essential command line tools for development

# Requires Administrator privileges
#Requires -RunAsAdministrator

param(
    [switch]$Verbose,
    [switch]$NoConfirm
)

# Set error action preference
$ErrorActionPreference = "Continue"

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

# Function to write colored output
function Write-ColorOutput($Message, $Color = "White") {
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to install package managers if not present
function Install-PackageManagers {
    Write-ColorOutput "`n=== Installing Package Managers ===" $Cyan

    # Check for Chocolatey
    if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Installing Chocolatey..." $Yellow
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Write-ColorOutput "✓ Chocolatey installed successfully" $Green
        }
        catch {
            Write-ColorOutput "✗ Failed to install Chocolatey: $($_.Exception.Message)" $Red
        }
    }
    else {
        Write-ColorOutput "✓ Chocolatey already installed" $Green
    }

    # Check for Scoop
    if (-not (Get-Command "scoop" -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "Installing Scoop..." $Yellow
        try {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            iwr -useb get.scoop.sh | iex
            Write-ColorOutput "✓ Scoop installed successfully" $Green
        }
        catch {
            Write-ColorOutput "✗ Failed to install Scoop: $($_.Exception.Message)" $Red
        }
    }
    else {
        Write-ColorOutput "✓ Scoop already installed" $Green
    }

    # Check for WinGet (usually pre-installed on Windows 11)
    if (-not (Get-Command "winget" -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "WinGet not found. Please install from Microsoft Store." $Yellow
    }
    else {
        Write-ColorOutput "✓ WinGet already available" $Green
    }
}

# Function to install a package with fallback options
function Install-Package {
    param(
        [string]$Name,
        [string]$ChocoName = $Name,
        [string]$ScoopName = $Name,
        [string]$WingetName = $Name,
        [string]$DisplayName = $Name
    )

    Write-ColorOutput "`nInstalling $DisplayName..." $Yellow

    # Try Chocolatey first
    if (Get-Command "choco" -ErrorAction SilentlyContinue) {
        try {
            choco install $ChocoName -y --no-progress
            Write-ColorOutput "✓ $DisplayName installed via Chocolatey" $Green
            return $true
        }
        catch {
            Write-ColorOutput "! Chocolatey installation failed for $DisplayName" $Yellow
        }
    }

    # Try WinGet second
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            winget install --id $WingetName --silent --accept-source-agreements --accept-package-agreements
            Write-ColorOutput "✓ $DisplayName installed via WinGet" $Green
            return $true
        }
        catch {
            Write-ColorOutput "! WinGet installation failed for $DisplayName" $Yellow
        }
    }

    # Try Scoop last
    if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
        try {
            scoop install $ScoopName
            Write-ColorOutput "✓ $DisplayName installed via Scoop" $Green
            return $true
        }
        catch {
            Write-ColorOutput "! Scoop installation failed for $DisplayName" $Yellow
        }
    }

    Write-ColorOutput "✗ Failed to install $DisplayName with any package manager" $Red
    return $false
}

# Main installation function
function Install-CLITools {
    Write-ColorOutput "`n=== setupx CLI Tools Installation ===" $Cyan
    Write-ColorOutput "This will install essential command line tools for development`n" $White

    # Check administrator privileges
    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges. Please run as Administrator." $Red
        exit 1
    }

    # Install package managers first
    Install-PackageManagers

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    Write-ColorOutput "`n=== Installing CLI Tools ===" $Cyan

    # Core Development Tools
    Install-Package -Name "git" -ChocoName "git" -ScoopName "git" -WingetName "Git.Git" -DisplayName "Git"
    Install-Package -Name "gh" -ChocoName "gh" -ScoopName "gh" -WingetName "GitHub.cli" -DisplayName "GitHub CLI"
    Install-Package -Name "nodejs" -ChocoName "nodejs" -ScoopName "nodejs" -WingetName "OpenJS.NodeJS" -DisplayName "Node.js"
    Install-Package -Name "python" -ChocoName "python" -ScoopName "python" -WingetName "Python.Python.3.12" -DisplayName "Python"

    # PowerShell and Terminal
    Install-Package -Name "pwsh" -ChocoName "pwsh" -ScoopName "pwsh" -WingetName "Microsoft.PowerShell" -DisplayName "PowerShell Core"
    Install-Package -Name "microsoft-windows-terminal" -ChocoName "microsoft-windows-terminal" -ScoopName "windows-terminal" -WingetName "Microsoft.WindowsTerminal" -DisplayName "Windows Terminal"

    # Essential CLI utilities
    Install-Package -Name "curl" -ChocoName "curl" -ScoopName "curl" -WingetName "cURL.cURL" -DisplayName "cURL"
    Install-Package -Name "wget" -ChocoName "wget" -ScoopName "wget" -WingetName "JernejSimoncic.Wget" -DisplayName "Wget"
    Install-Package -Name "jq" -ChocoName "jq" -ScoopName "jq" -WingetName "jqlang.jq" -DisplayName "jq (JSON processor)"
    Install-Package -Name "7zip" -ChocoName "7zip" -ScoopName "7zip" -WingetName "7zip.7zip" -DisplayName "7-Zip"

    # Development utilities
    Install-Package -Name "vscode" -ChocoName "vscode" -ScoopName "vscode" -WingetName "Microsoft.VisualStudioCode" -DisplayName "Visual Studio Code"

    Write-ColorOutput "`n=== Updating npm to latest version ===" $Cyan
    try {
        if (Get-Command "npm" -ErrorAction SilentlyContinue) {
            npm install -g npm@latest
            Write-ColorOutput "✓ npm updated to latest version" $Green
        }
    }
    catch {
        Write-ColorOutput "! Failed to update npm" $Yellow
    }

    # Install useful global npm packages
    Write-ColorOutput "`n=== Installing Global npm Packages ===" $Cyan
    $npmPackages = @(
        "yarn",
        "typescript",
        "ts-node",
        "@angular/cli",
        "create-react-app",
        "vue-cli",
        "nodemon",
        "live-server",
        "http-server"
    )

    foreach ($package in $npmPackages) {
        try {
            if (Get-Command "npm" -ErrorAction SilentlyContinue) {
                Write-ColorOutput "Installing npm package: $package..." $Yellow
                npm install -g $package --silent
                Write-ColorOutput "✓ $package installed globally" $Green
            }
        }
        catch {
            Write-ColorOutput "! Failed to install npm package: $package" $Yellow
        }
    }

    # Update pip and install essential Python packages
    Write-ColorOutput "`n=== Installing Python Packages ===" $Cyan
    try {
        if (Get-Command "pip" -ErrorAction SilentlyContinue) {
            pip install --upgrade pip
            pip install virtualenv pipenv pytest requests beautifulsoup4 pandas numpy matplotlib
            Write-ColorOutput "✓ Essential Python packages installed" $Green
        }
    }
    catch {
        Write-ColorOutput "! Failed to install Python packages" $Yellow
    }

    # Refresh environment
    Write-ColorOutput "`n=== Refreshing Environment ===" $Cyan
    try {
        # Update current session PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-ColorOutput "✓ Environment variables refreshed" $Green
    }
    catch {
        Write-ColorOutput "! Failed to refresh environment variables" $Yellow
    }

    Write-ColorOutput "`n=== Installation Complete! ===" $Green
    Write-ColorOutput "Essential CLI tools have been installed successfully." $Green
    Write-ColorOutput "`nInstalled tools:" $Cyan
    Write-ColorOutput "• Git & GitHub CLI" $White
    Write-ColorOutput "• Node.js & npm with global packages" $White
    Write-ColorOutput "• Python with pip and essential packages" $White
    Write-ColorOutput "• PowerShell Core & Windows Terminal" $White
    Write-ColorOutput "• Essential CLI utilities (curl, wget, jq, 7-zip)" $White
    Write-ColorOutput "• Visual Studio Code" $White
    Write-ColorOutput "`nPlease restart your terminal to use the new tools." $Yellow
}

# Run the installation
try {
    Install-CLITools
}
catch {
    Write-ColorOutput "`n✗ Installation failed: $($_.Exception.Message)" $Red
    exit 1
}

Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")