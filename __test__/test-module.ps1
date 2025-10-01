# Test Specific Module
# Tests all components in a specific module

param(
    [Parameter(Mandatory=$true)]
    [string]$ModuleName
)

. "$PSScriptRoot\..\src\core\json-loader.ps1"
. "$PSScriptRoot\..\src\core\engine.ps1"

Write-Host "`n=== Testing Module: $ModuleName ===" -ForegroundColor Cyan

$module = Get-ModuleConfig -ModuleName $ModuleName

if (-not $module) {
    Write-Host "Module '$ModuleName' not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`nModule: $($module.displayName)" -ForegroundColor Yellow
Write-Host "Description: $($module.description)" -ForegroundColor Gray
Write-Host "Components: $($module.components.PSObject.Properties.Count)" -ForegroundColor Gray
Write-Host ""

$passed = 0
$failed = 0

foreach ($componentName in $module.components.PSObject.Properties.Name) {
    $component = $module.components.$componentName
    
    Write-Host "Testing: $($component.displayName)" -ForegroundColor Cyan
    
    # Test if installed
    $isInstalled = Test-ComponentInstalled -Component $component
    
    if ($isInstalled) {
        Write-Host "  [+] Installed" -ForegroundColor Green
        $passed++
        
        # Try to get version
        if ($component.commands.check) {
            try {
                $version = Invoke-Expression $component.commands.check 2>&1 | Select-Object -First 1
                Write-Host "  Version: $version" -ForegroundColor Gray
            }
            catch {
                Write-Host "  Version: Could not retrieve" -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "  [-] Not installed" -ForegroundColor Red
        $failed++
    }
    
    Write-Host ""
}

Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Installed: $passed" -ForegroundColor Green
Write-Host "  Not Installed: $failed" -ForegroundColor Red

