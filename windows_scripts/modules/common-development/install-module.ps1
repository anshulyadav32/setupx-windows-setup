# Common Development Tools Module Installer
# Installs essential development tools used across all programming languages

param(
    [switch]$AutoConfig,
    [switch]$Force
)

# Get module path
$ModulePath = $PSScriptRoot
$SharedPath = Split-Path (Split-Path $ModulePath -Parent) -Parent | Join-Path -ChildPath "shared"

# Import shared functions
. "$SharedPath\component-manager.ps1"
. "$SharedPath\menu-helpers.ps1"

# Load module configuration
$moduleConfig = Get-Content "$ModulePath\module.json" | ConvertFrom-Json

Write-Host "`n[*] Installing Common Development Tools Module" -ForegroundColor Magenta
Write-Host "Essential tools that every developer needs." -ForegroundColor White

if ($AutoConfig) {
    Invoke-AutoConfig -ModuleName $moduleConfig.name -ModuleConfig $moduleConfig -ModulePath $ModulePath
} else {
    Show-ModuleMenu -ModuleName $moduleConfig.name -ModulePath $ModulePath
}