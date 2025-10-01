# Run All Component Tests
# Comprehensive testing of all modules and components

Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║         SetupX - Comprehensive Component Testing          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

. "$PSScriptRoot\..\src\core\json-loader.ps1"

# Get all modules
$modules = Get-AllModuleConfigs

Write-Host "Found $($modules.Count) modules to test`n" -ForegroundColor Yellow

$totalComponents = 0
$totalInstalled = 0
$totalNotInstalled = 0

# Test each module
foreach ($module in $modules | Sort-Object priority) {
    Write-Host "`n" -NoNewline
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host "Testing Module: $($module.displayName)" -ForegroundColor Yellow
    Write-Host ("=" * 70) -ForegroundColor Cyan
    
    # Run module test
    $result = & "$PSScriptRoot\test-module.ps1" -ModuleName $module.name 2>$null
    
    # Count components
    $componentCount = $module.components.PSObject.Properties.Count
    $totalComponents += $componentCount
    
    Start-Sleep -Milliseconds 500
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 70) -ForegroundColor Green
Write-Host "ALL TESTS COMPLETED" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Green

# Run quick summary
Write-Host "`nGenerating final summary..." -ForegroundColor Cyan
& "$PSScriptRoot\test-all-quick.ps1" 2>$null

Write-Host "`n[SUCCESS] Testing complete! Check test results above." -ForegroundColor Green

