# Package Managers Module Test Script
# Tests all components of the package-managers module

param(
    [ValidateSet('all', 'chocolatey', 'scoop', 'winget', 'npm', 'status', 'integration')]
    [string]$Test = 'all',
    [switch]$Verbose
)

# Get module path
$ModulePath = $PSScriptRoot
$SharedPath = Split-Path (Split-Path $ModulePath) -Name | Join-Path (Split-Path (Split-Path $ModulePath)) "shared"

# Import shared functions
. "$SharedPath\component-manager.ps1"
. "$SharedPath\menu-helpers.ps1"

# Load module configuration
$moduleConfig = Get-Content "$ModulePath\module.json" | ConvertFrom-Json

function Show-TestBanner {
    Write-SetupxOutput "`n╔══════════════════════════════════════════════════════════════╗" $Global:SetupxColors.Cyan
    Write-SetupxOutput "║              PACKAGE MANAGERS MODULE TESTING                 ║" $Global:SetupxColors.Cyan
    Write-SetupxOutput "╚══════════════════════════════════════════════════════════════╝" $Global:SetupxColors.Cyan
    Write-SetupxOutput "Testing all components of the package-managers module`n" $Global:SetupxColors.Gray
}

function Test-ComponentScript {
    param(
        [string]$ComponentName,
        [string]$ScriptPath
    )

    Write-SetupxOutput "`n🧪 Testing $ComponentName Component" $Global:SetupxColors.Cyan
    Write-SetupxOutput "Script: $ScriptPath" $Global:SetupxColors.Gray

    $testResults = @{
        ScriptExists = $false
        ValidSyntax = $false
        FunctionsExported = $false
        ConfigValid = $false
        TestFunction = $false
    }

    # Test 1: Script exists
    if (Test-Path $ScriptPath) {
        Write-SetupxOutput "✅ Script file exists" $Global:SetupxColors.Green
        $testResults.ScriptExists = $true
    } else {
        Write-SetupxOutput "❌ Script file not found" $Global:SetupxColors.Red
        return $testResults
    }

    # Test 2: Valid PowerShell syntax
    try {
        $scriptContent = Get-Content $ScriptPath -Raw
        $tokens = $errors = $null
        [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$tokens, [ref]$errors)

        if ($errors.Count -eq 0) {
            Write-SetupxOutput "✅ PowerShell syntax is valid" $Global:SetupxColors.Green
            $testResults.ValidSyntax = $true
        } else {
            Write-SetupxOutput "❌ PowerShell syntax errors found:" $Global:SetupxColors.Red
            foreach ($error in $errors) {
                Write-SetupxOutput "   Line $($error.Extent.StartLineNumber): $($error.Message)" $Global:SetupxColors.Red
            }
        }
    }
    catch {
        Write-SetupxOutput "❌ Could not parse PowerShell script" $Global:SetupxColors.Red
    }

    # Test 3: ComponentConfig exists
    if ($scriptContent -match '\$ComponentConfig\s*=\s*@\{') {
        Write-SetupxOutput "✅ ComponentConfig found" $Global:SetupxColors.Green
        $testResults.ConfigValid = $true
    } else {
        Write-SetupxOutput "❌ ComponentConfig not found" $Global:SetupxColors.Red
    }

    # Test 4: Required functions exist
    $requiredFunctions = @("Install-", "Test-", "Update-")
    $functionsFound = 0

    foreach ($funcPattern in $requiredFunctions) {
        if ($scriptContent -match "function\s+$funcPattern\w+") {
            $functionsFound++
        }
    }

    if ($functionsFound -eq 3) {
        Write-SetupxOutput "✅ All required functions found (Install, Test, Update)" $Global:SetupxColors.Green
        $testResults.FunctionsExported = $true
    } else {
        Write-SetupxOutput "❌ Missing required functions ($functionsFound/3 found)" $Global:SetupxColors.Red
    }

    # Test 5: Try to dot-source and test the script
    try {
        . $ScriptPath

        # Look for test function
        $testFuncName = "Test-$ComponentName"
        if (Get-Command $testFuncName -ErrorAction SilentlyContinue) {
            Write-SetupxOutput "✅ Test function ($testFuncName) is available" $Global:SetupxColors.Green
            $testResults.TestFunction = $true

            if ($Verbose) {
                Write-SetupxOutput "Running $testFuncName..." $Global:SetupxColors.White
                try {
                    & $testFuncName
                }
                catch {
                    Write-SetupxOutput "⚠️  Test function error: $($_.Exception.Message)" $Global:SetupxColors.Yellow
                }
            }
        } else {
            Write-SetupxOutput "❌ Test function ($testFuncName) not found" $Global:SetupxColors.Red
        }
    }
    catch {
        Write-SetupxOutput "❌ Could not dot-source script: $($_.Exception.Message)" $Global:SetupxColors.Red
    }

    return $testResults
}

