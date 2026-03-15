# STX - Short alias for SetupX CLI

param(
    [switch]$i,
    [Parameter(Position=0)]
    [string]$Command,
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

$setupxPath = Join-Path $PSScriptRoot "setupx.ps1"

if (Test-Path $setupxPath) {
    if ($i) {
        if ($Command) {
            & $setupxPath -i $Command @Arguments
        } else {
            & $setupxPath -i @Arguments
        }
    } else {
        & $setupxPath $Command @Arguments
    }
} else {
    Write-Host "Error: setupx.ps1 not found in $PSScriptRoot" -ForegroundColor Red
    Write-Host "Please ensure SetupX is properly installed." -ForegroundColor Yellow
}
