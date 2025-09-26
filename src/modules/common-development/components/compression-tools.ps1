# Compression Tools Component for setupx
# Installs 7-Zip for archive management

# Component configuration
$ComponentConfig = @{
    name = "compression-tools"
    displayName = "Compression Tools"
    description = "7-Zip for archive management"

    # Executables to test
    executableNames = @("7z.exe", "7z")

    # Version commands
    versionCommands = @("7z")

    # Test commands
    testCommands = @("7z")

    # Installation settings
    requiresAdmin = $true
    category = "utilities"

    # Test paths
    testPaths = @(
        "${env:ProgramFiles}\7-Zip\7z.exe",
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    )
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-CompressionTools {
    param([switch]$Force, [switch]$SkipTest)

    Write-Host "`n[*] Installing Compression Tools (7-Zip)" -ForegroundColor Blue

    # Check current status
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-Host "[+] 7-Zip is already installed and working!" -ForegroundColor Green
            return $testResult
        }
    }

    Write-Host "Installing 7-Zip..." -ForegroundColor Yellow

    $installed = $false

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Installing via WinGet..." -ForegroundColor White
            winget install --id 7zip.7zip --silent --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] 7-Zip installed via WinGet" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] WinGet installation failed" -ForegroundColor Yellow
        }
    }

    # Try Chocolatey as fallback
    if (-not $installed -and (Get-Command "choco" -ErrorAction SilentlyContinue)) {
        try {
            Write-Host "Installing via Chocolatey..." -ForegroundColor White
            choco install 7zip -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] 7-Zip installed via Chocolatey" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] Chocolatey installation failed" -ForegroundColor Yellow
        }
    }

    if (-not $installed) {
        Write-Host "[X] Failed to install 7-Zip automatically" -ForegroundColor Red
        Write-Host "`nManual installation:" -ForegroundColor Cyan
        Write-Host "Download from: https://www.7-zip.org/" -ForegroundColor Gray

        $result = [ComponentResult]::new()
        $result.Name = $ComponentConfig.displayName
        $result.Success = $false
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Automatic installation failed"
        return $result
    }

    # Refresh PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

    # Verify installation
    $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($verifyResult.Success) {
        Write-Host "[+] 7-Zip installation completed!" -ForegroundColor Green
        Write-Host "`n[i] Usage examples:" -ForegroundColor Cyan
        Write-Host "  7z a archive.7z files/       - Create archive" -ForegroundColor White
        Write-Host "  7z x archive.7z              - Extract archive" -ForegroundColor White
        Write-Host "  7z l archive.7z              - List archive contents" -ForegroundColor White
    }

    return $verifyResult
}

function Test-CompressionTools {
    Write-Host "`n[*] Testing 7-Zip Installation" -ForegroundColor Cyan
    return Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
}

function Update-CompressionTools {
    Write-Host "`n[*] Updating 7-Zip" -ForegroundColor Cyan

    try {
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget upgrade 7zip.7zip --silent
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] 7-Zip updated" -ForegroundColor Green
                return $true
            }
        }
        return $false
    }
    catch {
        return $false
    }
}

# Main execution logic
if ($MyInvocation.InvocationName -ne '.') {
    param(
        [ValidateSet('install', 'test', 'update')]
        [string]$Action = 'install',
        [switch]$Force,
        [switch]$SkipTest
    )

    switch ($Action.ToLower()) {
        'install' { Install-CompressionTools -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-CompressionTools }
        'update' { Update-CompressionTools }
    }
}

Export-ModuleMember -Function Install-CompressionTools, Test-CompressionTools, Update-CompressionTools