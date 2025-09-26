# Package Managers Module Integration Test
# Simplified test to verify the package-managers module works independently

param(
    [ValidateSet('quick', 'full', 'components')]
    [string]$TestType = 'quick'
)

# Get module path
$ModulePath = $PSScriptRoot
$SharedPath = Split-Path (Split-Path $ModulePath) -Name | Join-Path (Split-Path (Split-Path $ModulePath)) "shared"

# Import shared functions
. "$SharedPath\component-manager.ps1"

# Load module configuration
$moduleConfig = Get-Content "$ModulePath\module.json" | ConvertFrom-Json

Write-SetupxOutput "`n╔══════════════════════════════════════════════════════════════╗" $Global:SetupxColors.Cyan
Write-SetupxOutput "║             PACKAGE MANAGERS INTEGRATION TEST                ║" $Global:SetupxColors.Cyan
Write-SetupxOutput "╚══════════════════════════════════════════════════════════════╝" $Global:SetupxColors.Cyan

Write-SetupxOutput "`nTesting Package Managers Module..." $Global:SetupxColors.White
Write-SetupxOutput "Module: $($moduleConfig.displayName)" $Global:SetupxColors.Gray
Write-SetupxOutput "Components: $($moduleConfig.components.Count)" $Global:SetupxColors.Gray

# Test each component
Write-SetupxOutput "`n🧪 COMPONENT TESTS" $Global:SetupxColors.Magenta

$testResults = @()

foreach ($component in $moduleConfig.components) {
    Write-SetupxOutput "`n📦 Testing $($component.displayName)..." $Global:SetupxColors.Cyan

    $componentScript = Join-Path $ModulePath "components\$($component.scriptName)"

    if (Test-Path $componentScript) {
        Write-SetupxOutput "   [+] Script file exists" $Global:SetupxColors.Green

        try {
            # Dot-source the component script
            . $componentScript
            Write-SetupxOutput "   [+] Script loaded successfully" $Global:SetupxColors.Green

            # Find and execute the test function
            $testFunctionName = "Test-$($component.name)"
            if (Get-Command $testFunctionName -ErrorAction SilentlyContinue) {
                Write-SetupxOutput "   [+] Test function ($testFunctionName) found" $Global:SetupxColors.Green

                if ($TestType -eq 'full') {
                    Write-SetupxOutput "   🔄 Running component test..." $Global:SetupxColors.White
                    try {
                        $result = & $testFunctionName
                        if ($result -and $result.Success) {
                            Write-SetupxOutput "   [+] Component test PASSED" $Global:SetupxColors.Green
                            $testResults += @{
                                Component = $component.displayName
                                Status = "PASSED"
                                Message = $result.Message
                            }
                        } else {
                            Write-SetupxOutput "   ❌ Component test FAILED" $Global:SetupxColors.Red
                            $testResults += @{
                                Component = $component.displayName
                                Status = "FAILED"
                                Message = if ($result) { $result.Message } else { "Unknown error" }
                            }
                        }
                    }
                    catch {
                        Write-SetupxOutput "   [!] Test execution error: $($_.Exception.Message)" $Global:SetupxColors.Yellow
                        $testResults += @{
                            Component = $component.displayName
                            Status = "ERROR"
                            Message = $_.Exception.Message
                        }
                    }
                } else {
                    Write-SetupxOutput "   ℹ️  Test function available (use -TestType full to run)" $Global:SetupxColors.Gray
                    $testResults += @{
                        Component = $component.displayName
                        Status = "AVAILABLE"
                        Message = "Test function ready"
                    }
                }
            } else {
                Write-SetupxOutput "   ❌ Test function not found" $Global:SetupxColors.Red
                $testResults += @{
                    Component = $component.displayName
                    Status = "NO_TEST"
                    Message = "Test function missing"
                }
            }
        }
        catch {
            Write-SetupxOutput "   ❌ Script loading error: $($_.Exception.Message)" $Global:SetupxColors.Red
            $testResults += @{
                Component = $component.displayName
                Status = "SCRIPT_ERROR"
                Message = $_.Exception.Message
            }
        }
    } else {
        Write-SetupxOutput "   ❌ Script file not found: $componentScript" $Global:SetupxColors.Red
        $testResults += @{
            Component = $component.displayName
            Status = "MISSING"
            Message = "Script file not found"
        }
    }
}

