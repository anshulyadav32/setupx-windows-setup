# Comprehensive Component Testing Script
# Tests install, uninstall, reinstall, update, and path checking for all components

param(
    [string]$ComponentName = "",
    [switch]$SkipInstall = $false,
    [switch]$Verbose = $false
)

# Import SetupX modules
. "$PSScriptRoot\src\utils\logger.ps1"
. "$PSScriptRoot\src\utils\helpers.ps1"
. "$PSScriptRoot\src\core\engine.ps1"
. "$PSScriptRoot\src\core\json-loader.ps1"

function Test-Component {
    param(
        [string]$ComponentName,
        [switch]$Verbose
    )
    
    Write-Host "`n=== Testing Component: $ComponentName ===" -ForegroundColor Cyan
    
    $component = Get-ComponentByName -ComponentName $ComponentName
    if (-not $component) {
        Write-Host "Component '$ComponentName' not found" -ForegroundColor Red
        return $false
    }
    
    $results = @{
        Component = $ComponentName
        Install = $false
        Uninstall = $false
        Reinstall = $false
        Update = $false
        PathCheck = $false
        Errors = @()
    }
    
    try {
        # Step 1: Check initial status
        Write-Host "1. Checking initial status..." -ForegroundColor Yellow
        $initialCheck = Test-ComponentInstalled -Component $component
        Write-Host "   Initial status: $(if($initialCheck) {'Installed'} else {'Not Installed'})" -ForegroundColor Gray
        
        # Step 2: Install (if not skipping)
        if (-not $SkipInstall) {
            Write-Host "2. Installing component..." -ForegroundColor Yellow
            try {
                $installResult = Invoke-ComponentCommand -Component $component -Action "install"
                if ($installResult) {
                    $results.Install = $true
                    Write-Host "   ✓ Install successful" -ForegroundColor Green
                } else {
                    $results.Errors += "Install failed"
                    Write-Host "   ✗ Install failed" -ForegroundColor Red
                }
            } catch {
                $results.Errors += "Install error: $($_.Exception.Message)"
                Write-Host "   ✗ Install error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        # Step 3: Check after install
        Write-Host "3. Checking after install..." -ForegroundColor Yellow
        $afterInstallCheck = Test-ComponentInstalled -Component $component
        if ($afterInstallCheck) {
            Write-Host "   ✓ Component is installed" -ForegroundColor Green
        } else {
            Write-Host "   ✗ Component not found after install" -ForegroundColor Red
            $results.Errors += "Not found after install"
        }
        
        # Step 4: Check paths
        Write-Host "4. Checking paths..." -ForegroundColor Yellow
        try {
            if ($component.commands.path) {
                Invoke-Expression $component.commands.path
            }
            $results.PathCheck = $true
            Write-Host "   ✓ Path check successful" -ForegroundColor Green
        } catch {
            $results.Errors += "Path check error: $($_.Exception.Message)"
            Write-Host "   ✗ Path check failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Step 5: Uninstall
        Write-Host "5. Uninstalling component..." -ForegroundColor Yellow
        try {
            $uninstallResult = Invoke-ComponentCommand -Component $component -Action "remove"
            if ($uninstallResult) {
                $results.Uninstall = $true
                Write-Host "   ✓ Uninstall successful" -ForegroundColor Green
            } else {
                $results.Errors += "Uninstall failed"
                Write-Host "   ✗ Uninstall failed" -ForegroundColor Red
            }
        } catch {
            $results.Errors += "Uninstall error: $($_.Exception.Message)"
            Write-Host "   ✗ Uninstall error: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Step 6: Check after uninstall
        Write-Host "6. Checking after uninstall..." -ForegroundColor Yellow
        $afterUninstallCheck = Test-ComponentInstalled -Component $component
        if (-not $afterUninstallCheck) {
            Write-Host "   ✓ Component successfully uninstalled" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ Component still present after uninstall" -ForegroundColor Yellow
        }
        
        # Step 7: Reinstall
        Write-Host "7. Reinstalling component..." -ForegroundColor Yellow
        try {
            $reinstallResult = Invoke-ComponentCommand -Component $component -Action "install"
            if ($reinstallResult) {
                $results.Reinstall = $true
                Write-Host "   ✓ Reinstall successful" -ForegroundColor Green
            } else {
                $results.Errors += "Reinstall failed"
                Write-Host "   ✗ Reinstall failed" -ForegroundColor Red
            }
        } catch {
            $results.Errors += "Reinstall error: $($_.Exception.Message)"
            Write-Host "   ✗ Reinstall error: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Step 8: Update (if supported)
        Write-Host "8. Testing update..." -ForegroundColor Yellow
        if ($component.commands.update) {
            try {
                $updateResult = Invoke-ComponentCommand -Component $component -Action "update"
                if ($updateResult) {
                    $results.Update = $true
                    Write-Host "   ✓ Update successful" -ForegroundColor Green
                } else {
                    Write-Host "   ⚠ Update not available or failed" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "   ⚠ Update error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ⚠ Update not supported for this component" -ForegroundColor Yellow
        }
        
        # Step 9: Final verification
        Write-Host "9. Final verification..." -ForegroundColor Yellow
        $finalCheck = Test-ComponentInstalled -Component $component
        if ($finalCheck) {
            Write-Host "   ✓ Final verification passed" -ForegroundColor Green
        } else {
            Write-Host "   ✗ Final verification failed" -ForegroundColor Red
            $results.Errors += "Final verification failed"
        }
        
    } catch {
        $results.Errors += "General error: $($_.Exception.Message)"
        Write-Host "   ✗ General error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $results
}

function Show-TestSummary {
    param([array]$Results)
    
    Write-Host "`n=== TEST SUMMARY ===" -ForegroundColor Cyan
    
    $totalComponents = $Results.Count
    $successfulComponents = ($Results | Where-Object { $_.Errors.Count -eq 0 }).Count
    $failedComponents = $totalComponents - $successfulComponents
    
    Write-Host "Total Components Tested: $totalComponents" -ForegroundColor White
    Write-Host "Successful: $successfulComponents" -ForegroundColor Green
    Write-Host "Failed: $failedComponents" -ForegroundColor Red
    
    if ($failedComponents -gt 0) {
        Write-Host "`nFailed Components:" -ForegroundColor Red
        foreach ($result in $Results | Where-Object { $_.Errors.Count -gt 0 }) {
            Write-Host "  - $($result.Component): $($result.Errors -join ', ')" -ForegroundColor Red
        }
    }
    
    Write-Host "`nDetailed Results:" -ForegroundColor Yellow
    foreach ($result in $Results) {
        $status = if ($result.Errors.Count -eq 0) { "PASS" } else { "FAIL" }
        $color = if ($result.Errors.Count -eq 0) { "Green" } else { "Red" }
        Write-Host "  $status " -ForegroundColor $color -NoNewline
        Write-Host "$($result.Component)" -ForegroundColor White
    }
}

# Main execution
Write-Host "SetupX Component Testing Suite" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

if ($ComponentName) {
    # Test specific component
    $results = @(Test-Component -ComponentName $ComponentName -Verbose:$Verbose)
} else {
    # Test all components
    $allComponents = Get-AllComponents
    $results = @()
    
    Write-Host "Testing all $($allComponents.Count) components..." -ForegroundColor Yellow
    
    foreach ($component in $allComponents) {
        $result = Test-Component -ComponentName $component.name -Verbose:$Verbose
        $results += $result
        
        # Brief pause between components
        Start-Sleep -Seconds 2
    }
}

Show-TestSummary -Results $results

# Export results to file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$resultsFile = "test-results-$timestamp.json"
$results | ConvertTo-Json -Depth 3 | Out-File -FilePath $resultsFile -Encoding UTF8
Write-Host "`nResults exported to: $resultsFile" -ForegroundColor Cyan