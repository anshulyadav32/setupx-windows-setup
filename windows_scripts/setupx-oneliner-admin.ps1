# SETUPX - Admin-Friendly One-Liner Installer
# This script sets up essential Windows development tools via Chocolatey and Scoop.
# It handles admin scenarios by using Chocolatey to install Scoop when needed.

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
    Write-ColorOutput "`nSETUPX - Admin-Friendly One-Liner Installer" "Cyan"
    Write-ColorOutput "Setting up Windows Development Environment..." "White"
    Write-ColorOutput ""

    $isAdmin = Test-IsAdmin
    if ($isAdmin) {
        Write-ColorOutput "Running as Administrator" "Yellow"
    } else {
        Write-ColorOutput "Running as regular user" "Yellow"
    }
    Write-ColorOutput ""

    # 1. Check Execution Policy (only set if needed)
    Write-ColorOutput "Checking execution policy..." "Magenta"
    $currentPolicy = Get-ExecutionPolicy
    Write-ColorOutput "  Current execution policy: $currentPolicy" "White"
    
    if ($currentPolicy -eq "Restricted") {
        Write-ColorOutput "  Setting execution policy to allow script execution..." "Yellow"
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
            $newPolicy = Get-ExecutionPolicy
            Write-ColorOutput "  SUCCESS: Execution policy updated to $newPolicy" "Green"
        } catch {
            Write-ColorOutput "  INFO: Execution policy unchanged (may be overridden by Group Policy)" "Yellow"
        }
    } else {
        Write-ColorOutput "  INFO: Execution policy is already permissive ($currentPolicy)" "Green"
    }
    Write-ColorOutput ""

    # 2. Install Chocolatey
    Write-ColorOutput "Installing Chocolatey..." "Magenta"
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
            Write-ColorOutput "  SUCCESS: Chocolatey installed successfully." "Green"
        } catch {
            Write-ColorOutput "  ERROR: Chocolatey installation failed: $($_.Exception.Message)" "Red"
        }
    } else {
        Write-ColorOutput "  INFO: Chocolatey is already installed." "Yellow"
    }
    Write-ColorOutput ""

    # 3. Install Scoop (admin-friendly approach)
    Write-ColorOutput "Installing Scoop..." "Magenta"
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        if ($isAdmin) {
            Write-ColorOutput "  INFO: Running as Administrator - Using Chocolatey to install Scoop." "Yellow"
            try {
                choco install scoop --yes
                Write-ColorOutput "  SUCCESS: Scoop installed via Chocolatey." "Green"
            } catch {
                Write-ColorOutput "  ERROR: Scoop installation via Chocolatey failed: $($_.Exception.Message)" "Red"
                Write-ColorOutput "  TIP: Try running as a regular user for direct Scoop installation." "Cyan"
            }
        } else {
            try {
                Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
                Write-ColorOutput "  SUCCESS: Scoop installed successfully." "Green"
            } catch {
                Write-ColorOutput "  ERROR: Scoop installation failed: $($_.Exception.Message)" "Red"
            }
        }
    } else {
        Write-ColorOutput "  INFO: Scoop is already installed." "Yellow"
    }
    Write-ColorOutput ""

    # 4. Check WinGet
    Write-ColorOutput "Checking WinGet..." "Magenta"
    try {
        $wingetVersion = winget --version 2>$null
        if ($wingetVersion) {
            Write-ColorOutput "  SUCCESS: WinGet is available: $wingetVersion" "Green"
        } else {
            Write-ColorOutput "  INFO: WinGet not found. Install from Microsoft Store or Windows Update." "Yellow"
        }
    } catch {
        Write-ColorOutput "  INFO: WinGet not found. Install from Microsoft Store or Windows Update." "Yellow"
    }
    Write-ColorOutput ""

    Show-PostInstallMessage
}

function Show-PostInstallMessage {
    Write-ColorOutput "`nSetupX Installation Complete!" "Green"
    Write-ColorOutput "You can now use your package managers." "White"
    Write-ColorOutput ""
    Write-ColorOutput "Test your package managers:" "Cyan"
    Write-ColorOutput "  choco --version" "White"
    Write-ColorOutput "  scoop --version" "White"
    Write-ColorOutput "  winget --version" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Install software with:" "Cyan"
    Write-ColorOutput "  choco install [package]" "White"
    Write-ColorOutput "  scoop install [package]" "White"
    Write-ColorOutput "  winget install [package]" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Tips:" "Cyan"
    Write-ColorOutput "  - Restart PowerShell if commands are not recognized" "White"
    Write-ColorOutput "  - Run as regular user for best Scoop experience" "White"
    Write-ColorOutput "  - Check PATH environment variable if needed" "White"
}

# Execute installation
Install-SetupX
