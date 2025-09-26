# Package Managers Installation Script
# Installs Chocolatey, Scoop, and configures WinGet

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

function Install-PackageManagers {
    Write-ColorOutput "`n=== Installing Package Managers ===" $Cyan
    Write-ColorOutput "This will install and configure all Windows package managers:" $White
    Write-ColorOutput "• Chocolatey - The package manager for Windows" $White
    Write-ColorOutput "• Scoop - A command-line installer for Windows" $White
    Write-ColorOutput "• WinGet - Windows Package Manager (Microsoft)" $White

    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges." $Red
        exit 1
    }

    # Install Chocolatey
    Write-ColorOutput "`n=== Installing Chocolatey ===" $Cyan

    if (Get-Command "choco" -ErrorAction SilentlyContinue) {
        $chocoVersion = choco --version
        Write-ColorOutput "✓ Chocolatey is already installed: v$chocoVersion" $Green

        # Update Chocolatey
        Write-ColorOutput "Updating Chocolatey..." $Yellow
        try {
            choco upgrade chocolatey -y
            Write-ColorOutput "✓ Chocolatey updated" $Green
        } catch {
            Write-ColorOutput "! Failed to update Chocolatey" $Yellow
        }
    } else {
        Write-ColorOutput "Installing Chocolatey..." $Yellow

        try {
            # Set execution policy
            Set-ExecutionPolicy Bypass -Scope Process -Force

            # Enable TLS 1.2
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

            # Install Chocolatey
            iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

            Write-ColorOutput "✓ Chocolatey installed successfully" $Green

            # Verify installation
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            if (Get-Command "choco" -ErrorAction SilentlyContinue) {
                $chocoVersion = choco --version
                Write-ColorOutput "✓ Chocolatey verification successful: v$chocoVersion" $Green
            }
        } catch {
            Write-ColorOutput "✗ Failed to install Chocolatey: $($_.Exception.Message)" $Red
        }
    }

    # Install Scoop
    Write-ColorOutput "`n=== Installing Scoop ===" $Cyan

    if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
        $scoopVersion = scoop --version
        Write-ColorOutput "✓ Scoop is already installed: v$scoopVersion" $Green

        # Update Scoop
        Write-ColorOutput "Updating Scoop..." $Yellow
        try {
            scoop update
            Write-ColorOutput "✓ Scoop updated" $Green
        } catch {
            Write-ColorOutput "! Failed to update Scoop" $Yellow
        }
    } else {
        Write-ColorOutput "Installing Scoop..." $Yellow

        try {
            # Set execution policy for current user
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

            # Install Scoop
            iwr -useb get.scoop.sh | iex

            Write-ColorOutput "✓ Scoop installed successfully" $Green

            # Verify installation
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
                $scoopVersion = scoop --version
                Write-ColorOutput "✓ Scoop verification successful: v$scoopVersion" $Green
            }

            # Add useful Scoop buckets
            Write-ColorOutput "Adding Scoop buckets..." $Yellow
            try {
                scoop bucket add extras
                scoop bucket add versions
                scoop bucket add nonportable
                Write-ColorOutput "✓ Scoop buckets added (extras, versions, nonportable)" $Green
            } catch {
                Write-ColorOutput "! Failed to add some Scoop buckets" $Yellow
            }

        } catch {
            Write-ColorOutput "✗ Failed to install Scoop: $($_.Exception.Message)" $Red
        }
    }

    # Check WinGet
    Write-ColorOutput "`n=== Configuring WinGet ===" $Cyan

    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        $wingetVersion = winget --version
        Write-ColorOutput "✓ WinGet is available: $wingetVersion" $Green

        # Accept source agreements
        Write-ColorOutput "Configuring WinGet sources..." $Yellow
        try {
            winget source update
            Write-ColorOutput "✓ WinGet sources updated" $Green
        } catch {
            Write-ColorOutput "! WinGet source update had issues (this is often normal)" $Yellow
        }

    } else {
        Write-ColorOutput "! WinGet not found" $Yellow
        Write-ColorOutput "WinGet comes pre-installed with Windows 11 and newer Windows 10 versions." $White
        Write-ColorOutput "If you don't have it, install 'App Installer' from Microsoft Store." $White
        Write-ColorOutput "Alternatively, download from: https://github.com/microsoft/winget-cli/releases" $White
    }

    # Configure Chocolatey features
    if (Get-Command "choco" -ErrorAction SilentlyContinue) {
        Write-ColorOutput "`n=== Configuring Chocolatey Features ===" $Cyan

        try {
            choco feature enable -n allowGlobalConfirmation
            choco feature enable -n allowEmptyChecksums
            choco feature enable -n useRememberedArgumentsForUpgrades
            Write-ColorOutput "✓ Chocolatey features configured" $Green
        } catch {
            Write-ColorOutput "! Some Chocolatey features could not be configured" $Yellow
        }
    }

    # Install essential tools via package managers
    Write-ColorOutput "`n=== Installing Essential Tools ===" $Cyan
    Write-ColorOutput "Installing basic utilities via package managers..." $Yellow

    # Via Chocolatey
    if (Get-Command "choco" -ErrorAction SilentlyContinue) {
        $basicTools = @("curl", "wget", "7zip", "git")
        foreach ($tool in $basicTools) {
            try {
                choco install $tool -y --no-progress
                Write-ColorOutput "✓ $tool installed via Chocolatey" $Green
            } catch {
                Write-ColorOutput "! Failed to install $tool via Chocolatey" $Yellow
            }
        }
    }

    Write-ColorOutput "`n=== Package Managers Installation Complete ===" $Green
    Write-ColorOutput "Successfully configured Windows package managers!" $Green

    Write-ColorOutput "`n=== Installed Package Managers ===" $Cyan

    # Show versions
    if (Get-Command "choco" -ErrorAction SilentlyContinue) {
        $chocoVersion = choco --version
        Write-ColorOutput "✓ Chocolatey v$chocoVersion" $White
    }

    if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
        $scoopVersion = scoop --version
        Write-ColorOutput "✓ Scoop v$scoopVersion" $White
    }

    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        $wingetVersion = winget --version
        Write-ColorOutput "✓ WinGet $wingetVersion" $White
    }

    Write-ColorOutput "`n=== Usage Examples ===" $Cyan
    Write-ColorOutput "Chocolatey:" $White
    Write-ColorOutput "  choco install nodejs python vscode -y" $Yellow
    Write-ColorOutput "  choco upgrade all -y" $Yellow
    Write-ColorOutput "  choco search python" $Yellow

    Write-ColorOutput "`nScoop:" $White
    Write-ColorOutput "  scoop install git nodejs python" $Yellow
    Write-ColorOutput "  scoop update *" $Yellow
    Write-ColorOutput "  scoop search python" $Yellow

    Write-ColorOutput "`nWinGet:" $White
    Write-ColorOutput "  winget install Microsoft.VisualStudioCode" $Yellow
    Write-ColorOutput "  winget upgrade --all" $Yellow
    Write-ColorOutput "  winget search python" $Yellow

    Write-ColorOutput "`n=== Next Steps ===" $Cyan
    Write-ColorOutput "• Use any of the package managers to install software" $White
    Write-ColorOutput "• Chocolatey: Best for development tools and utilities" $White
    Write-ColorOutput "• Scoop: Best for portable apps and command-line tools" $White
    Write-ColorOutput "• WinGet: Microsoft's official package manager" $White
    Write-ColorOutput "• Run 'refreshenv' or restart terminal to use newly installed tools" $White
}

Install-PackageManagers
Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")