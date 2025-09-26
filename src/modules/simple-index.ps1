# Simple SetupX Modules Index
# Lists all modules and their components

Write-Host "SetupX Modules Index" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""

# Get the modules directory
$modulesDir = $PSScriptRoot
$moduleCount = 0
$componentCount = 0

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
            $moduleCount++
            $componentCount += $moduleConfig.components.Count
            
            Write-Host "📦 $($moduleConfig.displayName)" -ForegroundColor Yellow
            Write-Host "   Name: $moduleName" -ForegroundColor White
            Write-Host "   Description: $($moduleConfig.description)" -ForegroundColor Gray
            Write-Host "   Components: $($moduleConfig.components.Count)" -ForegroundColor Green
            Write-Host "   Admin Required: $($moduleConfig.requiresAdmin)" -ForegroundColor $(if ($moduleConfig.requiresAdmin) { "Red" } else { "Green" })
            Write-Host "   Install Time: $($moduleConfig.estimatedInstallTime)" -ForegroundColor Gray
            Write-Host ""
            
            if ($moduleConfig.components) {
                Write-Host "   Components:" -ForegroundColor Cyan
                foreach ($component in $moduleConfig.components) {
                    Write-Host "     • $($component.displayName)" -ForegroundColor White
                }
                Write-Host ""
            }
        } catch {
            Write-Warning "Failed to parse module.json for $moduleName"
        }
    }
}

Write-Host "Total Modules: $moduleCount" -ForegroundColor Green
Write-Host "Total Components: $componentCount" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  setupx list                    # List all modules" -ForegroundColor White
Write-Host "  setupx status                  # Show system status" -ForegroundColor White
Write-Host "  setupx install <module>        # Install specific module" -ForegroundColor White
Write-Host "  setupx components <module>     # Show module components" -ForegroundColor White
Write-Host "  setupx menu                    # Interactive menu" -ForegroundColor White