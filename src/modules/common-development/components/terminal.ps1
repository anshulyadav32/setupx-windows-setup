# Windows Terminal Component for setupx
# Installs and configures Windows Terminal

# Component configuration
$ComponentConfig = @{
    name = "terminal"
    displayName = "Windows Terminal"
    description = "Modern terminal application for Windows"

    # Executables to test
    executableNames = @("wt.exe", "wt")

    # Version commands
    versionCommands = @("wt --version")

    # Test commands
    testCommands = @("wt --version")

    # Installation settings
    requiresAdmin = $false
    category = "shell"

    # Test paths
    testPaths = @(
        "${env:LOCALAPPDATA}\Microsoft\WindowsApps\wt.exe",
        "${env:ProgramFiles}\WindowsApps\Microsoft.WindowsTerminal*\wt.exe"
    )
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-Terminal {
    param([switch]$Force, [switch]$SkipTest)

    Write-Host "`n[*] Installing Windows Terminal" -ForegroundColor Blue

    # Check current status
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-Host "[+] Windows Terminal is already installed and working!" -ForegroundColor Green
            return $testResult
        }
    }

    Write-Host "Installing Windows Terminal..." -ForegroundColor Yellow

    $installed = $false

    # Try WinGet first (recommended method)
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Installing via WinGet..." -ForegroundColor White
            winget install --id Microsoft.WindowsTerminal --silent --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Windows Terminal installed via WinGet" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] WinGet installation failed" -ForegroundColor Yellow
        }
    }

    # Try Chocolatey as fallback
    if (-not $installed -and (Get-Command "choco" -ErrorAction SilentlyContinue)) {
        try {
            Write-Host "Installing via Chocolatey..." -ForegroundColor White
            choco install microsoft-windows-terminal -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Windows Terminal installed via Chocolatey" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] Chocolatey installation failed" -ForegroundColor Yellow
        }
    }

    if (-not $installed) {
        Write-Host "[X] Failed to install Windows Terminal automatically" -ForegroundColor Red
        Write-Host "`nManual installation options:" -ForegroundColor Cyan
        Write-Host "1. Microsoft Store: Search for 'Windows Terminal'" -ForegroundColor Gray
        Write-Host "2. GitHub releases: https://github.com/microsoft/terminal/releases" -ForegroundColor Gray

        # Try to open Microsoft Store
        $openStore = Read-Host "`nWould you like to open Microsoft Store? (y/N)"
        if ($openStore -eq "y" -or $openStore -eq "Y") {
            try {
                Start-Process "ms-windows-store://pdp/?productid=9N0DX20HK701"
                Write-Host "[i] Microsoft Store opened for Windows Terminal" -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Could not open Microsoft Store" -ForegroundColor Yellow
            }
        }

        $result = [ComponentResult]::new()
        $result.Name = $ComponentConfig.displayName
        $result.Success = $false
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Automatic installation failed - manual installation required"
        return $result
    }

    # Wait for installation to complete
    Start-Sleep -Seconds 3

    # Verify installation
    $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($verifyResult.Success) {
        Write-Host "[+] Windows Terminal installation completed!" -ForegroundColor Green

        # Configure Windows Terminal
        Write-Host "`nConfiguring Windows Terminal..." -ForegroundColor Cyan

        $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

        if (Test-Path $settingsPath) {
            Write-Host "[i] Settings file found at: $settingsPath" -ForegroundColor Gray

            # Create a backup of existing settings
            $backupPath = "$settingsPath.backup"
            try {
                Copy-Item $settingsPath $backupPath -Force
                Write-Host "[i] Settings backed up to: $backupPath" -ForegroundColor Gray
            }
            catch {
                Write-Host "[!] Could not backup settings" -ForegroundColor Yellow
            }
        }

        Write-Host "`n[i] Windows Terminal Features:" -ForegroundColor Cyan
        Write-Host "  • Multiple tabs and panes" -ForegroundColor White
        Write-Host "  • GPU-accelerated text rendering" -ForegroundColor White
        Write-Host "  • Rich customization options" -ForegroundColor White
        Write-Host "  • Support for multiple shells" -ForegroundColor White
        Write-Host "  • Themes and color schemes" -ForegroundColor White

        Write-Host "`n[i] Usage:" -ForegroundColor Cyan
        Write-Host "  wt                           - Open new terminal window" -ForegroundColor White
        Write-Host "  wt -p PowerShell             - Open PowerShell profile" -ForegroundColor White
        Write-Host "  wt -p \"Command Prompt\"       - Open Command Prompt profile" -ForegroundColor White
        Write-Host "  wt new-tab                   - Open new tab" -ForegroundColor White
        Write-Host "  wt split-pane                - Split current pane" -ForegroundColor White

        Write-Host "`n[i] Keyboard Shortcuts:" -ForegroundColor Cyan
        Write-Host "  Ctrl+Shift+T                - New tab" -ForegroundColor White
        Write-Host "  Ctrl+Shift+W                - Close tab" -ForegroundColor White
        Write-Host "  Ctrl+Shift+D                - Split pane" -ForegroundColor White
        Write-Host "  Ctrl+Shift+P                - Command palette" -ForegroundColor White
        Write-Host "  Ctrl+,                      - Open settings" -ForegroundColor White

        Write-Host "`n[i] Customization:" -ForegroundColor Cyan
        Write-Host "  • Press Ctrl+, to open settings.json" -ForegroundColor Gray
        Write-Host "  • Download themes from Windows Terminal Gallery" -ForegroundColor Gray
        Write-Host "  • Install Nerd Fonts for better icons" -ForegroundColor Gray
    }

    return $verifyResult
}

