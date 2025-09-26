# SETUPX Module and Component Index
param(
    [string]$Module = "",
    [switch]$Detailed,
    [switch]$Json
)

function Write-Output {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Banner {
    Write-Output ""
    Write-Output "SETUPX MODULE AND COMPONENT INDEX" "Cyan"
    Write-Output "Complete Development Environment Catalog" "Cyan"
    Write-Output ""
}

function Get-AllModules {
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
                Components = @()
            }
            
            if ($moduleInfo.HasConfig) {
                try {
                    $config = Get-Content $configPath -Raw | ConvertFrom-Json
                    $moduleInfo.Description = $config.description
                    $moduleInfo.Version = $config.version
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

function Show-ModuleIndex {
    Show-Banner
    Write-Output "MODULE INDEX - All Available Development Modules" "Magenta"
    Write-Output ""
    
    $modules = Get-AllModules
    $totalComponents = 0
    
    foreach ($module in $modules) {
        $status = if ($module.HasConfig) { "OK" } else { "WARN" }
        Write-Output "  $status $($module.Name)" "White"
        Write-Output "     Description: $($module.Description)" "Gray"
        Write-Output "     Components: $($module.Components.Count)" "Gray"
        Write-Output "     Path: $($module.Path)" "Gray"
        Write-Output ""
        
        $totalComponents += $module.Components.Count
    }
    
    Write-Output "SUMMARY:" "Yellow"
    Write-Output "  Total Modules: $($modules.Count)" "White"
    Write-Output "  Total Components: $totalComponents" "White"
    Write-Output "  Configured Modules: $(($modules | Where-Object { $_.HasConfig }).Count)" "White"
}

function Show-ComponentIndex {
    param([string]$ModuleName = "")
    
    Show-Banner
    Write-Output "COMPONENT INDEX - All Development Components" "Magenta"
    Write-Output ""
    
    $modules = Get-AllModules
    $allComponents = @()
    
    foreach ($module in $modules) {
        if ($ModuleName -and $module.Name -ne $ModuleName) {
            continue
        }
        
        if ($module.Components) {
            Write-Output "Module: $($module.Name)" "Cyan"
            Write-Output "   Description: $($module.Description)" "Gray"
            Write-Output ""
            
            foreach ($component in $module.Components) {
                $allComponents += @{
                    Module = $module.Name
                    Name = $component.name
                    Description = $component.description
                    Package = $component.package
                    Manager = $component.manager
                    TestCommand = $component.testCommand
                }
                
                Write-Output "  - $($component.name)" "White"
                Write-Output "    Description: $($component.description)" "Gray"
                Write-Output "    Package: $($component.package)" "Gray"
                Write-Output "    Manager: $($component.manager)" "Gray"
                Write-Output "    Test: $($component.testCommand)" "Gray"
                Write-Output ""
            }
        }
    }
    
    Write-Output "COMPONENT SUMMARY:" "Yellow"
    Write-Output "  Total Components: $($allComponents.Count)" "White"
    
    if ($ModuleName) {
        $moduleComponents = $allComponents | Where-Object { $_.Module -eq $ModuleName }
        Write-Output "  Components in '$ModuleName': $($moduleComponents.Count)" "White"
    }
}

function Show-DetailedIndex {
    Show-Banner
    Write-Output "DETAILED MODULE AND COMPONENT INDEX" "Magenta"
    Write-Output ""
    
    $modules = Get-AllModules
    $totalComponents = 0
    $componentsByManager = @{}
    
    foreach ($module in $modules) {
        Write-Output "MODULE: $($module.Name)" "Cyan"
        Write-Output "   Description: $($module.Description)" "Gray"
        Write-Output "   Path: $($module.Path)" "Gray"
        Write-Output "   Configuration: $(if ($module.HasConfig) { 'Valid' } else { 'Missing' })" "Gray"
        Write-Output ""
        
        if ($module.Components) {
            $componentCount = $module.Components.Count
            Write-Output "   COMPONENTS ($componentCount total):" "Yellow"
            foreach ($component in $module.Components) {
                Write-Output "     - $($component.name)" "White"
                Write-Output "       Description: $($component.description)" "Gray"
                Write-Output "       Package: $($component.package)" "Gray"
                Write-Output "       Manager: $($component.manager)" "Gray"
                Write-Output "       Test Command: $($component.testCommand)" "Gray"
                Write-Output ""
                
                $totalComponents++
                
                if ($component.manager) {
                    if (!$componentsByManager.ContainsKey($component.manager)) {
                        $componentsByManager[$component.manager] = 0
                    }
                    $componentsByManager[$component.manager]++
                }
            }
        }
        else {
            Write-Output "   No components configured" "Yellow"
        }
        
        Write-Output "   " + ("-" * 60) "Gray"
        Write-Output ""
    }
    
    Write-Output "COMPREHENSIVE SUMMARY:" "Yellow"
    Write-Output "  Total Modules: $($modules.Count)" "White"
    Write-Output "  Total Components: $totalComponents" "White"
    Write-Output "  Configured Modules: $(($modules | Where-Object { $_.HasConfig }).Count)" "White"
    Write-Output ""
    
    Write-Output "Components by Package Manager:" "Yellow"
    foreach ($manager in $componentsByManager.Keys) {
        Write-Output "  $manager: $($componentsByManager[$manager]) components" "White"
    }
}

function Show-JsonIndex {
    $modules = Get-AllModules
    $index = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        total_modules = $modules.Count
        total_components = ($modules | ForEach-Object { $_.Components.Count } | Measure-Object -Sum).Sum
        modules = @()
    }
    
    foreach ($module in $modules) {
        $moduleData = @{
            name = $module.Name
            description = $module.Description
            path = $module.Path
            has_config = $module.HasConfig
            component_count = $module.Components.Count
            components = $module.Components
        }
        $index.modules += $moduleData
    }
    
    return $index | ConvertTo-Json -Depth 10
}

# Main execution
if ($Json) {
    Show-JsonIndex
    exit 0
}

if ($Module) {
    Show-ComponentIndex -ModuleName $Module
}
elseif ($Detailed) {
    Show-DetailedIndex
}
else {
    Show-ModuleIndex
}

Write-Output ""
Write-Output "USAGE EXAMPLES:" "Cyan"
Write-Output "  .\index-simple.ps1                    # Module index" "White"
Write-Output "  .\index-simple.ps1 -Detailed          # Detailed index" "White"
Write-Output "  .\index-simple.ps1 -Module web-dev   # Component index" "White"
Write-Output "  .\index-simple.ps1 -Json             # JSON output" "White"
