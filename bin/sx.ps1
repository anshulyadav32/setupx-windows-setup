# SX - Main CLI entry point for SetupX

param(
    [Parameter(Position=0)]
    [string]$Command,
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Import core logic from src/core/engine.ps1
. "$PSScriptRoot/../src/core/engine.ps1"

# Call the main engine function
Invoke-SetupXEngine -Command $Command -Arguments $Arguments
