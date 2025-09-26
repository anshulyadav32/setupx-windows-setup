#!/usr/bin/env powershell

param(
    [string]$Module,
    [string]$Component,
    [string]$Action = 'menu',
    [switch]$Force,
    [switch]$AutoConfig,
    [switch]$Help
)

# Script configuration
$ScriptRoot = $PSScriptRoot
$ModulesPath = Join-Path $ScriptRoot "modules"

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
    Write-SetupxOutput "This is a demo version of setupx." $Global:SetupxColors.Green
}

function Get-AvailableModules {
    $modules = @()
    if (Test-Path $ModulesPath) {
        $moduleDirectories = Get-ChildItem -Path $ModulesPath -Directory
        foreach ($moduleDir in $moduleDirectories) {
            $configPath = Join-Path $moduleDir.FullName "module.json"
            if (Test-Path $configPath) {
                try {
                    $moduleConfig = Get-Content $configPath | ConvertFrom-Json
                    $modules += $moduleConfig
                }
                catch {
                    Write-SetupxOutput "Warning: Could not load module config for $($moduleDir.Name)" $Global:SetupxColors.Yellow
                }
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

        if ($modules.Count -eq 0) {
            Write-SetupxOutput "  No modules found in the modules directory." $Global:SetupxColors.Yellow
            Write-SetupxOutput "  Modules path: $ModulesPath" $Global:SetupxColors.Gray
        } else {
            for ($i = 0; $i -lt $modules.Count; $i++) {
                $module = $modules[$i]
                Write-SetupxOutput "  [$($i + 1)] $($module.displayName)" $Global:SetupxColors.White
                Write-SetupxOutput "      $($module.description)" $Global:SetupxColors.Gray
            }
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
if ($Help) {
    Show-Help
    return
}

if ($Module) {
    Write-SetupxOutput "Module-specific functionality will be implemented in the full version." $Global:SetupxColors.Yellow
    Write-SetupxOutput "Requested module: $Module" $Global:SetupxColors.White
    Write-SetupxOutput "Requested action: $Action" $Global:SetupxColors.White
} else {
    Show-MainMenu
}
