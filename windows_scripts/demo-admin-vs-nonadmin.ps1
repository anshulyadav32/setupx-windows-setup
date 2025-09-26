# Demo script showing admin vs non-admin behavior
# This demonstrates what the one-liner script does in different scenarios

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-ColorOutput "`nSETUPX - Admin vs Non-Admin Demo" "Cyan"
Write-ColorOutput "Demonstrating different behaviors..." "White"
Write-ColorOutput ""

$isAdmin = Test-IsAdmin
Write-ColorOutput "Current user context: $(if ($isAdmin) { 'Administrator' } else { 'Regular User' })" "Yellow"
Write-ColorOutput ""

# Show what happens in admin scenario
Write-ColorOutput "=== ADMIN SCENARIO ===" "Magenta"
Write-ColorOutput "When running as Administrator:" "White"
Write-ColorOutput "  WARNING: Running as Administrator - Scoop installation is restricted." "Yellow"
Write-ColorOutput "  INFO: Scoop cannot be installed as administrator by default." "Yellow"
Write-ColorOutput "  SOLUTION: Please run this script as a regular user for Scoop installation." "Cyan"
Write-ColorOutput "  ALTERNATIVE: Use Chocolatey to install Scoop: choco install scoop" "Cyan"
Write-ColorOutput ""

# Show what happens in non-admin scenario
Write-ColorOutput "=== NON-ADMIN SCENARIO ===" "Magenta"
Write-ColorOutput "When running as Regular User:" "White"
Write-ColorOutput "  INFO: Running as regular user - Scoop installation should work." "Green"
Write-ColorOutput "  SUCCESS: Scoop installation would proceed normally." "Green"
Write-ColorOutput "  INFO: Scoop would be installed via: Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression" "Green"
Write-ColorOutput ""

Write-ColorOutput "=== SUMMARY ===" "Cyan"
Write-ColorOutput "The one-liner script now handles both scenarios properly:" "White"
Write-ColorOutput "  • Admin users: Get clear explanation and alternatives" "White"
Write-ColorOutput "  • Non-admin users: Scoop installs normally" "White"
Write-ColorOutput "  • No more confusing 'Abort' messages" "White"
Write-ColorOutput "  • Clear guidance for all users" "White"
Write-ColorOutput ""
Write-ColorOutput "Demo Complete!" "Green"