function Test-Terminal {
    Write-Host "`n[*] Testing Windows Terminal Installation" -ForegroundColor Cyan

    $result = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result.Success) {
        try {
            # Get version info
            $version = wt --version 2>$null
            Write-Host "[+] Windows Terminal version: $version" -ForegroundColor Green

            # Check if settings file exists
            $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
            if (Test-Path $settingsPath) {
                Write-Host "[+] Settings file exists and is accessible" -ForegroundColor Green

                try {
                    $settings = Get-Content $settingsPath | ConvertFrom-Json
                    $profileCount = $settings.profiles.list.Count
                    Write-Host "[+] $profileCount profiles configured" -ForegroundColor Green
                }
                catch {
                    Write-Host "[!] Settings file exists but could not be parsed" -ForegroundColor Yellow
                }
            } else {
                Write-Host "[!] Settings file not found (may be first run)" -ForegroundColor Yellow
            }

            # Test launching terminal (non-blocking)
            try {
                Start-Process "wt" -ArgumentList "-w", "0", "exit" -WindowStyle Hidden -Wait
                Write-Host "[+] Windows Terminal launches successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Could not test terminal launch" -ForegroundColor Yellow
            }

            # Check for common shells
            $shells = @("PowerShell", "Command Prompt", "PowerShell 7")
            Write-Host "[i] Available shells for profiles:" -ForegroundColor Cyan

            if (Get-Command "powershell" -ErrorAction SilentlyContinue) {
                Write-Host "    • Windows PowerShell 5.1" -ForegroundColor Gray
            }

            if (Get-Command "pwsh" -ErrorAction SilentlyContinue) {
                Write-Host "    • PowerShell 7+" -ForegroundColor Gray
            }

            if (Get-Command "cmd" -ErrorAction SilentlyContinue) {
                Write-Host "    • Command Prompt" -ForegroundColor Gray
            }

        }
        catch {
            Write-Host "[!] Windows Terminal functionality test had issues" -ForegroundColor Yellow
        }
    }

    return $result
}

function Update-Terminal {
    Write-Host "`n[*] Updating Windows Terminal" -ForegroundColor Cyan

    try {
        # Try WinGet update first
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for Windows Terminal updates via WinGet..." -ForegroundColor White
            winget upgrade Microsoft.WindowsTerminal --silent
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Windows Terminal updated via WinGet" -ForegroundColor Green
                return $true
            }
        }

        # Try Chocolatey update
        if (Get-Command "choco" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for Windows Terminal updates via Chocolatey..." -ForegroundColor White
            choco upgrade microsoft-windows-terminal -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Windows Terminal updated via Chocolatey" -ForegroundColor Green
                return $true
            }
        }

        Write-Host "[!] Windows Terminal updates via Microsoft Store automatically" -ForegroundColor Yellow
        Write-Host "You can also check for updates in Microsoft Store app" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "[X] Failed to update Windows Terminal: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution logic
if ($MyInvocation.InvocationName -ne '.') {
    param(
        [ValidateSet('install', 'test', 'update')]
        [string]$Action = 'install',
        [switch]$Force,
        [switch]$SkipTest
    )

    switch ($Action.ToLower()) {
        'install' { Install-Terminal -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-Terminal }
        'update' { Update-Terminal }
    }
}

# Export functions for module use
Export-ModuleMember -Function Install-Terminal, Test-Terminal, Update-Terminal