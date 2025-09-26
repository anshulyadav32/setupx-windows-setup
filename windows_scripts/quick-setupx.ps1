# Quick SetupX - Run SetupX commands directly
# This script provides immediate access to SetupX functionality

param(
    [string]$Command = "menu"
)

# Get the current script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$setupxScript = Join-Path $scriptDir "setupx-main.ps1"

if (-not (Test-Path $setupxScript)) {
    Write-Host "ERROR: setupx-main.ps1 not found" -ForegroundColor Red
    Write-Host "Please run this script from the windows_scripts directory" -ForegroundColor Yellow
    exit 1
}

# Run the setupx script with the provided command
if ($Command -eq "menu" -or $Command -eq "") {
    & $setupxScript
} else {
    & $setupxScript $Command
}
