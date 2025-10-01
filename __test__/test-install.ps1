# Test Installation of Components
# WARNING: This will actually install components!

param(
    [Parameter(Mandatory=$true)]
    [string]$ComponentName,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

. "$PSScriptRoot\..\src\core\engine.ps1"
. "$PSScriptRoot\..\src\core\json-loader.ps1"

Write-Host "`n=== Installation Test ===" -ForegroundColor Cyan

$component = Get-ComponentByName -ComponentName $ComponentName

if (-not $component) {
    Write-Host "Component '$ComponentName' not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`nComponent: $($component.displayName)" -ForegroundColor Yellow
Write-Host "Description: $($component.description)" -ForegroundColor Gray

# Check current status
Write-Host "`n[1/4] Checking current installation status..." -ForegroundColor Cyan
$wasInstalled = Test-ComponentInstalled -Component $component

if ($wasInstalled) {
    Write-Host "  Already installed" -ForegroundColor Yellow
}
else {
    Write-Host "  Not installed" -ForegroundColor Gray
}

if ($DryRun) {
    Write-Host "`n[DRY RUN MODE - No actual installation]" -ForegroundColor Yellow
    Write-Host "`nWould execute:" -ForegroundColor Cyan
    Write-Host "  $($component.commands.install)" -ForegroundColor White
    exit 0
}

# Confirm installation
if (-not $wasInstalled) {
    Write-Host "`n[2/4] Ready to install" -ForegroundColor Cyan
    $confirm = Read-Host "Proceed with installation? (y/N)"
    
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Installation cancelled" -ForegroundColor Yellow
        exit 0
    }
    
    # Install
    Write-Host "`n[3/4] Installing $($component.displayName)..." -ForegroundColor Cyan
    $result = Invoke-ComponentCommand -Component $component -Action "install"
    
    if ($result) {
        Write-Host "  Installation command completed" -ForegroundColor Green
    }
    else {
        Write-Host "  Installation failed!" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "`n[2/4] Skipping installation (already installed)" -ForegroundColor Yellow
    Write-Host "[3/4] Skipped" -ForegroundColor Yellow
}

# Verify
Write-Host "`n[4/4] Verifying installation..." -ForegroundColor Cyan
Start-Sleep -Seconds 2

$isNowInstalled = Test-ComponentInstalled -Component $component

if ($isNowInstalled) {
    Write-Host "  [+] Verification PASSED" -ForegroundColor Green
    
    if ($component.commands.check) {
        Write-Host "`nVersion:" -ForegroundColor Cyan
        try {
            $version = Invoke-Expression $component.commands.check 2>&1
            Write-Host "  $version" -ForegroundColor White
        }
        catch {
            Write-Host "  Could not retrieve version" -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "  [-] Verification FAILED" -ForegroundColor Red
}

Write-Host "`nTest completed!" -ForegroundColor Green

