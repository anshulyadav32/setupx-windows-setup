# Simple Component Testing Script
param(
    [string]$ComponentName = "chocolatey"
)

# Import SetupX modules
. "$PSScriptRoot\src\utils\logger.ps1"
. "$PSScriptRoot\src\utils\helpers.ps1"
. "$PSScriptRoot\src\core\engine.ps1"
. "$PSScriptRoot\src\core\json-loader.ps1"

Write-Host "Testing Component: $ComponentName" -ForegroundColor Cyan

# Get component
$component = Get-ComponentByName -ComponentName $ComponentName
if (-not $component) {
    Write-Host "Component '$ComponentName' not found" -ForegroundColor Red
    exit 1
}

Write-Host "Component found: $($component.displayName)" -ForegroundColor Green

# Test 1: Check initial status
Write-Host "`n1. Checking initial status..." -ForegroundColor Yellow
$initialCheck = Test-ComponentInstalled -Component $component
Write-Host "Initial status: $(if($initialCheck) {'Installed'} else {'Not Installed'})" -ForegroundColor Gray

# Test 2: Install
Write-Host "`n2. Installing component..." -ForegroundColor Yellow
try {
    $installResult = Invoke-ComponentCommand -Component $component -Action "install"
    if ($installResult) {
        Write-Host "✓ Install successful" -ForegroundColor Green
    } else {
        Write-Host "✗ Install failed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Install error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Check after install
Write-Host "`n3. Checking after install..." -ForegroundColor Yellow
$afterInstallCheck = Test-ComponentInstalled -Component $component
if ($afterInstallCheck) {
    Write-Host "✓ Component is installed" -ForegroundColor Green
} else {
    Write-Host "✗ Component not found after install" -ForegroundColor Red
}

# Test 4: Check paths
Write-Host "`n4. Checking paths..." -ForegroundColor Yellow
try {
    if ($component.commands.path) {
        Invoke-Expression $component.commands.path
        Write-Host "✓ Path check successful" -ForegroundColor Green
    } else {
        Write-Host "⚠ No path command defined" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Path check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Uninstall
Write-Host "`n5. Uninstalling component..." -ForegroundColor Yellow
try {
    $uninstallResult = Invoke-ComponentCommand -Component $component -Action "remove"
    if ($uninstallResult) {
        Write-Host "✓ Uninstall successful" -ForegroundColor Green
    } else {
        Write-Host "✗ Uninstall failed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Uninstall error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Check after uninstall
Write-Host "`n6. Checking after uninstall..." -ForegroundColor Yellow
$afterUninstallCheck = Test-ComponentInstalled -Component $component
if (-not $afterUninstallCheck) {
    Write-Host "✓ Component successfully uninstalled" -ForegroundColor Green
} else {
    Write-Host "⚠ Component still present after uninstall" -ForegroundColor Yellow
}

# Test 7: Reinstall
Write-Host "`n7. Reinstalling component..." -ForegroundColor Yellow
try {
    $reinstallResult = Invoke-ComponentCommand -Component $component -Action "install"
    if ($reinstallResult) {
        Write-Host "✓ Reinstall successful" -ForegroundColor Green
    } else {
        Write-Host "✗ Reinstall failed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Reinstall error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Update
Write-Host "`n8. Testing update..." -ForegroundColor Yellow
if ($component.commands.update) {
    try {
        $updateResult = Invoke-ComponentCommand -Component $component -Action "update"
        if ($updateResult) {
            Write-Host "✓ Update successful" -ForegroundColor Green
        } else {
            Write-Host "⚠ Update not available or failed" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠ Update error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ Update not supported for this component" -ForegroundColor Yellow
}

# Test 9: Final verification
Write-Host "`n9. Final verification..." -ForegroundColor Yellow
$finalCheck = Test-ComponentInstalled -Component $component
if ($finalCheck) {
    Write-Host "✓ Final verification passed" -ForegroundColor Green
} else {
    Write-Host "✗ Final verification failed" -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