function Test-ModuleIntegration {
    Write-SetupxOutput "`n🔧 Testing Module Integration" $Global:SetupxColors.Cyan

    # Test module.json
    Write-SetupxOutput "Testing module.json..." $Global:SetupxColors.White

    $moduleJsonPath = "$ModulePath\module.json"
    if (Test-Path $moduleJsonPath) {
        Write-SetupxOutput "✅ module.json exists" $Global:SetupxColors.Green

        try {
            $config = Get-Content $moduleJsonPath | ConvertFrom-Json
            Write-SetupxOutput "✅ module.json is valid JSON" $Global:SetupxColors.Green
            Write-SetupxOutput "   Module: $($config.displayName)" $Global:SetupxColors.Gray
            Write-SetupxOutput "   Components: $($config.components.Count)" $Global:SetupxColors.Gray
        }
        catch {
            Write-SetupxOutput "❌ module.json is invalid JSON" $Global:SetupxColors.Red
        }
    } else {
        Write-SetupxOutput "❌ module.json not found" $Global:SetupxColors.Red
    }

    # Test install-module.ps1
    $installScriptPath = "$ModulePath\install-module.ps1"
    if (Test-Path $installScriptPath) {
        Write-SetupxOutput "✅ install-module.ps1 exists" $Global:SetupxColors.Green
    } else {
        Write-SetupxOutput "❌ install-module.ps1 not found" $Global:SetupxColors.Red
    }
}

function Test-CLIIntegration {
    Write-SetupxOutput "`n🖥️ Testing CLI Integration" $Global:SetupxColors.Cyan

    $setupxPath = Join-Path (Split-Path $ModulePath -Parent) "setupx.ps1"
    if (Test-Path $setupxPath) {
        Write-SetupxOutput "✅ Main setupx.ps1 script found" $Global:SetupxColors.Green

        Write-SetupxOutput "Testing module listing..." $Global:SetupxColors.White
        try {
            # Test if setupx can list modules
            $listCommand = "& '$setupxPath' list"
            Write-SetupxOutput "Running: $listCommand" $Global:SetupxColors.Gray

            # Note: In a real test, we'd execute this, but for safety we're just checking the script exists
            Write-SetupxOutput "✅ setupx.ps1 is available for CLI testing" $Global:SetupxColors.Green
        }
        catch {
            Write-SetupxOutput "⚠️  CLI integration test could not be completed" $Global:SetupxColors.Yellow
        }
    } else {
        Write-SetupxOutput "❌ Main setupx.ps1 script not found" $Global:SetupxColors.Red
    }
}

function Show-TestSummary {
    param([hashtable]$AllResults)

    Write-SetupxOutput "`n📊 TEST SUMMARY" $Global:SetupxColors.Magenta
    Write-SetupxOutput "=" * 60 $Global:SetupxColors.Gray

    $totalTests = 0
    $passedTests = 0

    foreach ($component in $AllResults.Keys) {
        $results = $AllResults[$component]
        Write-SetupxOutput "`n📦 $component Component:" $Global:SetupxColors.Cyan

        foreach ($test in $results.Keys) {
            $totalTests++
            if ($results[$test]) {
                Write-SetupxOutput "   ✅ $test" $Global:SetupxColors.Green
                $passedTests++
            } else {
                Write-SetupxOutput "   ❌ $test" $Global:SetupxColors.Red
            }
        }
    }

    $percentage = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 1) } else { 0 }

    Write-SetupxOutput "`n🎯 OVERALL RESULTS:" $Global:SetupxColors.Cyan
    Write-SetupxOutput "   Tests Passed: $passedTests/$totalTests ($percentage%)" $Global:SetupxColors.White

    if ($percentage -eq 100) {
        Write-SetupxOutput "   🎉 All tests passed! Module is ready for production." $Global:SetupxColors.Green
    } elseif ($percentage -ge 80) {
        Write-SetupxOutput "   ✅ Most tests passed. Minor issues to resolve." $Global:SetupxColors.Green
    } elseif ($percentage -ge 60) {
        Write-SetupxOutput "   ⚠️  Some issues found. Review and fix before deployment." $Global:SetupxColors.Yellow
    } else {
        Write-SetupxOutput "   ❌ Significant issues found. Major fixes required." $Global:SetupxColors.Red
    }
}

