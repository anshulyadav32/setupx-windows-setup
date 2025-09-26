# Postman Component for setupx
# Installs Postman API development platform

# Component configuration
$ComponentConfig = @{
    name = "postman"
    displayName = "Postman"
    description = "API development and testing platform"

    # Executables to test
    executableNames = @("Postman.exe", "postman")

    # Version commands
    versionCommands = @()

    # Test commands
    testCommands = @()

    # Installation settings
    requiresAdmin = $false
    category = "api-tools"

    # Test paths
    testPaths = @(
        "${env:LOCALAPPDATA}\Postman\Postman.exe",
        "${env:ProgramFiles}\Postman\Postman.exe"
    )
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-Postman {
    param([switch]$Force, [switch]$SkipTest)

    Write-Host "`n[*] Installing Postman" -ForegroundColor Blue

    # Check current status
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-Host "[+] Postman is already installed!" -ForegroundColor Green
            return $testResult
        }
    }

    Write-Host "Installing Postman..." -ForegroundColor Yellow

    $installed = $false

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Installing via WinGet..." -ForegroundColor White
            winget install --id Postman.Postman --silent --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Postman installed via WinGet" -ForegroundColor Green
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
            choco install postman -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Postman installed via Chocolatey" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] Chocolatey installation failed" -ForegroundColor Yellow
        }
    }

    if (-not $installed) {
        Write-Host "[X] Failed to install Postman automatically" -ForegroundColor Red
        Write-Host "`nManual installation:" -ForegroundColor Cyan
        Write-Host "Download from: https://www.postman.com/downloads/" -ForegroundColor Gray

        $result = [ComponentResult]::new()
        $result.Name = $ComponentConfig.displayName
        $result.Success = $false
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Automatic installation failed"
        return $result
    }

    Start-Sleep -Seconds 3

    # Verify installation
    $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($verifyResult.Success) {
        Write-Host "[+] Postman installation completed!" -ForegroundColor Green
        Write-Host "`n[i] Postman Features:" -ForegroundColor Cyan
        Write-Host "  • API request building and testing" -ForegroundColor White
        Write-Host "  • Collection management" -ForegroundColor White
        Write-Host "  • Environment variables" -ForegroundColor White
        Write-Host "  • Automated testing scripts" -ForegroundColor White
        Write-Host "  • Team collaboration" -ForegroundColor White
    }

    return $verifyResult
}

function Test-Postman {
    Write-Host "`n[*] Testing Postman Installation" -ForegroundColor Cyan
    return Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
}

function Update-Postman {
    Write-Host "`n[*] Updating Postman" -ForegroundColor Cyan

    try {
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget upgrade Postman.Postman --silent
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Postman updated" -ForegroundColor Green
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
        'install' { Install-Postman -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-Postman }
        'update' { Update-Postman }
    }
}

# Functions are available for use
