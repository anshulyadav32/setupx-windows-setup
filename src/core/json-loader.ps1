# SetupX JSON Loader
# Handles loading and parsing JSON configuration files

function Get-SetupxConfig {
    <#
    .SYNOPSIS
    Loads the main SetupX configuration
    #>
    
    $configPath = Join-Path $PSScriptRoot "..\config\setupx.json"
    
    if (Test-Path $configPath) {
        try {
            return Get-Content $configPath -Raw | ConvertFrom-Json
        }
        catch {
            Write-Host "Error loading main config: $_" -ForegroundColor Red
            return $null
        }
    }
    
    Write-Host "Main configuration file not found: $configPath" -ForegroundColor Red
    return $null
}

function Get-ModuleConfig {
    <#
    .SYNOPSIS
    Loads a specific module configuration
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName
    )
    
    $modulePath = Join-Path $PSScriptRoot "..\config\modules\$ModuleName.json"
    
    if (Test-Path $modulePath) {
        try {
            return Get-Content $modulePath -Raw | ConvertFrom-Json
        }
        catch {
            Write-Host "Error loading module config: $_" -ForegroundColor Red
            return $null
        }
    }
    
    Write-Host "Module configuration not found: $modulePath" -ForegroundColor Yellow
    return $null
}

function Get-AllModuleConfigs {
    <#
    .SYNOPSIS
    Loads all module configurations
    #>
    
    $modules = @()
    $modulesPath = Join-Path $PSScriptRoot "..\config\modules"
    
    if (Test-Path $modulesPath) {
        $jsonFiles = Get-ChildItem -Path $modulesPath -Filter "*.json"
        
        foreach ($file in $jsonFiles) {
            try {
                $moduleData = Get-Content $file.FullName -Raw | ConvertFrom-Json
                $modules += $moduleData
            }
            catch {
                Write-Host "Warning: Could not load $($file.Name): $_" -ForegroundColor Yellow
            }
        }
    }
    
    return $modules
}

function Save-SetupxConfig {
    <#
    .SYNOPSIS
    Saves the main SetupX configuration
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Config
    )
    
    $configPath = Join-Path $PSScriptRoot "..\config\setupx.json"
    
    try {
        $Config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Force
        Write-Host "Configuration saved successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error saving configuration: $_" -ForegroundColor Red
        return $false
    }
}

function New-ModuleConfig {
    <#
    .SYNOPSIS
    Creates a new module configuration file
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [Parameter(Mandatory=$true)]
        [string]$DisplayName,
        [Parameter(Mandatory=$true)]
        [string]$Description,
        [Parameter(Mandatory=$false)]
        [string]$Category = "development"
    )
    
    $modulePath = Join-Path $PSScriptRoot "..\config\modules\$ModuleName.json"
    
    $moduleTemplate = @{
        name = $ModuleName
        displayName = $DisplayName
        description = $Description
        category = $Category
        priority = 1
        status = "available"
        components = @{}
    }
    
    try {
        $moduleTemplate | ConvertTo-Json -Depth 10 | Set-Content $modulePath -Force
        Write-Host "Module configuration created: $modulePath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error creating module configuration: $_" -ForegroundColor Red
        return $false
    }
}

# Functions are available when dot-sourced

