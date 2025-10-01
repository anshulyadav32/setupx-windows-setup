# WSX - Windows Setup X (Short Alias)
# Simplified wrapper for setupx.ps1

param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1)]
    [string]$Component,
    
    [switch]$All,
    [switch]$Force
)

# Execute setupx.ps1 with all parameters
& "$PSScriptRoot\setupx.ps1" $Command $Component -All:$All -Force:$Force

