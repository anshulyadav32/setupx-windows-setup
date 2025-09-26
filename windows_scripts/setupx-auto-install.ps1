# SetupX Auto Install - Complete SetupX installation with PATH setup
# This script downloads SetupX to C:\setupx and sets up global PATH access

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Install-SetupXComplete {
    Write-ColorOutput "`nSetupX Auto Install - Complete Setup" "Cyan"
    Write-ColorOutput "Installing SetupX to C:\setupx with global PATH access..." "White"
    Write-ColorOutput ""

    # 1. Create SetupX directory
    $setupxDir = "C:\setupx"
    Write-ColorOutput "Creating SetupX directory..." "Magenta"
    try {
        if (-not (Test-Path $setupxDir)) {
            New-Item -ItemType Directory -Path $setupxDir -Force | Out-Null
            Write-ColorOutput "  SUCCESS: Created directory $setupxDir" "Green"
        } else {
            Write-ColorOutput "  INFO: Directory $setupxDir already exists" "Yellow"
        }
    } catch {
        Write-ColorOutput "  ERROR: Failed to create directory - $($_.Exception.Message)" "Red"
        return
    }
    Write-ColorOutput ""

    # 2. Download SetupX scripts
    Write-ColorOutput "Downloading SetupX scripts..." "Magenta"
    $baseUrl = "https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/windows_scripts/"
    $scripts = @(
        "setupx-main.ps1",
        "setupx-now.ps1", 
        "quick-setupx.ps1",
        "install-setupx-command.ps1"
    )

    foreach ($script in $scripts) {
        try {
            Write-ColorOutput "  Downloading $script..." "Yellow"
            $url = $baseUrl + $script
            $localPath = Join-Path $setupxDir $script
            Invoke-RestMethod -Uri $url -OutFile $localPath
            Write-ColorOutput "    SUCCESS: $script downloaded" "Green"
        } catch {
            Write-ColorOutput "    ERROR: Failed to download $script - $($_.Exception.Message)" "Red"
        }
    }
    Write-ColorOutput ""

    # 3. Create setupx.cmd wrapper
    Write-ColorOutput "Creating setupx.cmd wrapper..." "Magenta"
    $setupxCmd = @"
@echo off
powershell -ExecutionPolicy Bypass -File "C:\setupx\setupx-main.ps1" %*
"@
    
    try {
        $cmdPath = Join-Path $setupxDir "setupx.cmd"
        Set-Content -Path $cmdPath -Value $setupxCmd -Force
        Write-ColorOutput "  SUCCESS: setupx.cmd created" "Green"
    } catch {
        Write-ColorOutput "  ERROR: Failed to create setupx.cmd - $($_.Exception.Message)" "Red"
    }
    Write-ColorOutput ""

    # 4. Add to PATH
    Write-ColorOutput "Adding SetupX to PATH..." "Magenta"
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notlike "*$setupxDir*") {
            $newPath = $currentPath + ";" + $setupxDir
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
            Write-ColorOutput "  SUCCESS: Added $setupxDir to system PATH" "Green"
        } else {
            Write-ColorOutput "  INFO: $setupxDir already in PATH" "Yellow"
        }
    } catch {
        Write-ColorOutput "  WARNING: Could not modify system PATH - $($_.Exception.Message)" "Yellow"
        Write-ColorOutput "  INFO: You may need to restart PowerShell for PATH changes to take effect" "Cyan"
    }
    Write-ColorOutput ""

    # 5. Refresh current session PATH
    Write-ColorOutput "Refreshing current session PATH..." "Magenta"
    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")
    Write-ColorOutput "  SUCCESS: PATH refreshed for current session" "Green"
    Write-ColorOutput ""

    # 6. Test installation
    Write-ColorOutput "Testing SetupX installation..." "Magenta"
    try {
        $setupxTest = Get-Command setupx -ErrorAction SilentlyContinue
        if ($setupxTest) {
            Write-ColorOutput "  SUCCESS: setupx command is now available!" "Green"
            Write-ColorOutput "  Location: $($setupxTest.Source)" "White"
        } else {
            Write-ColorOutput "  INFO: setupx command not yet available in current session" "Yellow"
            Write-ColorOutput "  TIP: Restart PowerShell or run: refreshenv" "Cyan"
        }
    } catch {
        Write-ColorOutput "  INFO: setupx command not yet available" "Yellow"
    }
    Write-ColorOutput ""

    Show-InstallationComplete
}

function Show-InstallationComplete {
    Write-ColorOutput "`nSetupX Auto Install Complete!" "Green"
    Write-ColorOutput "SetupX has been installed to C:\setupx" "White"
    Write-ColorOutput ""
    Write-ColorOutput "What was installed:" "Cyan"
    Write-ColorOutput "  - SetupX scripts in C:\setupx\" "White"
    Write-ColorOutput "  - setupx.cmd wrapper for global access" "White"
    Write-ColorOutput "  - Added C:\setupx to system PATH" "White"
    Write-ColorOutput ""
    Write-ColorOutput "You can now use:" "Cyan"
    Write-ColorOutput "  setupx -h          # Show help" "White"
    Write-ColorOutput "  setupx list        # List modules" "White"
    Write-ColorOutput "  setupx status      # Show status" "White"
    Write-ColorOutput "  setupx menu        # Interactive menu" "White"
    Write-ColorOutput ""
    Write-ColorOutput "If setupx command is not recognized:" "Yellow"
    Write-ColorOutput "  - Restart PowerShell" "White"
    Write-ColorOutput "  - Or run: refreshenv" "White"
    Write-ColorOutput "  - Or use: C:\setupx\setupx-now.ps1" "White"
}

# Execute installation
Install-SetupXComplete
