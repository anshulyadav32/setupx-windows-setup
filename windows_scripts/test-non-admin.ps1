# Test script to simulate non-admin behavior
# This script will show what happens when running as non-admin

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-ColorOutput "`nSETUPX - Non-Admin Test" "Cyan"
Write-ColorOutput "Testing non-admin behavior..." "White"
Write-ColorOutput ""

$isAdmin = Test-IsAdmin
if ($isAdmin) {
    Write-ColorOutput "Running as Administrator" "Yellow"
} else {
    Write-ColorOutput "Running as regular user" "Yellow"
}
Write-ColorOutput ""

# Simulate the Scoop installation logic
Write-ColorOutput "Installing Scoop..." "Magenta"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    if ($isAdmin) {
        Write-ColorOutput "  WARNING: Running as Administrator - Scoop installation is restricted." "Yellow"
        Write-ColorOutput "  INFO: Scoop cannot be installed as administrator by default." "Yellow"
        Write-ColorOutput "  SOLUTION: Please run this script as a regular user for Scoop installation." "Cyan"
        Write-ColorOutput "  ALTERNATIVE: Use Chocolatey to install Scoop: choco install scoop" "Cyan"
    } else {
        Write-ColorOutput "  INFO: Running as regular user - Scoop installation should work." "Green"
        Write-ColorOutput "  SUCCESS: Scoop installation would proceed normally." "Green"
    }
} else {
    Write-ColorOutput "  INFO: Scoop is already installed." "Yellow"
}

Write-ColorOutput ""
Write-ColorOutput "Test Complete!" "Green"