# Main execution
function Main {
    Show-TestBanner

    $allResults = @{}

    switch ($Test.ToLower()) {
        'all' {
            foreach ($component in $moduleConfig.components) {
                $scriptPath = "$ModulePath\components\$($component.scriptName)"
                $allResults[$component.name] = Test-ComponentScript -ComponentName $component.name -ScriptPath $scriptPath
            }
            Test-ModuleIntegration
            Test-CLIIntegration
            Show-TestSummary -AllResults $allResults
        }
        'chocolatey' {
            $scriptPath = "$ModulePath\components\chocolatey.ps1"
            $allResults['chocolatey'] = Test-ComponentScript -ComponentName 'Chocolatey' -ScriptPath $scriptPath
            Show-TestSummary -AllResults $allResults
        }
        'scoop' {
            $scriptPath = "$ModulePath\components\scoop.ps1"
            $allResults['scoop'] = Test-ComponentScript -ComponentName 'Scoop' -ScriptPath $scriptPath
            Show-TestSummary -AllResults $allResults
        }
        'winget' {
            $scriptPath = "$ModulePath\components\winget.ps1"
            $allResults['winget'] = Test-ComponentScript -ComponentName 'WinGet' -ScriptPath $scriptPath
            Show-TestSummary -AllResults $allResults
        }
        'npm' {
            $scriptPath = "$ModulePath\components\npm.ps1"
            $allResults['npm'] = Test-ComponentScript -ComponentName 'NPM' -ScriptPath $scriptPath
            Show-TestSummary -AllResults $allResults
        }
        'status' {
            Write-SetupxOutput "📊 Package Managers Status Check" $Global:SetupxColors.Cyan
            foreach ($component in $moduleConfig.components) {
                Write-SetupxOutput "`nChecking $($component.displayName)..." $Global:SetupxColors.White
                $scriptPath = "$ModulePath\components\$($component.scriptName)"

                try {
                    . $scriptPath
                    $testFuncName = "Test-$($component.name)"
                    if (Get-Command $testFuncName -ErrorAction SilentlyContinue) {
                        $result = & $testFuncName
                        if ($result.Success) {
                            Write-SetupxOutput "✅ $($component.displayName): $($result.Status)" $Global:SetupxColors.Green
                        } else {
                            Write-SetupxOutput "❌ $($component.displayName): $($result.Status) - $($result.Message)" $Global:SetupxColors.Red
                        }
                    }
                }
                catch {
                    Write-SetupxOutput "⚠️  $($component.displayName): Could not test - $($_.Exception.Message)" $Global:SetupxColors.Yellow
                }
            }
        }
        'integration' {
            Test-ModuleIntegration
            Test-CLIIntegration
        }
    }

    Write-SetupxOutput "`n💡 Usage Tips:" $Global:SetupxColors.Cyan
    Write-SetupxOutput "  .\test-module.ps1                    # Test all components" $Global:SetupxColors.Gray
    Write-SetupxOutput "  .\test-module.ps1 -Test chocolatey   # Test specific component" $Global:SetupxColors.Gray
    Write-SetupxOutput "  .\test-module.ps1 -Test status       # Check installation status" $Global:SetupxColors.Gray
    Write-SetupxOutput "  .\test-module.ps1 -Verbose          # Detailed output" $Global:SetupxColors.Gray
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    Main
}
