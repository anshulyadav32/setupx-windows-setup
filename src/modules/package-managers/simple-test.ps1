# Simple Package Managers Module Test
# Basic test to verify all components are present and loadable

param([switch]$Verbose)

$ModulePath = $PSScriptRoot
$SharedPath = Split-Path (Split-Path $ModulePath) -Name | Join-Path (Split-Path (Split-Path $ModulePath)) "shared"

# Import shared functions
. "$SharedPath\component-manager.ps1"

# Load module configuration
$moduleConfig = Get-Content "$ModulePath\module.json" | ConvertFrom-Json

Write-Host "`nPackage Managers Module Test" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Gray

Write-Host "`nModule: $($moduleConfig.displayName)" -ForegroundColor White
Write-Host "Components: $($moduleConfig.components.Count)" -ForegroundColor Gray

$results = @()

foreach ($component in $moduleConfig.components) {
    Write-Host "`nTesting $($component.displayName)..." -ForegroundColor Yellow

    $componentScript = Join-Path $ModulePath "components\$($component.scriptName)"
    $componentResult = @{
        Name = $component.displayName
        ScriptExists = $false
        LoadsCorrectly = $false
        HasTestFunction = $false
        HasInstallFunction = $false
    }

    # Test 1: Script exists
    if (Test-Path $componentScript) {
        Write-Host "  [+] Script file exists" -ForegroundColor Green
        $componentResult.ScriptExists = $true

        try {
            # Test 2: Script can be loaded
            . $componentScript
            Write-Host "  [+] Script loads without errors" -ForegroundColor Green
            $componentResult.LoadsCorrectly = $true

            # Test 3: Has test function
            $testFunc = "Test-$($component.name)"
            if (Get-Command $testFunc -ErrorAction SilentlyContinue) {
                Write-Host "  [+] Test function ($testFunc) exists" -ForegroundColor Green
                $componentResult.HasTestFunction = $true
            } else {
                Write-Host "  [X] Test function missing" -ForegroundColor Red
            }

            # Test 4: Has install function
            $installFunc = "Install-$($component.name)"
            if (Get-Command $installFunc -ErrorAction SilentlyContinue) {
                Write-Host "  [+] Install function ($installFunc) exists" -ForegroundColor Green
                $componentResult.HasInstallFunction = $true
            } else {
                Write-Host "  [X] Install function missing" -ForegroundColor Red
            }

        }
        catch {
            Write-Host "  [X] Script loading failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  [X] Script file not found" -ForegroundColor Red
    }

    $results += $componentResult
}

# Test module installer
Write-Host "`nTesting Module Installer..." -ForegroundColor Yellow
$installScript = Join-Path $ModulePath "install-module.ps1"
if (Test-Path $installScript) {
    Write-Host "  [+] install-module.ps1 exists" -ForegroundColor Green
} else {
    Write-Host "  [X] install-module.ps1 missing" -ForegroundColor Red
}

# Summary
Write-Host "`nSUMMARY" -ForegroundColor Cyan
Write-Host "=======" -ForegroundColor Gray

$totalComponents = $results.Count
$scriptsExist = ($results | Where-Object { $_.ScriptExists }).Count
$scriptsLoad = ($results | Where-Object { $_.LoadsCorrectly }).Count
$hasTests = ($results | Where-Object { $_.HasTestFunction }).Count
$hasInstall = ($results | Where-Object { $_.HasInstallFunction }).Count

Write-Host "Scripts exist: $scriptsExist/$totalComponents" -ForegroundColor $(if ($scriptsExist -eq $totalComponents) { "Green" } else { "Red" })
Write-Host "Scripts load: $scriptsLoad/$totalComponents" -ForegroundColor $(if ($scriptsLoad -eq $totalComponents) { "Green" } else { "Red" })
Write-Host "Test functions: $hasTests/$totalComponents" -ForegroundColor $(if ($hasTests -eq $totalComponents) { "Green" } else { "Red" })
Write-Host "Install functions: $hasInstall/$totalComponents" -ForegroundColor $(if ($hasInstall -eq $totalComponents) { "Green" } else { "Red" })

if ($scriptsExist -eq $totalComponents -and $scriptsLoad -eq $totalComponents -and $hasTests -eq $totalComponents -and $hasInstall -eq $totalComponents) {
    Write-Host "`n[SUCCESS] Package Managers module is complete and ready!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n[INCOMPLETE] Some components need attention." -ForegroundColor Yellow
    exit 1
}
