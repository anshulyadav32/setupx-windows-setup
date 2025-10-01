# SetupX Core Engine
# Executes commands from JSON configuration

function Invoke-ComponentCommand {
    <#
    .SYNOPSIS
    Executes a component command from JSON configuration
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Component,
        [Parameter(Mandatory=$true)]
        [ValidateSet("install", "remove", "update", "check", "verify", "test")]
        [string]$Action
    )
    
    if (-not $Component.commands.$Action) {
        Write-Host "Action '$Action' not available for $($Component.displayName)" -ForegroundColor Yellow
        return $false
    }
    
    $command = $Component.commands.$Action
    
    Write-Host "`nExecuting: $($Component.displayName) - $Action" -ForegroundColor Cyan
    Write-Host "Command: $command" -ForegroundColor DarkGray
    Write-Host ""
    
    try {
        # Execute the command
        $result = Invoke-Expression $command
        
        # Check if command was successful
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "$($Component.displayName) - $Action completed successfully" -ForegroundColor Green
            
            # Execute path refresh if specified
            if ($Component.commands.path) {
                try {
                    Invoke-Expression $Component.commands.path
                }
                catch {
                    Write-Host "Warning: Path refresh failed: $_" -ForegroundColor Yellow
                }
            }
            
            # Refresh environment variables using PowerShell-only methods
            try {
                # Refresh PATH from registry without external commands
                $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
                $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
                $env:PATH = $machinePath + ";" + $userPath
                
                # Refresh other common environment variables
                $env:PYTHONPATH = [System.Environment]::GetEnvironmentVariable("PYTHONPATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PYTHONPATH", "User")
            }
            catch {
                Write-Host "Warning: Could not refresh environment variables: $_" -ForegroundColor Yellow
            }
            
            return $true
        }
        else {
            Write-Host "$($Component.displayName) - $Action failed with exit code: $LASTEXITCODE" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error executing $Action for $($Component.displayName): $_" -ForegroundColor Red
        return $false
    }
}

function Get-AllComponents {
    <#
    .SYNOPSIS
    Gets all components from all module JSON files
    #>
    
    $allComponents = @()
    $modulesPath = Join-Path $PSScriptRoot "..\config\modules"
    
    if (Test-Path $modulesPath) {
        $jsonFiles = Get-ChildItem -Path $modulesPath -Filter "*.json"
        
        foreach ($file in $jsonFiles) {
            try {
                $moduleData = Get-Content $file.FullName -Raw | ConvertFrom-Json
                
                foreach ($componentName in $moduleData.components.PSObject.Properties.Name) {
                    $component = $moduleData.components.$componentName
                    $component | Add-Member -NotePropertyName "moduleName" -NotePropertyValue $moduleData.name -Force
                    $component | Add-Member -NotePropertyName "moduleFile" -NotePropertyValue $file.Name -Force
                    $allComponents += $component
                }
            }
            catch {
                Write-Host "Warning: Could not load $($file.Name): $_" -ForegroundColor Yellow
            }
        }
    }
    
    # Also check main config file
    $mainConfigPath = Join-Path $PSScriptRoot "..\config\setupx.json"
    if (Test-Path $mainConfigPath) {
        try {
            $mainConfig = Get-Content $mainConfigPath -Raw | ConvertFrom-Json
            
            if ($mainConfig.components) {
                foreach ($componentName in $mainConfig.components.PSObject.Properties.Name) {
                    $component = $mainConfig.components.$componentName
                    $component | Add-Member -NotePropertyName "moduleName" -NotePropertyValue "main" -Force
                    $component | Add-Member -NotePropertyName "moduleFile" -NotePropertyValue "setupx.json" -Force
                    $allComponents += $component
                }
            }
        }
        catch {
            Write-Host "Warning: Could not load main config: $_" -ForegroundColor Yellow
        }
    }
    
    return $allComponents
}

function Get-ComponentByName {
    <#
    .SYNOPSIS
    Gets a specific component by name
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComponentName
    )
    
    $allComponents = Get-AllComponents
    $component = $allComponents | Where-Object { $_.name -eq $ComponentName } | Select-Object -First 1
    
    if (-not $component) {
        # Try fuzzy match
        $component = $allComponents | Where-Object { 
            $_.name -like "*$ComponentName*" -or 
            $_.displayName -like "*$ComponentName*" 
        } | Select-Object -First 1
    }
    
    return $component
}

function Get-ComponentsByCategory {
    <#
    .SYNOPSIS
    Gets all components in a specific category
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Category
    )
    
    $allComponents = Get-AllComponents
    return $allComponents | Where-Object { $_.category -eq $Category }
}

function Get-ComponentsByModule {
    <#
    .SYNOPSIS
    Gets all components from a specific module file
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName
    )
    
    $allComponents = Get-AllComponents
    return $allComponents | Where-Object { $_.moduleName -eq $ModuleName }
}

