# WSX - Alias for SetupX CLI
# This is a shorter alternative command name for SetupX

param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Call the main SetupX CLI with all arguments
$setupxPath = Join-Path $PSScriptRoot "setupx.ps1"

if (Test-Path $setupxPath) {
    & $setupxPath $Command @Arguments
}
else {
    Write-Host "Error: setupx.ps1 not found in $PSScriptRoot" -ForegroundColor Red
    Write-Host "Please ensure SetupX is properly installed." -ForegroundColor Yellow
}
