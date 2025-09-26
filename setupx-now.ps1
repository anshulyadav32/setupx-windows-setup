# SetupX Now - Immediate access to SetupX commands
# Run this script to access SetupX functionality immediately

param(
    [string]$Command = "menu"
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# Get the current script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$setupxScript = Join-Path $scriptDir "setupx-main.ps1"

if (-not (Test-Path $setupxScript)) {
    Write-ColorOutput "ERROR: setupx-main.ps1 not found" "Red"
    Write-ColorOutput "Please run this script from the windows_scripts directory" "Yellow"
    exit 1
}

Write-ColorOutput "`nSetupX Now - Immediate SetupX Access" "Cyan"
Write-ColorOutput "Running SetupX command: $Command" "White"
Write-ColorOutput ""

# Run the setupx script with the provided command
if ($Command -eq "menu" -or $Command -eq "") {
    & $setupxScript
} else {
    & $setupxScript $Command
}
