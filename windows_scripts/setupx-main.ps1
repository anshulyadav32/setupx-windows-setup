#!/usr/bin/env powershell
# SETUPX - Main Command Line Interface
param(
    [string]$Action = "help",
    [string]$Module = "",
    [switch]$Help
)

function Write-Output {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Banner {
    Write-Output ""
    Write-Output "SETUPX v2.0 - Modular Windows Development Setup" "Cyan"
    Write-Output ""
}

function Show-Help {
    Show-Banner
    Write-Output "USAGE:" "Magenta"
    Write-Output "  setupx [command] [options]" "White"
    Write-Output ""
    Write-Output "COMMANDS:" "Magenta"
    Write-Output "  -h, -help              Show this help message" "White"
    Write-Output "  list                   List all available modules" "White"
    Write-Output "  status                 Show system status" "White"
    Write-Output "  install <module>       Install a specific module" "White"
    Write-Output "  test <module>          Test module components" "White"
    Write-Output "  components <module>    List module components" "White"
    Write-Output "  menu                   Show interactive menu" "White"
    Write-Output ""
    Write-Output "EXAMPLES:" "Magenta"
    Write-Output "  setupx -h" "White"
    Write-Output "  setupx list" "White"
    Write-Output "  setupx install package-managers" "White"
    Write-Output "  setupx test package-managers" "White"
    Write-Output "  setupx components package-managers" "White"
    Write-Output ""
    Write-Output "PACKAGE MANAGERS:" "Magenta"
    Write-Output "  • WinGet (Microsoft Official)" "White"
    Write-Output "  • Chocolatey (Community)" "White"
    Write-Output "  • Scoop (Portable Apps)" "White"
}

function Get-AvailableModules {
    $modules = @()
    $modulesPath = Join-Path $PSScriptRoot "modules"
    
    if (Test-Path $modulesPath) {
        $moduleDirectories = Get-ChildItem -Path $modulesPath -Directory
        foreach ($moduleDir in $moduleDirectories) {
            $configPath = Join-Path $moduleDir.FullName "module.json"
            $moduleInfo = @{
                Name = $moduleDir.Name
                Path = $moduleDir.FullName
                HasConfig = Test-Path $configPath
            }
            
            if ($moduleInfo.HasConfig) {
                try {
                    $config = Get-Content $configPath -Raw | ConvertFrom-Json
                    $moduleInfo.Description = $config.description
                    $moduleInfo.Components = $config.components
                }
                catch {
                    $moduleInfo.Description = "Configuration error"
                    $moduleInfo.Components = @()
                }
            }
            else {
                $moduleInfo.Description = "No configuration found"
                $moduleInfo.Components = @()
            }
            
            $modules += $moduleInfo
        }
    }
    
    return $modules
}

function Get-PackageManagers {
    $managers = @()
    
    # Check WinGet
    try {
        $wingetVersion = winget --version 2>$null
        if ($wingetVersion) {
            $managers += @{
                Name = "WinGet"
                Available = $true
                Version = $wingetVersion
                Type = "Microsoft Official"
            }
        }
    }
    catch {
        $managers += @{
            Name = "WinGet"
            Available = $false
            Version = "Not installed"
            Type = "Microsoft Official"
        }
    }
    
    # Check Chocolatey
    try {
        $chocoVersion = choco --version 2>$null
        if ($chocoVersion) {
            $managers += @{
                Name = "Chocolatey"
                Available = $true
                Version = $chocoVersion
                Type = "Community"
            }
        }
    }
    catch {
        $managers += @{
            Name = "Chocolatey"
            Available = $false
            Version = "Not installed"
            Type = "Community"
        }
    }
    
    # Check Scoop
    try {
        $scoopVersion = scoop --version 2>$null
        if ($scoopVersion) {
            $managers += @{
                Name = "Scoop"
                Available = $true
                Version = $scoopVersion
                Type = "Portable"
            }
        }
    }
    catch {
        $managers += @{
            Name = "Scoop"
            Available = $false
            Version = "Not installed"
            Type = "Portable"
        }
    }
    
    return $managers
}

function Show-ModuleList {
    Show-Banner
    Write-Output "Available Development Modules:" "Magenta"
    Write-Output ""
    
    $modules = Get-AvailableModules
    foreach ($module in $modules) {
        $status = if ($module.HasConfig) { "OK" } else { "WARN" }
        Write-Output "  $status $($module.Name)" "White"
        Write-Output "     Description: $($module.Description)" "Gray"
        Write-Output "     Components: $($module.Components.Count)" "Gray"
        Write-Output ""
    }
    
    Write-Output "Total modules: $($modules.Count)" "Magenta"
}

function Show-SystemStatus {
    Show-Banner
    Write-Output "System Status:" "Magenta"
    Write-Output ""
    
    # Package managers
    Write-Output "Package Managers:" "Magenta"
    $managers = Get-PackageManagers
    foreach ($manager in $managers) {
        $status = if ($manager.Available) { "OK" } else { "MISSING" }
        Write-Output "  $status $($manager.Name) ($($manager.Type))" "White"
        Write-Output "     Version: $($manager.Version)" "Gray"
    }
    
    # Modules
    Write-Output ""
    Write-Output "Modules:" "Magenta"
    $modules = Get-AvailableModules
    $configuredModules = ($modules | Where-Object { $_.HasConfig }).Count
    Write-Output "  Total modules: $($modules.Count)" "White"
    Write-Output "  Configured modules: $configuredModules" "White"
}

function Show-ModuleComponents {
    param([string]$ModuleName)
    
    if (!$ModuleName) {
        Write-Output "Module name required. Use: setupx components <module>" "Red"
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-Output "Module '$ModuleName' not found" "Red"
        return
    }
    
    Show-Banner
    Write-Output "Components in '$ModuleName' module:" "Magenta"
    Write-Output ""
    
    if ($module.Components) {
        foreach ($component in $module.Components) {
            Write-Output "  - $($component.name)" "White"
            Write-Output "    Description: $($component.description)" "Gray"
            Write-Output "    Package: $($component.package)" "Gray"
            Write-Output ""
        }
    }
    else {
        Write-Output "  No components configured" "Yellow"
    }
}

function Test-ModuleComponents {
    param([string]$ModuleName)
    
    if (!$ModuleName) {
        Write-Output "Module name required. Use: setupx test <module>" "Red"
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-Output "Module '$ModuleName' not found" "Red"
        return
    }
    
    Show-Banner
    Write-Output "Testing components in '$ModuleName' module:" "Magenta"
    Write-Output ""
    
    if ($module.Components) {
        $totalComponents = $module.Components.Count
        $installedComponents = 0
        
        foreach ($component in $module.Components) {
            Write-Output "Testing $($component.name)..." "White" -NoNewline
            
            # Simple test - check if command exists
            $testCommand = $component.testCommand
            if ($testCommand) {
                try {
                    $output = Invoke-Expression $testCommand 2>$null
                    if ($LASTEXITCODE -eq 0 -or $output) {
                        Write-Output " OK" "Green"
                        $installedComponents++
                    }
                    else {
                        Write-Output " MISSING" "Red"
                    }
                }
                catch {
                    Write-Output " MISSING" "Red"
                }
            }
            else {
                Write-Output " NO TEST" "Yellow"
            }
        }
        
        Write-Output ""
        Write-Output "Test Results:" "Magenta"
        Write-Output "  Installed: $installedComponents/$totalComponents" "White"
        $percentage = [math]::Round(($installedComponents / $totalComponents) * 100, 1)
        Write-Output "  Completion: $percentage%" "White"
    }
    else {
        Write-Output "  No components to test" "Yellow"
    }
}

function Install-Module {
    param([string]$ModuleName)
    
    if (!$ModuleName) {
        Write-Output "Module name required. Use: setupx install <module>" "Red"
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-Output "Module '$ModuleName' not found" "Red"
        return
    }
    
    Show-Banner
    Write-Output "Installing '$ModuleName' module:" "Magenta"
    Write-Output ""
    
    if ($module.Components) {
        $totalComponents = $module.Components.Count
        $installedComponents = 0
        
        foreach ($component in $module.Components) {
            Write-Output "Installing $($component.displayName)..." "White"
            
            # Get the component script path
            $componentScript = Join-Path $PSScriptRoot "modules\$ModuleName\components\$($component.scriptName)"
            
            if (Test-Path $componentScript) {
                try {
                    Write-Output "  Running installation script..." "Gray"
                    
                    # Execute the component installation script
                    & $componentScript
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Output "  Status: Installed successfully" "Green"
                        $installedComponents++
                    } else {
                        Write-Output "  Status: Installation failed" "Red"
                    }
                }
                catch {
                    Write-Output "  Status: Installation error - $($_.Exception.Message)" "Red"
                }
            } else {
                Write-Output "  Status: Installation script not found" "Yellow"
            }
            
            Write-Output ""
        }
        
        Write-Output "Installation Results:" "Magenta"
        Write-Output "  Components processed: $installedComponents/$totalComponents" "White"
        $percentage = [math]::Round(($installedComponents / $totalComponents) * 100, 1)
        Write-Output "  Success rate: $percentage%" "White"
    }
    else {
        Write-Output "  No components to install" "Yellow"
    }
}

