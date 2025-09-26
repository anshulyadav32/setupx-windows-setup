# SetupX Installer
# Clean, modular installer for SetupX

param(
    [string]$InstallPath = "C:\setupx"
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Install-Setupx {
    Write-ColorOutput "`nSETUPX INSTALLER" "Cyan"
    Write-ColorOutput "Installing SetupX to: $InstallPath" "White"
    Write-ColorOutput ""
    
    # Create installation directory
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-ColorOutput "SUCCESS: Created installation directory: $InstallPath" "Green"
    } else {
        Write-ColorOutput "INFO: Installation directory already exists: $InstallPath" "Yellow"
    }
    
    # Copy source files
    $sourceDir = $PSScriptRoot
    Write-ColorOutput "Copying SetupX files..." "Magenta"
    Copy-Item -Path "$sourceDir\*" -Destination $InstallPath -Recurse -Force
    Write-ColorOutput "SUCCESS: SetupX files copied successfully" "Green"
    
    # Create setupx.cmd wrapper
    $cmdPath = Join-Path $InstallPath "setupx.cmd"
    $cmdContent = @"
@echo off
powershell -ExecutionPolicy Bypass -File "$InstallPath\setupx.ps1" %*
"@
    
    Set-Content -Path $cmdPath -Value $cmdContent -Force
    Write-ColorOutput "SUCCESS: Created setupx.cmd wrapper" "Green"
    
    # Add to PATH
    Write-ColorOutput "Adding SetupX to system PATH..." "Magenta"
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notlike "*$InstallPath*") {
            $newPath = $currentPath + ";" + $InstallPath
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
            Write-ColorOutput "SUCCESS: Added $InstallPath to system PATH" "Green"
        } else {
            Write-ColorOutput "INFO: $InstallPath already in system PATH" "Yellow"
        }
    } catch {
        Write-ColorOutput "WARNING: Could not modify system PATH: $($_.Exception.Message)" "Yellow"
    }
    
    # Refresh current session PATH
    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")
    Write-ColorOutput "SUCCESS: Refreshed current session PATH" "Green"
    
    Write-ColorOutput "`nSetupX installation completed successfully!" "Green"
    Write-ColorOutput "You can now use 'setupx' command from anywhere!" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Test your installation:" "Cyan"
    Write-ColorOutput "  setupx -h          # Show help" "White"
    Write-ColorOutput "  setupx list        # List modules" "White"
    Write-ColorOutput "  setupx status      # Show status" "White"
    Write-ColorOutput "  setupx menu        # Interactive menu" "White"
}

# Execute installation
Install-Setupx