function Get-ModuleConfig {
    <#
    .SYNOPSIS
    Gets module configuration from JSON file
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName
    )
    
    $modulePath = Join-Path $PSScriptRoot "..\config\modules\$ModuleName.json"
    
    if (Test-Path $modulePath) {
        try {
            $moduleData = Get-Content $modulePath -Raw | ConvertFrom-Json
            return $moduleData
        }
        catch {
            Write-Host "Warning: Could not load module $ModuleName`: $_" -ForegroundColor Yellow
            return $null
        }
    }
    
    return $null
}

function Get-AllModuleConfigs {
    <#
    .SYNOPSIS
    Gets all module configurations
    #>
    $allModules = @()
    $modulesPath = Join-Path $PSScriptRoot "..\config\modules"
    
    if (Test-Path $modulesPath) {
        $jsonFiles = Get-ChildItem -Path $modulesPath -Filter "*.json"
        
        foreach ($file in $jsonFiles) {
            try {
                $moduleData = Get-Content $file.FullName -Raw | ConvertFrom-Json
                $allModules += $moduleData
            }
            catch {
                Write-Host "Warning: Could not load $($file.Name): $_" -ForegroundColor Yellow
            }
        }
    }
    
    return $allModules
}

function Test-ComponentInstalled {
    <#
    .SYNOPSIS
    Tests if a component is installed
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Component
    )
    
    if ($Component.commands.check) {
        try {
            # Try the check command
            $result = Invoke-Expression $Component.commands.check 2>&1
            if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
                return $true
            }
        }
        catch {
            # If check command fails, try alternative detection methods
        }
    }
    
    # Alternative detection methods for common tools
    $componentName = $Component.name.ToLower()
    
    # Check for Python
    if ($componentName -eq "python") {
        try {
            $pythonPath = "C:\Python313\python.exe"
            if (Test-Path $pythonPath) {
                return $true
            }
        }
        catch { }
    }
    
    # Check for pip-based tools using PowerShell-only methods
    if ($componentName -in @("jupyter", "tensorflow", "pytorch", "pandas", "ansible")) {
        try {
            # Check Python site-packages directory for installed packages
            $pythonPaths = @(
                "C:\Python313\Lib\site-packages",
                "C:\Python312\Lib\site-packages", 
                "C:\Python311\Lib\site-packages",
                "$env:USERPROFILE\AppData\Local\Programs\Python\Python313\Lib\site-packages"
            )
            
            foreach ($pythonPath in $pythonPaths) {
                if (Test-Path $pythonPath) {
                    $packagePath = Join-Path $pythonPath $componentName
                    if (Test-Path $packagePath) {
                        return $true
                    }
                }
            }
        }
        catch { }
    }
    
    # Check for Chocolatey packages using PowerShell-only methods
    if ($componentName -in @("docker", "mongodb", "jenkins", "terraform", "aws-cli", "azure-cli")) {
        try {
            # Check Chocolatey lib directory for installed packages
            $chocoLibPath = "C:\ProgramData\chocolatey\lib"
            if (Test-Path $chocoLibPath) {
                $packagePath = Join-Path $chocoLibPath $componentName
                if (Test-Path $packagePath) {
                    return $true
                }
            }
        }
        catch { }
    }
    
    # Check for Node.js tools using PowerShell-only methods
    if ($componentName -in @("nodejs", "yarn", "react-tools", "vue-tools", "angular-tools", "vite")) {
        try {
            if ($componentName -eq "nodejs") {
                # Check for Node.js installation in common locations
                $nodePaths = @(
                    "C:\Program Files\nodejs\node.exe",
                    "C:\Program Files (x86)\nodejs\node.exe",
                    "$env:USERPROFILE\AppData\Local\Programs\nodejs\node.exe"
                )
                foreach ($nodePath in $nodePaths) {
                    if (Test-Path $nodePath) {
                        return $true
                    }
                }
            } elseif ($componentName -eq "yarn") {
                # Check for Yarn in npm global directory
                $yarnPaths = @(
                    "$env:USERPROFILE\AppData\Roaming\npm\yarn.cmd",
                    "$env:USERPROFILE\AppData\Local\Yarn\bin\yarn.cmd"
                )
                foreach ($yarnPath in $yarnPaths) {
                    if (Test-Path $yarnPath) {
                        return $true
                    }
                }
            } else {
                # Check npm global packages directory
                $npmGlobalPath = "$env:USERPROFILE\AppData\Roaming\npm\node_modules"
                if (Test-Path $npmGlobalPath) {
                    $packagePath = Join-Path $npmGlobalPath $componentName
                    if (Test-Path $packagePath) {
                        return $true
                    }
                }
            }
        }
        catch { }
    }
    
    return $false
}

# Functions are available when dot-sourced

