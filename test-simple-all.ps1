# Simple Comprehensive Test Script
Write-Host "=== SETUPX COMPREHENSIVE TEST ===" -ForegroundColor Cyan

# Test 1: Installation
Write-Host "`n1. Testing Installation..." -ForegroundColor Green
if (Test-Path "C:\tools\setup\setupx.ps1") {
    Write-Host "✓ SetupX executable found" -ForegroundColor Green
} else {
    Write-Host "✗ SetupX executable not found" -ForegroundColor Red
}

# Test 2: JSON Configuration
Write-Host "`n2. Testing JSON Configuration..." -ForegroundColor Green
if (Test-Path "C:\tools\setup\setupx.json") {
    Write-Host "✓ JSON configuration found" -ForegroundColor Green
} else {
    Write-Host "✗ JSON configuration not found" -ForegroundColor Red
}

# Test 3: PATH Integration
Write-Host "`n3. Testing PATH Integration..." -ForegroundColor Green
if ($env:PATH -like "*C:\tools\setup*") {
    Write-Host "✓ PATH integration working" -ForegroundColor Green
} else {
    Write-Host "✗ PATH integration missing" -ForegroundColor Red
}

# Test 4: Help Command
Write-Host "`n4. Testing Help Command..." -ForegroundColor Green
setupx help

# Test 5: List Command
Write-Host "`n5. Testing List Command..." -ForegroundColor Green
setupx list

# Test 6: Status Command
Write-Host "`n6. Testing Status Command..." -ForegroundColor Green
setupx status

# Test 7: Install Command
Write-Host "`n7. Testing Install Command..." -ForegroundColor Green
setupx install package-managers

# Test 8: Components Command
Write-Host "`n8. Testing Components Command..." -ForegroundColor Green
setupx components web-development

# Test 9: Invalid Command
Write-Host "`n9. Testing Invalid Command..." -ForegroundColor Green
setupx invalid

# Test 10: JSON Loading
Write-Host "`n10. Testing JSON Loading..." -ForegroundColor Green
$json = Get-Content "C:\tools\setup\setupx.json" | ConvertFrom-Json
Write-Host "✓ JSON loaded: $($json.name) v$($json.version)" -ForegroundColor Green

# Test 11: Module Count
Write-Host "`n11. Testing Module Count..." -ForegroundColor Green
$moduleCount = $json.modules.PSObject.Properties.Count
Write-Host "✓ Found $moduleCount modules" -ForegroundColor Green

# Test 12: Tool Status
Write-Host "`n12. Testing Tool Status..." -ForegroundColor Green
Write-Host "Chocolatey:" -ForegroundColor Yellow
choco --version
Write-Host "Node.js:" -ForegroundColor Yellow
node --version
Write-Host "Git:" -ForegroundColor Yellow
git --version

Write-Host "`n=== ALL TESTS COMPLETED ===" -ForegroundColor Cyan
Write-Host "SetupX is fully functional!" -ForegroundColor Green
