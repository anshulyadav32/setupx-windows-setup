# Test All Components - Install, Check, Status
# Comprehensive testing for every component

. "$PSScriptRoot\..\src\core\engine.ps1"
. "$PSScriptRoot\..\src\core\json-loader.ps1"

Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           Test All Components - Full Suite                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

$allComponents = Get-AllComponents
$results = @{
    TotalComponents = $allComponents.Count
    TestedComponents = 0
    InstalledComponents = 0
    NotInstalledComponents = 0
    PassedTests = 0
    FailedTests = 0
    ComponentResults = @()
}

Write-Host "`nTesting $($allComponents.Count) components...`n" -ForegroundColor Yellow

foreach ($component in $allComponents | Sort-Object moduleName, name) {
    Write-Host "Testing: $($component.displayName)" -ForegroundColor Cyan -NoNewline
    Write-Host " [$($component.moduleName)]" -ForegroundColor DarkGray
    
    $componentResult = @{
        Name = $component.name
        DisplayName = $component.displayName
        Module = $component.moduleName
        Tests = @{}
    }
    
    # Test 1: Check if installed
    $isInstalled = Test-ComponentInstalled -Component $component
    $componentResult.Tests.IsInstalled = $isInstalled
    
    if ($isInstalled) {
        Write-Host "  [+] Installed" -ForegroundColor Green
        $results.InstalledComponents++
        
        # Test 2: Check command
        if ($component.commands.check) {
            try {
                $version = Invoke-Expression $component.commands.check 2>&1 | Select-Object -First 1
                Write-Host "      Version: $version" -ForegroundColor Gray
                $componentResult.Tests.CheckCommand = "PASS"
                $componentResult.Version = $version
                $results.PassedTests++
            }
            catch {
                Write-Host "      Version check failed" -ForegroundColor Yellow
                $componentResult.Tests.CheckCommand = "FAIL"
                $results.FailedTests++
            }
        }
    }
    else {
        Write-Host "  [-] Not installed" -ForegroundColor Gray
        $results.NotInstalledComponents++
        $componentResult.Tests.CheckCommand = "SKIP"
    }
    
    $results.ComponentResults += $componentResult
    $results.TestedComponents++
}

# Show final status
Write-Host "`n" -NoNewline
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "Final Status Summary" -ForegroundColor Yellow
Write-Host ("=" * 70) -ForegroundColor Cyan

Write-Host "`nTotal Components: $($results.TotalComponents)" -ForegroundColor White
Write-Host "Installed: $($results.InstalledComponents)" -ForegroundColor Green
Write-Host "Not Installed: $($results.NotInstalledComponents)" -ForegroundColor Gray
Write-Host "Coverage: $([math]::Round(($results.InstalledComponents / $results.TotalComponents) * 100, 1))%" -ForegroundColor Cyan

Write-Host "`nTest Results:" -ForegroundColor White
Write-Host "Passed: $($results.PassedTests)" -ForegroundColor Green
Write-Host "Failed: $($results.FailedTests)" -ForegroundColor Red

# Export results
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = Join-Path $PSScriptRoot "all-components-test-$timestamp.json"
$results | ConvertTo-Json -Depth 10 | Set-Content $reportPath

Write-Host "`nDetailed results: $reportPath" -ForegroundColor Gray
Write-Host "`nAll components tested!" -ForegroundColor Green

