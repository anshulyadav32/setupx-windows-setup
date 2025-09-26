# Test SetupX Installation
# Simple test to verify installation works

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-SetupxInstall {
    Write-ColorOutput "`nTESTING SETUPX INSTALLATION" "Cyan"
    Write-ColorOutput "Testing if SetupX can be installed..." "White"
    Write-ColorOutput ""
    
    $installPath = "C:\setupx-test"
    
    # Create test directory
    if (Test-Path $installPath) {
        Remove-Item -Path $installPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    Write-ColorOutput "SUCCESS: Created test directory: $installPath" "Green"
    
    # Copy current files
    $sourceDir = $PSScriptRoot
    Write-ColorOutput "Copying SetupX files..." "Magenta"
    Copy-Item -Path "$sourceDir\*" -Destination $installPath -Recurse -Force
    Write-ColorOutput "SUCCESS: SetupX files copied" "Green"
    
    # Create setupx.cmd wrapper
    $cmdPath = Join-Path $installPath "setupx.cmd"
    $cmdContent = @"
@echo off
powershell -ExecutionPolicy Bypass -File "$installPath\setupx.ps1" %*
"@
    
    Set-Content -Path $cmdPath -Value $cmdContent -Force
    Write-ColorOutput "SUCCESS: Created setupx.cmd wrapper" "Green"
    
    # Test the installation
    Write-ColorOutput "Testing SetupX command..." "Magenta"
    try {
        $testResult = & "$installPath\setupx.ps1" -h
        Write-ColorOutput "SUCCESS: SetupX command works!" "Green"
    } catch {
        Write-ColorOutput "ERROR: SetupX command failed - $($_.Exception.Message)" "Red"
    }
    
    # Cleanup
    Write-ColorOutput "Cleaning up test directory..." "Magenta"
    Remove-Item -Path $installPath -Recurse -Force
    Write-ColorOutput "SUCCESS: Test completed" "Green"
    
    Write-ColorOutput "`nSetupX installation test completed!" "Green"
}

# Execute test
Test-SetupxInstall
