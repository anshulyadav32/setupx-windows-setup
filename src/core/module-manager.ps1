# SetupX Module Manager
# Handles module discovery, loading, and management

# Import dependencies
. "$PSScriptRoot\..\utils\logger.ps1"
. "$PSScriptRoot\..\utils\helpers.ps1"

function Get-AvailableModules {
    <#
    .SYNOPSIS
    Discovers and returns all available SetupX modules
    #>
    $modules = @()
    $modulesDir = Join-Path $PSScriptRoot "..\modules"
    
    if (-not (Test-Path $modulesDir)) {
        Write-SetupxWarning "Modules directory not found: $modulesDir"
        return $modules
    }
    
    $moduleDirs = Get-ChildItem -Path $modulesDir -Directory
    foreach ($moduleDir in $moduleDirs) {
        $moduleJsonPath = Join-Path $moduleDir.FullName "module.json"
        if (Test-Path $moduleJsonPath) {
            try {
                $moduleConfig = Get-Content $moduleJsonPath | ConvertFrom-Json
                $modules += [PSCustomObject]@{
                    Name = $moduleDir.Name
                    DisplayName = $moduleConfig.displayName
                    Description = $moduleConfig.description
                    Components = $moduleConfig.components
                    Path = $moduleDir.FullName
                }
                Write-SetupxInfo "Loaded module: $($moduleDir.Name)"
            } catch {
                Write-SetupxError "Failed to load module $($moduleDir.Name): $($_.Exception.Message)"
            }
        }
    }
    
    return $modules
}

function Get-ModuleComponents {
    param([string]$ModuleName)
    <#
    .SYNOPSIS
    Gets all components for a specific module
    #>
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if ($module) {
        return $module.Components
    } else {
        Write-SetupxError "Module '$ModuleName' not found"
        return @()
    }
}

function Test-ModuleExists {
    param([string]$ModuleName)
    <#
    .SYNOPSIS
    Tests if a module exists
    #>
    $modules = Get-AvailableModules
    return ($modules | Where-Object { $_.Name -eq $ModuleName }) -ne $null
}

function Install-Module {
    param([string]$ModuleName)
    <#
    .SYNOPSIS
    Installs a specific module and its components
    #>
    if (-not $ModuleName) {
        Write-SetupxError "Module name required. Use: setupx install <module>"
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (-not $module) {
        Write-SetupxError "Module '$ModuleName' not found"
        return
    }
    
    Write-SetupxInfo "Installing module: $($module.DisplayName)"
    
    if ($module.Components) {
        $totalComponents = $module.Components.Count
        $installedComponents = 0
        
        foreach ($component in $module.Components) {
            Write-SetupxInfo "Installing component: $($component.displayName)"
            
            # Get the component script path
            $componentScript = Join-Path $module.Path "components\$($component.scriptName)"
            
            if (Test-Path $componentScript) {
                try {
                    Write-SetupxInfo "Running installation script: $($component.scriptName)"
                    & $componentScript
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-SetupxSuccess "Component installed: $($component.displayName)"
                        $installedComponents++
                    } else {
                        Write-SetupxError "Component installation failed: $($component.displayName)"
                    }
                } catch {
                    Write-SetupxError "Component installation error: $($_.Exception.Message)"
                }
            } else {
                Write-SetupxWarning "Installation script not found: $($component.scriptName)"
            }
        }
        
        Write-SetupxInfo "Installation Results: $installedComponents/$totalComponents components installed"
    } else {
        Write-SetupxWarning "No components to install for module: $ModuleName"
    }
}

function Install-ModuleComponent {
    param([string]$ModuleName, [string]$ComponentName)
    <#
    .SYNOPSIS
    Installs a specific component from a module
    #>
    if (-not $ModuleName -or -not $ComponentName) {
        Write-SetupxError "Module name and component name required. Use: setupx install-component <module> <component>"
        return $false
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (-not $module) {
        Write-SetupxError "Module '$ModuleName' not found"
        return $false
    }
    
    if (-not $module.Components) {
        Write-SetupxError "No components found for module: $ModuleName"
        return $false
    }
    
    $component = $module.Components | Where-Object { $_.scriptName -like "*$ComponentName*" -or $_.displayName -like "*$ComponentName*" }
    
    if (-not $component) {
        Write-SetupxError "Component '$ComponentName' not found in module '$ModuleName'"
        Write-SetupxInfo "Available components:"
        foreach ($comp in $module.Components) {
            Write-SetupxInfo "  - $($comp.displayName) ($($comp.scriptName))"
        }
        return $false
    }
    
    Write-SetupxInfo "Installing component: $($component.displayName)"
    
    # Get the component script path
    $componentScript = Join-Path $module.Path "components\$($component.scriptName)"
    
    if (Test-Path $componentScript) {
        try {
            Write-SetupxInfo "Running installation script: $($component.scriptName)"
            & $componentScript
            
            if ($LASTEXITCODE -eq 0) {
                Write-SetupxSuccess "Component installed: $($component.displayName)"
                return $true
            } else {
                Write-SetupxError "Component installation failed: $($component.displayName)"
                return $false
            }
        } catch {
            Write-SetupxError "Component installation error: $($_.Exception.Message)"
            return $false
        }
    } else {
        Write-SetupxWarning "Installation script not found: $($component.scriptName)"
        return $false
    }
}

# Functions are available for use in other modules
