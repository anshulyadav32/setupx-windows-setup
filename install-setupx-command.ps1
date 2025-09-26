# Install SetupX as a global command
# This script makes 'setupx' available as a command from anywhere

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Install-SetupXCommand {
    Write-ColorOutput "`nInstalling SetupX as global command..." "Cyan"
    Write-ColorOutput "This will make 'setupx' available from anywhere." "White"
    Write-ColorOutput ""

    # Get the current script directory
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $setupxScript = Join-Path $scriptDir "setupx-main.ps1"
    
    if (-not (Test-Path $setupxScript)) {
        Write-ColorOutput "ERROR: setupx-main.ps1 not found in $scriptDir" "Red"
        return
    }

    # Create a setupx.cmd file in a directory that's in PATH
    $setupxCmd = @"
@echo off
powershell -ExecutionPolicy Bypass -File "$setupxScript" %*
"@

    # Try to install to a directory in PATH
    $installPaths = @(
        "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps",
        "$env:ProgramFiles\SetupX",
        "$env:ProgramFiles(x86)\SetupX"
    )

    $installed = $false
    foreach ($path in $installPaths) {
        try {
            if (-not (Test-Path $path)) {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
            }
            
            $cmdPath = Join-Path $path "setupx.cmd"
            $cmdPath | Set-Content -Value $setupxCmd -Force
            
            Write-ColorOutput "SUCCESS: SetupX command installed to $path" "Green"
            Write-ColorOutput "You can now use 'setupx' from anywhere!" "Green"
            $installed = $true
            break
        }
        catch {
            Write-ColorOutput "Failed to install to $path : $($_.Exception.Message)" "Yellow"
        }
    }

    if (-not $installed) {
        Write-ColorOutput "WARNING: Could not install to standard locations." "Yellow"
        Write-ColorOutput "You can manually run: .\setupx-main.ps1" "Cyan"
    }

    Write-ColorOutput ""
    Write-ColorOutput "Test the installation:" "Cyan"
    Write-ColorOutput "  setupx -h" "White"
    Write-ColorOutput "  setupx list" "White"
    Write-ColorOutput "  setupx status" "White"
}

Install-SetupXCommand
