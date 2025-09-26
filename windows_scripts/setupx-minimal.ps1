#!/usr/bin/env powershell

<#
.SYNOPSIS
setupx - Modular Windows Development Environment Setup CLI

.DESCRIPTION
The setupx CLI provides a modular approach to setting up development environments on Windows.
Each module contains multiple components that can be installed individually or as a complete set.

.PARAMETER Module
The module to interact with (web-development, mobile-development, cloud-development, etc.)

.PARAMETER Component
The specific component within a module to install/test/update

.PARAMETER Action
The action to perform: install, test, update, status, menu

.PARAMETER Force
Force reinstallation even if component is already installed

.PARAMETER AutoConfig
Automatically install all components in a module without prompts

.EXAMPLE
setupx web-development
Opens interactive menu for web development module

.EXAMPLE
setupx install web-development
Auto-installs all components in web development module

.EXAMPLE
setupx install web-development/nodejs
Installs only the Node.js component

.EXAMPLE
setupx test web-development
Tests all components in web development module

.EXAMPLE
setupx status
Shows status of all modules and components

.NOTES
Requires Administrator privileges for most installations
#>

param(
    [string]$Module,
    [string]$Component,
    [ValidateSet('install', 'test', 'update', 'status', 'menu', 'list')]
    [string]$Action = 'menu',
    [switch]$Force,
    [switch]$AutoConfig,
    [switch]$Help
)

# Script configuration
$ScriptRoot = $PSScriptRoot
$ModulesPath = Join-Path $ScriptRoot "modules"
$SharedPath = Join-Path $ScriptRoot "shared"

# Colors for output
$Global:SetupxColors = @{
    Green = "Green"
    Red = "Red"
    Yellow = "Yellow"
    Cyan = "Cyan"
    Magenta = "Magenta"
    White = "White"
    Gray = "Gray"
}

function Write-SetupxOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )

    if ($NoNewline) {
        Write-Host $Message -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-SetupxBanner {
    Write-SetupxOutput "`n" $Global:SetupxColors.White
    Write-SetupxOutput "╔══════════════════════════════════════════════════════════════╗" $Global:SetupxColors.Cyan
    Write-SetupxOutput "║                           setupx                              ║" $Global:SetupxColors.Cyan
    Write-SetupxOutput "║                                                              ║" $Global:SetupxColors.Cyan
    Write-SetupxOutput "║     Modular Windows Development Environment Setup CLI        ║" $Global:SetupxColors.White
    Write-SetupxOutput "║                                                              ║" $Global:SetupxColors.Cyan
    Write-SetupxOutput "╚══════════════════════════════════════════════════════════════╝" $Global:SetupxColors.Cyan
    Write-SetupxOutput "Transform your Windows machine into a complete development environment." $Global:SetupxColors.Gray
    Write-SetupxOutput ""
}

function Show-Help {
    Show-SetupxBanner

    Write-SetupxOutput "USAGE:" $Global:SetupxColors.Cyan
    Write-SetupxOutput "  setupx [module] [action] [options]" $Global:SetupxColors.White
    Write-SetupxOutput ""

    Write-SetupxOutput "ACTIONS:" $Global:SetupxColors.Cyan
    Write-SetupxOutput "  menu                    Show interactive menu (default)" $Global:SetupxColors.White
    Write-SetupxOutput "  install [module]        Install all components in module" $Global:SetupxColors.White
    Write-SetupxOutput "  install [module/comp]   Install specific component" $Global:SetupxColors.White
    Write-SetupxOutput "  test [module]           Test all components in module" $Global:SetupxColors.White
    Write-SetupxOutput "  status                  Show status of all modules" $Global:SetupxColors.White
    Write-SetupxOutput "  list                    List available modules and components" $Global:SetupxColors.White
    Write-SetupxOutput ""

    Write-SetupxOutput "OPTIONS:" $Global:SetupxColors.Cyan
    Write-SetupxOutput "  -Force                  Force reinstallation" $Global:SetupxColors.White
    Write-SetupxOutput "  -AutoConfig             Auto-install without prompts" $Global:SetupxColors.White
    Write-SetupxOutput "  -Help                   Show this help message" $Global:SetupxColors.White
    Write-SetupxOutput ""

    Write-SetupxOutput "EXAMPLES:" $Global:SetupxColors.Cyan
    Write-SetupxOutput "  setupx web-development              # Open web development menu" $Global:SetupxColors.Gray
    Write-SetupxOutput "  setupx install web-development      # Install all web dev components" $Global:SetupxColors.Gray
    Write-SetupxOutput "  setupx install web-development/nodejs # Install only Node.js" $Global:SetupxColors.Gray
    Write-SetupxOutput "  setupx test mobile-development      # Test mobile dev components" $Global:SetupxColors.Gray
    Write-SetupxOutput "  setupx status                       # Show all component status" $Global:SetupxColors.Gray
}

function Get-AvailableModules {
    $modules = @()
    $moduleDirectories = Get-ChildItem -Path $ModulesPath -Directory

    foreach ($moduleDir in $moduleDirectories) {
        $configPath = Join-Path $moduleDir.FullName "module.json"
        if (Test-Path $configPath) {
            try {
                $moduleConfig = Get-Content $configPath | ConvertFrom-Json
                $modules += $moduleConfig
            }
            catch {
                Write-SetupxOutput "⚠️  Warning: Could not load module config for $($moduleDir.Name)" $Global:SetupxColors.Yellow
            }
        }
    }

    return $modules | Sort-Object name
}

function Show-MainMenu {
    do {
        Clear-Host
        Show-SetupxBanner

        Write-SetupxOutput "╔═══════════════════════════════════════╗" $Global:SetupxColors.Cyan
        Write-SetupxOutput "║              MAIN MENU                ║" $Global:SetupxColors.Cyan
        Write-SetupxOutput "╚═══════════════════════════════════════╝" $Global:SetupxColors.Cyan
        Write-SetupxOutput ""

        $modules = Get-AvailableModules

        Write-SetupxOutput "📦 AVAILABLE MODULES:" $Global:SetupxColors.Magenta
        Write-SetupxOutput ""

        for ($i = 0; $i -lt $modules.Count; $i++) {
            $module = $modules[$i]
            Write-SetupxOutput "  [$($i + 1)] $($module.displayName)" $Global:SetupxColors.White
            Write-SetupxOutput "      $($module.description)" $Global:SetupxColors.Gray
        }

        Write-SetupxOutput ""
        Write-SetupxOutput "🔧 GLOBAL OPTIONS:" $Global:SetupxColors.Cyan
        Write-SetupxOutput "  [S] 📊 System Status    - Check status of all components" $Global:SetupxColors.White
        Write-SetupxOutput "  [L] 📋 List Components  - Show detailed component list" $Global:SetupxColors.White
        Write-SetupxOutput "  [H] ❓ Help            - Show help and usage examples" $Global:SetupxColors.White
        Write-SetupxOutput "  [Q] [X] Quit            - Exit setupx" $Global:SetupxColors.White
        Write-SetupxOutput ""

        $choice = Read-Host "Select module (1-$($modules.Count)) or option (S/L/H/Q)"

        if ($choice -eq "Q" -or $choice -eq "q") {
            Write-SetupxOutput "`nThank you for using setupx! 👋" $Global:SetupxColors.Green
            break
        }
        elseif ($choice -eq "S" -or $choice -eq "s") {
            Write-SetupxOutput "`n📊 System Status - All Modules" $Global:SetupxColors.Cyan
            Write-SetupxOutput "═" * 60 $Global:SetupxColors.Gray
            Write-SetupxOutput "Status check functionality will be implemented in the full version." $Global:SetupxColors.Yellow
        }
        elseif ($choice -eq "L" -or $choice -eq "l") {
            Write-SetupxOutput "`n📋 Complete Component List" $Global:SetupxColors.Cyan
            Write-SetupxOutput "Component list functionality will be implemented in the full version." $Global:SetupxColors.Yellow
        }
        elseif ($choice -eq "H" -or $choice -eq "h") {
            Show-Help
        }
        elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $modules.Count) {
            $selectedModule = $modules[[int]$choice - 1]
            Write-SetupxOutput "`n📦 Selected Module: $($selectedModule.displayName)" $Global:SetupxColors.Magenta
            Write-SetupxOutput "Module functionality will be implemented in the full version." $Global:SetupxColors.Yellow
        }
        else {
            Write-SetupxOutput "Invalid selection. Please try again." $Global:SetupxColors.Red
            Start-Sleep 2
            continue
        }

        if ($choice -in @("S", "s", "L", "l", "H", "h")) {
            Write-SetupxOutput "`nPress any key to continue..." $Global:SetupxColors.Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }

    } while ($true)
}

