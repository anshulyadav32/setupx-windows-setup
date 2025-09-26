param(
    [string]$Action = "menu",
    [string]$Module = "",
    [switch]$Help
)

# Colors
$Colors = @{
    Primary = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Secondary = "Magenta"
    Dim = "Gray"
}

function Write-Output {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Banner {
    Write-Output ""
    Write-Output "╔══════════════════════════════════════════════════════════════╗" $Colors.Primary
    Write-Output "║                    SETUPX CLI v2.0                          ║" $Colors.Primary
    Write-Output "║              Modular Windows Development Setup               ║" $Colors.Primary
    Write-Output "╚══════════════════════════════════════════════════════════════╝" $Colors.Primary
    Write-Output ""
}

function Show-Help {
    Show-Banner
    Write-Output "USAGE:" $Colors.Secondary
    Write-Output "  .\setupx-simple-cli.ps1 [command] [options]" $Colors.Info
    Write-Output ""
    Write-Output "COMMANDS:" $Colors.Secondary
    Write-Output "  list                    List all available modules" $Colors.Info
    Write-Output "  status                  Show system status" $Colors.Info
    Write-Output "  install <module>        Install a specific module" $Colors.Info
    Write-Output "  test <module>           Test module components" $Colors.Info
    Write-Output "  components <module>     List module components" $Colors.Info
    Write-Output "  menu                    Show interactive menu (default)" $Colors.Info
    Write-Output ""
    Write-Output "EXAMPLES:" $Colors.Secondary
    Write-Output "  .\setupx-simple-cli.ps1 list" $Colors.Info
    Write-Output "  .\setupx-simple-cli.ps1 install -Module web-development" $Colors.Info
    Write-Output "  .\setupx-simple-cli.ps1 test -Module common-development" $Colors.Info
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
    Write-Output "📦 Available Development Modules:" $Colors.Secondary
    Write-Output ""
    
    $modules = Get-AvailableModules
    foreach ($module in $modules) {
        $status = if ($module.HasConfig) { "✅" } else { "⚠️" }
        Write-Output "  $status $($module.Name)" $Colors.Info
        Write-Output "     Description: $($module.Description)" $Colors.Dim
        Write-Output "     Components: $($module.Components.Count)" $Colors.Dim
        Write-Output ""
    }
    
    Write-Output "Total modules: $($modules.Count)" $Colors.Secondary
}

function Show-SystemStatus {
    Show-Banner
    Write-Output "📊 System Status:" $Colors.Secondary
    Write-Output ""
    
    # Package managers
    Write-Output "🔧 Package Managers:" $Colors.Secondary
    $managers = Get-PackageManagers
    foreach ($manager in $managers) {
        $status = if ($manager.Available) { "✅" } else { "❌" }
        Write-Output "  $status $($manager.Name)" $Colors.Info
        Write-Output "     Version: $($manager.Version)" $Colors.Dim
    }
    
    # Modules
    Write-Output ""
    Write-Output "📦 Modules:" $Colors.Secondary
    $modules = Get-AvailableModules
    $configuredModules = ($modules | Where-Object { $_.HasConfig }).Count
    Write-Output "  Total modules: $($modules.Count)" $Colors.Info
    Write-Output "  Configured modules: $configuredModules" $Colors.Info
}

function Show-ModuleComponents {
    param([string]$ModuleName)
    
    if (!$ModuleName) {
        Write-Output "❌ Module name required" $Colors.Error
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-Output "❌ Module '$ModuleName' not found" $Colors.Error
        return
    }
    
    Show-Banner
    Write-Output "🔧 Components in '$ModuleName' module:" $Colors.Secondary
    Write-Output ""
    
    if ($module.Components) {
        foreach ($component in $module.Components) {
            Write-Output "  • $($component.name)" $Colors.Info
            Write-Output "    Description: $($component.description)" $Colors.Dim
            Write-Output "    Package: $($component.package)" $Colors.Dim
            Write-Output ""
        }
    }
    else {
        Write-Output "  No components configured" $Colors.Warning
    }
}

function Test-ModuleComponents {
    param([string]$ModuleName)
    
    if (!$ModuleName) {
        Write-Output "❌ Module name required" $Colors.Error
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-Output "❌ Module '$ModuleName' not found" $Colors.Error
        return
    }
    
    Show-Banner
    Write-Output "🧪 Testing components in '$ModuleName' module:" $Colors.Secondary
    Write-Output ""
    
    if ($module.Components) {
        $totalComponents = $module.Components.Count
        $installedComponents = 0
        
        foreach ($component in $module.Components) {
            Write-Output "Testing $($component.name)..." $Colors.Info -NoNewline
            
            $testResult = Test-Component -ComponentName $component.name -TestCommand $component.testCommand
            
            if ($testResult.Installed) {
                Write-Output " ✅ INSTALLED" $Colors.Success
                $installedComponents++
            }
            else {
                Write-Output " ❌ NOT INSTALLED" $Colors.Error
            }
        }
        
        Write-Output ""
        Write-Output "📊 Test Results:" $Colors.Secondary
        Write-Output "  Installed: $installedComponents/$totalComponents" $Colors.Info
        $percentage = [math]::Round(($installedComponents / $totalComponents) * 100, 1)
        Write-Output "  Completion: $percentage%" $Colors.Info
    }
    else {
        Write-Output "  No components to test" $Colors.Warning
    }
}

function Show-InteractiveMenu {
    Show-Banner
    Write-Output "🎯 Interactive Menu:" $Colors.Secondary
    Write-Output ""
    Write-Output "1. List all modules" $Colors.Info
    Write-Output "2. Show system status" $Colors.Info
    Write-Output "3. Show module components" $Colors.Info
    Write-Output "4. Test module components" $Colors.Info
    Write-Output "5. Exit" $Colors.Info
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
            Write-Output "👋 Goodbye!" $Colors.Success
            exit
        }
        default {
            Write-Output "❌ Invalid option. Please try again." $Colors.Error
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
        Write-Output "❌ Unknown command: $Action" $Colors.Error
        Write-Output "Use -Help to see available commands" $Colors.Info
    }
}