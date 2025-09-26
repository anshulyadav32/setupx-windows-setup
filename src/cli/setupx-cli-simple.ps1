# SetupX CLI - Simplified Version
# Main Command Line Interface for SetupX

# Import core modules
. "$PSScriptRoot\..\core\module-manager.ps1"
. "$PSScriptRoot\..\core\package-manager.ps1"

function Show-SetupxBanner {
    Write-Host ""
    Write-Host "SETUPX v2.0 - Modular Windows Development Setup" -ForegroundColor Cyan
    Write-Host ""
}

function Show-SetupxHelp {
    Show-SetupxBanner
    Write-Host "USAGE: setupx [command] [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "COMMANDS:" -ForegroundColor Yellow
    Write-Host "  -h, -help              Show this help message" -ForegroundColor White
    Write-Host "  list                   List all available modules" -ForegroundColor White
    Write-Host "  status                 Show system status" -ForegroundColor White
    Write-Host "  install [module]       Install a specific module" -ForegroundColor White
    Write-Host "  test [module]          Test module components" -ForegroundColor White
    Write-Host "  components [module]    List module components" -ForegroundColor White
    Write-Host "  menu                   Show interactive menu" -ForegroundColor White
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  setupx -h" -ForegroundColor White
    Write-Host "  setupx list" -ForegroundColor White
    Write-Host "  setupx install package-managers" -ForegroundColor White
    Write-Host "  setupx test package-managers" -ForegroundColor White
    Write-Host "  setupx components package-managers" -ForegroundColor White
    Write-Host ""
    Write-Host "PACKAGE MANAGERS:" -ForegroundColor Yellow
    Write-Host "  WinGet (Microsoft Official)" -ForegroundColor White
    Write-Host "  Chocolatey (Community)" -ForegroundColor White
    Write-Host "  Scoop (Portable Apps)" -ForegroundColor White
    Write-Host ""
}

function Show-SetupxList {
    Show-SetupxBanner
    Write-Host "Available Development Modules:" -ForegroundColor Yellow
    Write-Host ""
    
    $modules = Get-AvailableModules
    if ($modules.Count -eq 0) {
        Write-Host "Total modules: 0" -ForegroundColor Red
        Write-Host "No modules found. Check your installation." -ForegroundColor Yellow
    } else {
        foreach ($module in $modules) {
            Write-Host "Module: $($module.DisplayName)" -ForegroundColor White
            Write-Host "  Description: $($module.Description)" -ForegroundColor Gray
            Write-Host "  Components: $($module.Components.Count)" -ForegroundColor Gray
            Write-Host ""
        }
        Write-Host "Total modules: $($modules.Count)" -ForegroundColor Green
    }
}

function Show-SetupxStatus {
    Show-SetupxBanner
    Write-Host "System Status:" -ForegroundColor Yellow
    Write-Host ""
    
    # Show package manager status
    Show-PackageManagerStatus
    
    # Show module status
    $modules = Get-AvailableModules
    Write-Host "Modules:" -ForegroundColor Yellow
    Write-Host "  Total modules: $($modules.Count)" -ForegroundColor White
    Write-Host "  Configured modules: $($modules.Count)" -ForegroundColor White
    Write-Host ""
}

function Show-SetupxComponents {
    param([string]$ModuleName)
    
    if (-not $ModuleName) {
        Write-Host "Module name required. Use: setupx components [module]" -ForegroundColor Red
        return
    }
    
    Show-SetupxBanner
    Write-Host "Components for module: $ModuleName" -ForegroundColor Yellow
    Write-Host ""
    
    $components = Get-ModuleComponents $ModuleName
    if ($components.Count -eq 0) {
        Write-Host "No components found for module: $ModuleName" -ForegroundColor Red
    } else {
        foreach ($component in $components) {
            Write-Host "Component: $($component.displayName)" -ForegroundColor White
            Write-Host "  Script: $($component.scriptName)" -ForegroundColor Gray
            Write-Host ""
        }
        Write-Host "Total components: $($components.Count)" -ForegroundColor Green
    }
}

function Show-SetupxMenu {
    Show-SetupxBanner
    Write-Host "Interactive SetupX Menu" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. List all modules" -ForegroundColor White
    Write-Host "2. Show system status" -ForegroundColor White
    Write-Host "3. Install package managers" -ForegroundColor White
    Write-Host "4. Install specific module" -ForegroundColor White
    Write-Host "5. Show help" -ForegroundColor White
    Write-Host "0. Exit" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (0-5)"
    
    switch ($choice) {
        "1" { Show-SetupxList }
        "2" { Show-SetupxStatus }
        "3" { Install-Module "package-managers" }
        "4" {
            $moduleName = Read-Host "Enter module name"
            Install-Module $moduleName
        }
        "5" { Show-SetupxHelp }
        "0" { 
            Write-Host "Goodbye!" -ForegroundColor Green
            exit
        }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Show-SetupxMenu
        }
    }
}

# Main CLI logic
param(
    [string]$Command,
    [string]$ModuleName
)

# Import logger
. "$PSScriptRoot\..\utils\logger.ps1"

# Handle commands
switch ($Command) {
    "-h" { Show-SetupxHelp }
    "-help" { Show-SetupxHelp }
    "help" { Show-SetupxHelp }
    "list" { Show-SetupxList }
    "status" { Show-SetupxStatus }
    "install" { Install-Module $ModuleName }
    "test" { 
        if ($ModuleName) {
            Write-Host "Testing module: $ModuleName" -ForegroundColor Yellow
            # Add module testing logic here
        } else {
            Write-Host "Module name required for testing" -ForegroundColor Red
        }
    }
    "components" { Show-SetupxComponents $ModuleName }
    "menu" { Show-SetupxMenu }
    default { 
        if ($Command) {
            Write-Host "Unknown command: $Command" -ForegroundColor Red
            Write-Host "Use 'setupx -h' for help" -ForegroundColor Yellow
        } else {
            Show-SetupxMenu
        }
    }
}
