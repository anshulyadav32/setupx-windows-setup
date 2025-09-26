# SetupX Modules Index Generator
# Generates a comprehensive index of all modules and components

param(
    [switch]$Json,
    [switch]$Markdown,
    [switch]$Console
)

# Set default output to console if no format specified
if (-not $Json -and -not $Markdown -and -not $Console) {
    $Console = $true
}

# Get the modules directory
$modulesDir = $PSScriptRoot
$modules = @()

# Scan for modules
Get-ChildItem -Path $modulesDir -Directory | ForEach-Object {
    $moduleDir = $_.FullName
    $moduleName = $_.Name
    
    # Skip if it's not a module directory
    if ($moduleName -in @("components", "shared")) {
        return
    }
    
    $moduleJsonPath = Join-Path $moduleDir "module.json"
    
    if (Test-Path $moduleJsonPath) {
        try {
            $moduleConfig = Get-Content $moduleJsonPath | ConvertFrom-Json
            $module = @{
                Name = $moduleName
                DisplayName = $moduleConfig.displayName
                Description = $moduleConfig.description
                Version = $moduleConfig.version
                Category = $moduleConfig.category
                SupportsAutoInstall = $moduleConfig.supportsAutoInstall
                RequiresAdmin = $moduleConfig.requiresAdmin
                EstimatedInstallTime = $moduleConfig.estimatedInstallTime
                Components = $moduleConfig.components
                ComponentCount = $moduleConfig.components.Count
            }
            $modules += $module
        } catch {
            Write-Warning "Failed to parse module.json for $moduleName"
        }
    }
}

# Sort modules by priority
$modules = $modules | Sort-Object Name

if ($Console) {
    Write-Host "SetupX Modules Index" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($module in $modules) {
        Write-Host "📦 $($module.DisplayName)" -ForegroundColor Yellow
        Write-Host "   Name: $($module.Name)" -ForegroundColor White
        Write-Host "   Description: $($module.Description)" -ForegroundColor Gray
        Write-Host "   Category: $($module.Category)" -ForegroundColor Gray
        Write-Host "   Components: $($module.ComponentCount)" -ForegroundColor Green
        Write-Host "   Admin Required: $($module.RequiresAdmin)" -ForegroundColor $(if ($module.RequiresAdmin) { "Red" } else { "Green" })
        Write-Host "   Install Time: $($module.EstimatedInstallTime)" -ForegroundColor Gray
        Write-Host ""
        
        if ($module.Components) {
            Write-Host "   Components:" -ForegroundColor Cyan
            foreach ($component in $module.Components) {
                Write-Host "     • $($component.displayName)" -ForegroundColor White
            }
            Write-Host ""
        }
    }
    
    Write-Host "Total Modules: $($modules.Count)" -ForegroundColor Green
    Write-Host "Total Components: $(($modules | ForEach-Object { $_.ComponentCount } | Measure-Object -Sum).Sum)" -ForegroundColor Green
}

if ($Json) {
    $modules | ConvertTo-Json -Depth 3 | Write-Output
}

if ($Markdown) {
    Write-Output "# SetupX Modules Index"
    Write-Output ""
    Write-Output "Generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Output ""
    Write-Output "## Module Summary"
    Write-Output ""
    Write-Output "| Module | Display Name | Components | Admin Required | Install Time |"
    Write-Output "|--------|-------------|------------|----------------|--------------|"
    
    foreach ($module in $modules) {
        $adminStatus = if ($module.RequiresAdmin) { "Yes" } else { "No" }
        Write-Output "| $($module.Name) | $($module.DisplayName) | $($module.ComponentCount) | $adminStatus | $($module.EstimatedInstallTime) |"
    }
    
    Write-Output ""
    Write-Output "## Module Details"
    Write-Output ""
    
    foreach ($module in $modules) {
        Write-Output "### $($module.DisplayName) ($($module.Name))"
        Write-Output ""
        Write-Output "**Description:** $($module.Description)"
        Write-Output ""
        Write-Output "**Configuration:**"
        Write-Output "- Category: $($module.Category)"
        Write-Output "- Components: $($module.ComponentCount)"
        Write-Output "- Admin Required: $($module.RequiresAdmin)"
        Write-Output "- Install Time: $($module.EstimatedInstallTime)"
        Write-Output ""
        
        if ($module.Components) {
            Write-Output "**Components:**"
            foreach ($component in $module.Components) {
                Write-Output "- $($component.displayName) - $($component.description)"
            }
            Write-Output ""
        }
        
        Write-Output "**Usage:**"
        Write-Output "```bash"
        Write-Output "setupx install $($module.Name)"
        Write-Output "setupx components $($module.Name)"
        Write-Output "setupx test $($module.Name)"
        Write-Output "````"
        Write-Output ""
    }
}
