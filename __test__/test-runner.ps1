# SetupX Test Runner
# Tests all components one by one

param(
    [Parameter(Mandatory=$false)]
    [string]$ModuleName,
    
    [Parameter(Mandatory=$false)]
    [string]$ComponentName,
    
    [Parameter(Mandatory=$false)]
    [switch]$Quick
)

# Import core modules
. "$PSScriptRoot\..\src\core\engine.ps1"
. "$PSScriptRoot\..\src\core\json-loader.ps1"
. "$PSScriptRoot\..\src\utils\logger.ps1"

$script:TestResults = @()

function Write-TestHeader {
    param([string]$Title)
    
    Write-Host "`n" -NoNewline
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Yellow
    Write-Host "=" * 70 -ForegroundColor Cyan
}

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = ""
    )
    
    $result = [PSCustomObject]@{
        TestName = $TestName
        Passed = $Passed
        Message = $Message
        Timestamp = Get-Date
    }
    
    $script:TestResults += $result
    
    $icon = if ($Passed) { "[PASS]" } else { "[FAIL]" }
    $color = if ($Passed) { "Green" } else { "Red" }
    
    Write-Host "$icon $TestName" -ForegroundColor $color
    if ($Message) {
        Write-Host "      $Message" -ForegroundColor Gray
    }
}

function Test-ComponentCheck {
    param([PSCustomObject]$Component)
    
    Write-Host "`n  Testing: $($Component.displayName)" -ForegroundColor Cyan
    Write-Host "  Category: $($Component.category)" -ForegroundColor Gray
    Write-Host "  Module: $($Component.moduleName)" -ForegroundColor Gray
    
    # Test 1: Check if component has required properties
    $hasName = -not [string]::IsNullOrEmpty($Component.name)
    Write-TestResult "Has name property" $hasName
    
    $hasDisplayName = -not [string]::IsNullOrEmpty($Component.displayName)
    Write-TestResult "Has displayName property" $hasDisplayName
    
    $hasCommands = $null -ne $Component.commands
    Write-TestResult "Has commands property" $hasCommands
    
    # Test 2: Check if install command exists
    if ($hasCommands) {
        $hasInstall = -not [string]::IsNullOrEmpty($Component.commands.install)
        Write-TestResult "Has install command" $hasInstall $Component.commands.install
        
        $hasCheck = -not [string]::IsNullOrEmpty($Component.commands.check)
        Write-TestResult "Has check command" $hasCheck $Component.commands.check
    }
    
    # Test 3: Check if component is installed
    if ($Component.commands.check) {
        Write-Host "`n  Checking installation status..." -ForegroundColor Yellow
        $isInstalled = Test-ComponentInstalled -Component $Component
        Write-TestResult "Installation check" $true "Installed: $isInstalled"
        
        if ($isInstalled -and $Component.commands.check) {
            Write-Host "`n  Running version check..." -ForegroundColor Yellow
            try {
                $checkResult = Invoke-Expression $Component.commands.check 2>&1
                Write-TestResult "Version check executed" $true $checkResult
            }
            catch {
                Write-TestResult "Version check executed" $false $_.Exception.Message
            }
        }
    }
    
    Write-Host ""
}

function Test-AllComponents {
    param(
        [string]$FilterModule = "",
        [string]$FilterComponent = ""
    )
    
    Write-TestHeader "SetupX Component Testing"
    
    $allComponents = Get-AllComponents
    
    if ($FilterModule) {
        $allComponents = $allComponents | Where-Object { $_.moduleName -eq $FilterModule }
        Write-Host "Filtering by module: $FilterModule" -ForegroundColor Yellow
    }
    
    if ($FilterComponent) {
        $allComponents = $allComponents | Where-Object { $_.name -like "*$FilterComponent*" }
        Write-Host "Filtering by component: $FilterComponent" -ForegroundColor Yellow
    }
    
    Write-Host "`nTotal components to test: $($allComponents.Count)" -ForegroundColor Cyan
    Write-Host ""
    
    $counter = 0
    foreach ($component in $allComponents | Sort-Object moduleName, name) {
        $counter++
        Write-Host "`n[$counter/$($allComponents.Count)]" -ForegroundColor DarkGray -NoNewline
        Test-ComponentCheck -Component $component
        
        if (-not $Quick) {
            Start-Sleep -Milliseconds 500
        }
    }
}

function Show-TestSummary {
    Write-TestHeader "Test Summary"
    
    $totalTests = $script:TestResults.Count
    $passedTests = ($script:TestResults | Where-Object { $_.Passed }).Count
    $failedTests = ($script:TestResults | Where-Object { -not $_.Passed }).Count
    
    Write-Host "`nTotal Tests: $totalTests" -ForegroundColor Cyan
    Write-Host "Passed: $passedTests" -ForegroundColor Green
    Write-Host "Failed: $failedTests" -ForegroundColor Red
    
    $successRate = if ($totalTests -gt 0) { 
        [math]::Round(($passedTests / $totalTests) * 100, 2) 
    } else { 0 }
    
    Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } else { "Yellow" })
    
    if ($failedTests -gt 0) {
        Write-Host "`nFailed Tests:" -ForegroundColor Red
        $script:TestResults | Where-Object { -not $_.Passed } | ForEach-Object {
            Write-Host "  - $($_.TestName): $($_.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

function Export-TestResults {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = Join-Path $PSScriptRoot "test-results-$timestamp.json"
    
    $report = [PSCustomObject]@{
        Timestamp = Get-Date
        TotalTests = $script:TestResults.Count
        PassedTests = ($script:TestResults | Where-Object { $_.Passed }).Count
        FailedTests = ($script:TestResults | Where-Object { -not $_.Passed }).Count
        Results = $script:TestResults
    }
    
    $report | ConvertTo-Json -Depth 10 | Set-Content $reportPath
    Write-Host "Test results exported to: $reportPath" -ForegroundColor Cyan
}

# Main execution
Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║              SetupX Component Test Suite                  ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Test-AllComponents -FilterModule $ModuleName -FilterComponent $ComponentName
Show-TestSummary
Export-TestResults

Write-Host "`nTest run completed!" -ForegroundColor Green

