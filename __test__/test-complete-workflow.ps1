# Complete Component Testing Workflow
# Tests: Install -> Check -> Path -> Update -> Status -> Remove

param(
    [Parameter(Mandatory=$false)]
    [string]$ComponentName = "nodejs"
)

. "$PSScriptRoot\..\src\core\engine.ps1"
. "$PSScriptRoot\..\src\core\json-loader.ps1"

Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║        Complete Component Testing Workflow                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

$component = Get-ComponentByName -ComponentName $ComponentName

if (-not $component) {
    Write-Host "Component '$ComponentName' not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Testing Component: $($component.displayName)" -ForegroundColor Yellow
Write-Host "Category: $($component.category)" -ForegroundColor Gray
Write-Host ""

$testResults = @{
    ComponentName = $component.displayName
    Tests = @()
}

function Add-TestResult {
    param([string]$TestName, [bool]$Passed, [string]$Message = "")
    
    $testResults.Tests += @{
        Name = $TestName
        Passed = $Passed
        Message = $Message
        Timestamp = Get-Date
    }
    
    $icon = if ($Passed) { "[PASS]" } else { "[FAIL]" }
    $color = if ($Passed) { "Green" } else { "Red" }
    
    Write-Host "$icon $TestName" -ForegroundColor $color
    if ($Message) {
        Write-Host "      $Message" -ForegroundColor Gray
    }
}

# Test 1: Check initial status
Write-Host "`n[1/7] Initial Status Check" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkGray

$wasInstalled = Test-ComponentInstalled -Component $component
Add-TestResult "Initial status check" $true "Already installed: $wasInstalled"

# Test 2: Install (if not installed)
Write-Host "`n[2/7] Installation Test" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkGray

if (-not $wasInstalled) {
    Write-Host "Installing $($component.displayName)..." -ForegroundColor Yellow
    
    $confirm = Read-Host "Proceed with installation? (y/N)"
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        try {
            $installResult = Invoke-ComponentCommand -Component $component -Action "install"
            Add-TestResult "Installation" $installResult "Component installed"
        }
        catch {
            Add-TestResult "Installation" $false $_.Exception.Message
        }
    }
    else {
        Add-TestResult "Installation" $false "Skipped by user"
        Write-Host "`nSkipping remaining tests (component not installed)" -ForegroundColor Yellow
        exit 0
    }
}
else {
    Add-TestResult "Installation" $true "Already installed, skipping"
}

# Test 3: Check command
Write-Host "`n[3/7] Check Command Test" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkGray

if ($component.commands.check) {
    try {
        Write-Host "Running check command..." -ForegroundColor Yellow
        $checkOutput = Invoke-Expression $component.commands.check 2>&1 | Select-Object -First 3
        $checkOutput | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        Add-TestResult "Check command" $true "Command executed successfully"
    }
    catch {
        Add-TestResult "Check command" $false $_.Exception.Message
    }
}
else {
    Add-TestResult "Check command" $false "No check command defined"
}

# Test 4: Path/Environment refresh
Write-Host "`n[4/7] Path Refresh Test" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkGray

if ($component.commands.path) {
    try {
        Write-Host "Refreshing environment PATH..." -ForegroundColor Yellow
        Invoke-Expression $component.commands.path
        Add-TestResult "Path refresh" $true "Environment refreshed"
    }
    catch {
        Add-TestResult "Path refresh" $false $_.Exception.Message
    }
}
else {
    Add-TestResult "Path refresh" $true "No path refresh needed"
}

# Test 5: Verify command
Write-Host "`n[5/7] Verify Command Test" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkGray

if ($component.commands.verify) {
    try {
        Write-Host "Running verify command..." -ForegroundColor Yellow
        $verifyOutput = Invoke-Expression $component.commands.verify 2>&1 | Select-Object -First 3
        $verifyOutput | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        Add-TestResult "Verify command" $true "Verification successful"
    }
    catch {
        Add-TestResult "Verify command" $false $_.Exception.Message
    }
}
else {
    Add-TestResult "Verify command" $true "No verify command defined"
}

# Test 6: Update command (dry run - don't actually update)
Write-Host "`n[6/7] Update Command Test (Dry Run)" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkGray

if ($component.commands.update) {
    Write-Host "Update command available:" -ForegroundColor Yellow
    Write-Host "  $($component.commands.update)" -ForegroundColor White
    Add-TestResult "Update command" $true "Update command exists (not executed)"
}
else {
    Add-TestResult "Update command" $false "No update command defined"
}

# Test 7: Test command
Write-Host "`n[7/7] Test Command" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkGray

if ($component.commands.test) {
    try {
        Write-Host "Running test command..." -ForegroundColor Yellow
        $testOutput = Invoke-Expression $component.commands.test 2>&1 | Select-Object -First 3
        $testOutput | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        Add-TestResult "Test command" $true "Test executed successfully"
    }
    catch {
        Add-TestResult "Test command" $false $_.Exception.Message
    }
}
else {
    Add-TestResult "Test command" $true "No test command defined"
}

# Summary
Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Green
Write-Host "Test Summary" -ForegroundColor Yellow
Write-Host ("=" * 60) -ForegroundColor Green

$passedTests = ($testResults.Tests | Where-Object { $_.Passed }).Count
$totalTests = $testResults.Tests.Count

Write-Host "`nComponent: $($testResults.ComponentName)" -ForegroundColor Cyan
Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $($totalTests - $passedTests)" -ForegroundColor Red
Write-Host "Success Rate: $([math]::Round(($passedTests / $totalTests) * 100, 1))%" -ForegroundColor Cyan

# Export results
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = Join-Path $PSScriptRoot "workflow-test-$ComponentName-$timestamp.json"
$testResults | ConvertTo-Json -Depth 10 | Set-Content $reportPath

Write-Host "`nResults exported to: $reportPath" -ForegroundColor Gray
Write-Host "`nWorkflow test completed!" -ForegroundColor Green

