# SetupX Modular Installer
# Handles installation of SetupX with modular structure

# Import dependencies
. "$PSScriptRoot\..\utils\logger.ps1"
. "$PSScriptRoot\..\utils\helpers.ps1"

function Install-Setupx {
    <#
    .SYNOPSIS
    Installs SetupX with modular structure
    #>
    param(
        [string]$InstallPath = "C:\setupx"
    )
    
    Write-SetupxInfo "Installing SetupX to: $InstallPath"
    
    # Create installation directory
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-SetupxSuccess "Created installation directory: $InstallPath"
    } else {
        Write-SetupxInfo "Installation directory already exists: $InstallPath"
    }
    
    # Copy source files
    $sourceDir = Join-Path $PSScriptRoot ".."
    $targetDir = $InstallPath
    
    Write-SetupxInfo "Copying SetupX files..."
    Copy-Item -Path "$sourceDir\*" -Destination $targetDir -Recurse -Force
    Write-SetupxSuccess "SetupX files copied successfully"
    
    # Create setupx.cmd wrapper
    $cmdPath = Join-Path $InstallPath "setupx.cmd"
    $cmdContent = @"
@echo off
powershell -ExecutionPolicy Bypass -File "$InstallPath\setupx.ps1" %*
"@
    
    Set-Content -Path $cmdPath -Value $cmdContent -Force
    Write-SetupxSuccess "Created setupx.cmd wrapper"
    
    # Add to PATH
    Write-SetupxInfo "Adding SetupX to system PATH..."
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notlike "*$InstallPath*") {
            $newPath = $currentPath + ";" + $InstallPath
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
            Write-SetupxSuccess "Added $InstallPath to system PATH"
        } else {
            Write-SetupxInfo "$InstallPath already in system PATH"
        }
    } catch {
        Write-SetupxWarning "Could not modify system PATH: $($_.Exception.Message)"
    }
    
    # Refresh current session PATH
    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")
    Write-SetupxSuccess "Refreshed current session PATH"
    
    Write-SetupxSuccess "SetupX installation completed successfully!"
    Write-SetupxInfo "You can now use 'setupx' command from anywhere"
}

# Functions are available for use