# Test module menu functionality
Write-SetupxOutput "`n🖥️  MENU SYSTEM TEST" $Global:SetupxColors.Magenta

$installScript = Join-Path $ModulePath "install-module.ps1"
if (Test-Path $installScript) {
    Write-SetupxOutput "[+] Module installer script exists" $Global:SetupxColors.Green

    try {
        # Test if the script can be parsed
        $scriptContent = Get-Content $installScript -Raw
        $tokens = $errors = $null
        [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$tokens, [ref]$errors)

        if ($errors.Count -eq 0) {
            Write-SetupxOutput "[+] Module installer has valid syntax" $Global:SetupxColors.Green
        } else {
            Write-SetupxOutput "❌ Module installer has syntax errors" $Global:SetupxColors.Red
            foreach ($error in $errors) {
                Write-SetupxOutput "   Line $($error.Extent.StartLineNumber): $($error.Message)" $Global:SetupxColors.Red
            }
        }
    }
    catch {
        Write-SetupxOutput "❌ Could not parse module installer" $Global:SetupxColors.Red
    }
} else {
    Write-SetupxOutput "❌ Module installer script not found" $Global:SetupxColors.Red
}

# Show test summary
Write-SetupxOutput "`n📊 TEST SUMMARY" $Global:SetupxColors.Magenta
Write-SetupxOutput "=" * 60 $Global:SetupxColors.Gray

$passed = ($testResults | Where-Object { $_.Status -eq "PASSED" }).Count
$available = ($testResults | Where-Object { $_.Status -eq "AVAILABLE" }).Count
$failed = ($testResults | Where-Object { $_.Status -ne "PASSED" -and $_.Status -ne "AVAILABLE" }).Count

Write-SetupxOutput "`nTest Results:" $Global:SetupxColors.Cyan
foreach ($result in $testResults) {
    $statusIcon = switch ($result.Status) {
        "PASSED" { "[+]" }
        "AVAILABLE" { "[o]" }
        "FAILED" { "[X]" }
        "ERROR" { "[!]" }
        "NO_TEST" { "[ ]" }
        "MISSING" { "[M]" }
        "SCRIPT_ERROR" { "[E]" }
        default { "[?]" }
    }

    Write-SetupxOutput "  $statusIcon $($result.Component): $($result.Status)" $Global:SetupxColors.White
    if ($result.Message) {
        Write-SetupxOutput "     $($result.Message)" $Global:SetupxColors.Gray
    }
}

Write-SetupxOutput "`nOverall Status:" $Global:SetupxColors.Cyan
$total = $testResults.Count
if ($TestType -eq 'full') {
    Write-SetupxOutput "  Passed: $passed/$total" $Global:SetupxColors.Green
    Write-SetupxOutput "  Failed: $failed/$total" $Global:SetupxColors.Red

    if ($failed -eq 0) {
        Write-SetupxOutput "[*] All tests passed! Package Managers module is ready!" $Global:SetupxColors.Green
    } else {
        Write-SetupxOutput "[!] Some tests failed. Review issues above." $Global:SetupxColors.Yellow
    }
} else {
    Write-SetupxOutput "  Available: $available/$total" $Global:SetupxColors.Cyan
    Write-SetupxOutput "  Issues: $failed/$total" $Global:SetupxColors.Red

    if ($failed -eq 0) {
        Write-SetupxOutput "[+] All components are properly structured!" $Global:SetupxColors.Green
        Write-SetupxOutput "[i] Run with -TestType full to execute actual tests" $Global:SetupxColors.Cyan
    } else {
        Write-SetupxOutput "[!] Some structural issues found. Review above." $Global:SetupxColors.Yellow
    }
}

Write-SetupxOutput "`n[i] Usage:" $Global:SetupxColors.Cyan
Write-SetupxOutput "  .\test-integration.ps1                # Quick structure test" $Global:SetupxColors.Gray
Write-SetupxOutput "  .\test-integration.ps1 -TestType full # Full test execution" $Global:SetupxColors.Gray
Write-SetupxOutput "  .\install-module.ps1                  # Install the module" $Global:SetupxColors.Gray
Write-SetupxOutput "  .\install-module.ps1 -AutoConfig     # Auto-configure all components" $Global:SetupxColors.Gray
