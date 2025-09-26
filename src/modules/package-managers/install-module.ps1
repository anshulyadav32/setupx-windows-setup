# Package Managers Module Installer
# Installs all package managers: Chocolatey, Scoop, and WinGet

param(
    [switch]$AutoConfig,
    [switch]$Force
)

# Get module path
$ModulePath = $PSScriptRoot
$SharedPath = Split-Path (Split-Path $ModulePath) -Name | Join-Path (Split-Path (Split-Path $ModulePath)) "shared"

# Import shared functions
. "$SharedPath\component-manager.ps1"
. "$SharedPath\menu-helpers.ps1"

# Load module configuration
$moduleConfig = Get-Content "$ModulePath\module.json" | ConvertFrom-Json

Write-SetupxOutput "`n🏗️  Installing Package Managers Module" $Global:SetupxColors.Magenta
Write-SetupxOutput "This module provides the foundation for all other installations." $Global:SetupxColors.White

if ($AutoConfig) {
    Invoke-AutoConfig -ModuleName $moduleConfig.name -ModuleConfig $moduleConfig -ModulePath $ModulePath
} else {
    Show-ModuleMenu -ModuleName $moduleConfig.name -ModulePath $ModulePath
}