# Main execution logic
function Main {
    # Check if running with elevated privileges for admin-required operations
    $needsAdmin = $Action -eq 'install' -or $AutoConfig
    if ($needsAdmin -and -not (Test-Administrator)) {
        Write-SetupxOutput "⚠️  Warning: Some operations require Administrator privileges." $Global:SetupxColors.Yellow
        Write-SetupxOutput "For best results, run PowerShell as Administrator." $Global:SetupxColors.Yellow
        Write-SetupxOutput ""
    }

    # Handle help parameter
    if ($Help) {
        Show-Help
        return
    }

    # Handle different execution modes
    if ($Module -and $Module.Contains('/')) {
        # Component-specific action (e.g., "setupx install web-development/nodejs")
        Write-SetupxOutput "Component-specific actions will be implemented in the full version." $Global:SetupxColors.Yellow
    }
    elseif ($Module) {
        # Module-specific action
        if ($Action -eq 'menu') {
            # Show module menu
            $modulePath = Join-Path $ModulesPath $Module
            if (Test-Path $modulePath) {
                Write-SetupxOutput "Module menu functionality will be implemented in the full version." $Global:SetupxColors.Yellow
            } else {
                Write-SetupxOutput "[X] Module not found: $Module" $Global:SetupxColors.Red
            }
        }
        else {
            # Execute action on entire module
            Write-SetupxOutput "Module action functionality will be implemented in the full version." $Global:SetupxColors.Yellow
        }
    }
    elseif ($Action -eq 'status') {
        # Global status
        Write-SetupxOutput "`n📊 System Status - All Modules" $Global:SetupxColors.Cyan
        Write-SetupxOutput "═" * 60 $Global:SetupxColors.Gray
        Write-SetupxOutput "Status check functionality will be implemented in the full version." $Global:SetupxColors.Yellow
    }
    elseif ($Action -eq 'list') {
        # List all components
        Write-SetupxOutput "`n📋 Complete Component List" $Global:SetupxColors.Cyan
        Write-SetupxOutput "Component list functionality will be implemented in the full version." $Global:SetupxColors.Yellow
    }
    else {
        # Show main interactive menu
        Show-MainMenu
    }
}

# Execute main function if script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Main
}