function Show-InteractiveMenu {
    Show-Banner
    Write-Output "Interactive Menu:" "Magenta"
    Write-Output ""
    Write-Output "1. List all modules" "White"
    Write-Output "2. Show system status" "White"
    Write-Output "3. Install module" "White"
    Write-Output "4. Test module components" "White"
    Write-Output "5. Show module components" "White"
    Write-Output "6. Exit" "White"
    Write-Output ""
    
    $choice = Read-Host "Select option (1-6)"
    
    switch ($choice) {
        "1" { Show-ModuleList }
        "2" { Show-SystemStatus }
        "3" {
            $moduleName = Read-Host "Enter module name"
            Install-Module -ModuleName $moduleName
        }
        "4" {
            $moduleName = Read-Host "Enter module name"
            Test-ModuleComponents -ModuleName $moduleName
        }
        "5" {
            $moduleName = Read-Host "Enter module name"
            Show-ModuleComponents -ModuleName $moduleName
        }
        "6" {
            Write-Output "Goodbye!" "Green"
            exit
        }
        default {
            Write-Output "Invalid option. Please try again." "Red"
        }
    }
}

# Main execution
if ($Help -or $Action -eq "help" -or $Action -eq "-h") {
    Show-Help
    exit 0
}

switch ($Action.ToLower()) {
    "list" {
        Show-ModuleList
    }
    "status" {
        Show-SystemStatus
    }
    "install" {
        Install-Module -ModuleName $Module
    }
    "test" {
        Test-ModuleComponents -ModuleName $Module
    }
    "components" {
        Show-ModuleComponents -ModuleName $Module
    }
    "menu" {
        Show-InteractiveMenu
    }
    default {
        Write-Output "Unknown command: $Action" "Red"
        Write-Output "Use 'setupx -h' to see available commands" "White"
    }
}
