# SETUPX - Fixed One-Liner Installer
# This script sets up essential Windows development tools via Chocolatey and Scoop.
# It handles admin vs non-admin scenarios properly.

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-SetupX {
    Write-ColorOutput "`nSETUPX - One-Liner Installer" "Cyan"
    Write-ColorOutput "Setting up Windows Development Environment..." "White"
    Write-ColorOutput ""

    $isAdmin = Test-IsAdmin
    if ($isAdmin) {
        Write-ColorOutput "Running as Administrator" "Yellow"
    } else {
        Write-ColorOutput "Running as regular user" "Yellow"
    }
    Write-ColorOutput ""

    # 1. Set Execution Policy (with better error handling)
    Write-ColorOutput "Setting execution policy..." "Magenta"
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-ColorOutput "  ✅ Execution policy set to RemoteSigned for CurrentUser." "Green"
    } catch {
        Write-ColorOutput "  ⚠️ Could not set execution policy. Current policy: $(Get-ExecutionPolicy)" "Yellow"
    }
    Write-ColorOutput ""

    # 2. Install Chocolatey
    Write-ColorOutput "Installing Chocolatey..." "Magenta"
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
            Write-ColorOutput "  ✅ Chocolatey installed successfully." "Green"
        } catch {
            Write-ColorOutput "  ❌ Chocolatey installation failed: $($_.Exception.Message)" "Red"
        }
    } else {
        Write-ColorOutput "  ℹ️ Chocolatey is already installed." "Yellow"
    }
    Write-ColorOutput ""

    # 3. Install Scoop (handle admin vs non-admin)
    Write-ColorOutput "Installing Scoop..." "Magenta"
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        if ($isAdmin) {
            Write-ColorOutput "  ⚠️ Running as Administrator - Scoop installation may be restricted." "Yellow"
            Write-ColorOutput "  💡 For best results, run this script as a regular user." "Cyan"
            Write-ColorOutput "  🔄 Attempting Scoop installation anyway..." "Yellow"
        }
        
        try {
            # Set environment variable to allow admin installation
            $env:SCOOP_ALLOW_ADMIN_INSTALL = "true"
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
            Write-ColorOutput "  ✅ Scoop installed successfully." "Green"
        } catch {
            Write-ColorOutput "  ❌ Scoop installation failed: $($_.Exception.Message)" "Red"
            if ($isAdmin) {
                Write-ColorOutput "  💡 Try running as a regular user for Scoop installation." "Cyan"
            }
        }
    } else {
        Write-ColorOutput "  ℹ️ Scoop is already installed." "Yellow"
    }
    Write-ColorOutput ""

    # 4. Check WinGet
    Write-ColorOutput "Checking WinGet..." "Magenta"
    try {
        $wingetVersion = winget --version 2>$null
        if ($wingetVersion) {
            Write-ColorOutput "  ✅ WinGet is available: $wingetVersion" "Green"
        } else {
            Write-ColorOutput "  ℹ️ WinGet not found. Install from Microsoft Store or Windows Update." "Yellow"
        }
    } catch {
        Write-ColorOutput "  ℹ️ WinGet not found. Install from Microsoft Store or Windows Update." "Yellow"
    }
    Write-ColorOutput ""

    Show-PostInstallMessage
}

function Show-PostInstallMessage {
    Write-ColorOutput "`n🎉 SetupX Installation Complete!" "Green"
    Write-ColorOutput "You can now use your package managers." "White"
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
    Write-ColorOutput ""
    Write-ColorOutput "💡 Tips:" "Cyan"
    Write-ColorOutput "  • Restart PowerShell if commands are not recognized" "White"
    Write-ColorOutput "  • Run as regular user for best Scoop experience" "White"
    Write-ColorOutput "  • Check PATH environment variable if needed" "White"
}

# Execute installation
Install-SetupX
