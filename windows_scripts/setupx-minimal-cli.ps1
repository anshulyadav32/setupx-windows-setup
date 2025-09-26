param(
    [string]$Action = "menu",
    [string]$Module = "",
    [switch]$Help
)

function Write-Output {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Banner {
    Write-Output ""
    Write-Output "SETUPX CLI v2.0 - Modular Windows Development Setup" "Cyan"
    Write-Output ""
}

function Show-Help {
    Show-Banner
    Write-Output "USAGE:" "Magenta"
    Write-Output "  .\setupx-minimal-cli.ps1 [command]" "White"
    Write-Output ""
    Write-Output "COMMANDS:" "Magenta"
    Write-Output "  list                    List all available modules" "White"
    Write-Output "  status                  Show system status" "White"
    Write-Output "  components [module]      List module components" "White"
    Write-Output "  test [module]           Test module components" "White"
    Write-Output "  menu                    Show interactive menu (default)" "White"
    Write-Output ""
    Write-Output "EXAMPLES:" "Magenta"
    Write-Output "  .\setupx-minimal-cli.ps1 list" "White"
    Write-Output "  .\setupx-minimal-cli.ps1 components -Module web-development" "White"
    Write-Output "  .\setupx-minimal-cli.ps1 test -Module common-development" "White"
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
            }
        }
    }
    catch {
        $managers += @{
            Name = "WinGet"
            Available = $false
            Version = "Not installed"
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
            }
        }
    }
    catch {
        $managers += @{
            Name = "Chocolatey"
            Available = $false
            Version = "Not installed"
        }
    }
    
    return $managers
}

function Test-Component {
    param([string]$ComponentName, [string]$TestCommand)
    
    $result = @{
        Name = $ComponentName
        Installed = $false
        Version = "Unknown"
    }
    
    if ($TestCommand) {
        try {
            $output = Invoke-Expression $TestCommand 2>$null
            if ($LASTEXITCODE -eq 0 -or $output) {
                $result.Installed = $true
                $result.Version = $output
            }
        }
        catch {
            # Component not found
        }
    }
    
    return $result
}

function Show-ModuleList {
    Show-Banner
    Write-Output "Available Development Modules:" "Magenta"
    Write-Output ""
    
    $modules = Get-AvailableModules
    foreach ($module in $modules) {
        $status = if ($module.HasConfig) { "✅" } else { "⚠️" }
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
        $status = if ($manager.Available) { "✅" } else { "❌" }
        Write-Output "  $status $($manager.Name)" "White"
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
        Write-Output "❌ Module name required" "Red"
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-Output "❌ Module '$ModuleName' not found" "Red"
        return
    }
    
    Show-Banner
    Write-Output "Components in '$ModuleName' module:" "Magenta"
    Write-Output ""
    
    if ($module.Components) {
        foreach ($component in $module.Components) {
            Write-Output "  • $($component.name)" "White"
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
        Write-Output "❌ Module name required" "Red"
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-Output "❌ Module '$ModuleName' not found" "Red"
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
            
            $testResult = Test-Component -ComponentName $component.name -TestCommand $component.testCommand
            
            if ($testResult.Installed) {
                Write-Output " ✅ INSTALLED" "Green"
                $installedComponents++
            }
            else {
                Write-Output " ❌ NOT INSTALLED" "Red"
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

function Show-InteractiveMenu {
    Show-Banner
    Write-Output "Interactive Menu:" "Magenta"
    Write-Output ""
    Write-Output "1. List all modules" "White"
    Write-Output "2. Show system status" "White"
    Write-Output "3. Show module components" "White"
    Write-Output "4. Test module components" "White"
    Write-Output "5. Exit" "White"
    Write-Output ""
    
    $choice = Read-Host "Select option (1-5)"
    
    switch ($choice) {
        "1" { Show-ModuleList }
        "2" { Show-SystemStatus }
        "3" {
            $moduleName = Read-Host "Enter module name"
            Show-ModuleComponents -ModuleName $moduleName
        }
        "4" {
            $moduleName = Read-Host "Enter module name"
            Test-ModuleComponents -ModuleName $moduleName
        }
        "5" {
            Write-Output "Goodbye!" "Green"
            exit
        }
        default {
            Write-Output "❌ Invalid option. Please try again." "Red"
        }
    }
}

# Main execution
if ($Help) {
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
    "components" {
        Show-ModuleComponents -ModuleName $Module
    }
    "test" {
        Test-ModuleComponents -ModuleName $Module
    }
    "menu" {
        Show-InteractiveMenu
    }
    default {
        Write-Output "❌ Unknown command: $Action" "Red"
        Write-Output "Use -Help to see available commands" "White"
    }
}
