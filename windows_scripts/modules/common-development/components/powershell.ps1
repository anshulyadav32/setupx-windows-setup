# PowerShell 7+ Component for setupx
# Installs modern cross-platform PowerShell

# Component configuration
$ComponentConfig = @{
    name = "powershell"
    displayName = "PowerShell 7+"
    description = "Modern cross-platform PowerShell"

    # Executables to test
    executableNames = @("pwsh.exe", "pwsh")

    # Version commands
    versionCommands = @("pwsh --version")

    # Test commands
    testCommands = @(
        "pwsh --version",
        "pwsh -Command Get-Host"
    )

    # Installation settings
    requiresAdmin = $false
    category = "shell"

    # Test paths
    testPaths = @(
        "${env:ProgramFiles}\PowerShell\7\pwsh.exe",
        "${env:ProgramFiles(x86)}\PowerShell\7\pwsh.exe"
    )
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-PowerShell {
    param([switch]$Force, [switch]$SkipTest)

    Write-Host "`n[*] Installing PowerShell 7+" -ForegroundColor Blue

    # Check current status
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-Host "[+] PowerShell 7+ is already installed and working!" -ForegroundColor Green
            return $testResult
        }
    }

    Write-Host "Installing PowerShell 7+..." -ForegroundColor Yellow

    $installed = $false

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Installing via WinGet..." -ForegroundColor White
            winget install --id Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] PowerShell 7+ installed via WinGet" -ForegroundColor Green
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
            choco install powershell-core -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] PowerShell 7+ installed via Chocolatey" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] Chocolatey installation failed" -ForegroundColor Yellow
        }
    }

    # Try Scoop as third option
    if (-not $installed -and (Get-Command "scoop" -ErrorAction SilentlyContinue)) {
        try {
            Write-Host "Installing via Scoop..." -ForegroundColor White
            scoop install powershell
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] PowerShell 7+ installed via Scoop" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] Scoop installation failed" -ForegroundColor Yellow
        }
    }

    if (-not $installed) {
        Write-Host "[X] Failed to install PowerShell 7+ automatically" -ForegroundColor Red
        Write-Host "`nManual installation options:" -ForegroundColor Cyan
        Write-Host "1. Download from: https://github.com/PowerShell/PowerShell/releases" -ForegroundColor Gray
        Write-Host "2. Use Microsoft Store: search for PowerShell" -ForegroundColor Gray

        $result = [ComponentResult]::new()
        $result.Name = $ComponentConfig.displayName
        $result.Success = $false
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Automatic installation failed - manual installation required"
        return $result
    }

    # Wait for installation to complete and refresh PATH
    Start-Sleep -Seconds 3
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

    # Verify installation
    $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($verifyResult.Success) {
        Write-Host "[+] PowerShell 7+ installation completed!" -ForegroundColor Green

        Write-Host "`n[i] PowerShell 7+ Features:" -ForegroundColor Cyan
        Write-Host "  • Cross-platform compatibility" -ForegroundColor White
        Write-Host "  • Improved performance and speed" -ForegroundColor White
        Write-Host "  • Enhanced cmdlets and modules" -ForegroundColor White
        Write-Host "  • Better JSON and REST support" -ForegroundColor White
        Write-Host "  • Parallel processing capabilities" -ForegroundColor White

        Write-Host "`n[i] Usage:" -ForegroundColor Cyan
        Write-Host "  pwsh                         - Start PowerShell 7+" -ForegroundColor White
        Write-Host "  pwsh -Command \"Get-Process\" - Run single command" -ForegroundColor White
        Write-Host "  pwsh -File script.ps1       - Run PowerShell script" -ForegroundColor White

        Write-Host "`n[i] Key Differences from Windows PowerShell 5.1:" -ForegroundColor Cyan
        Write-Host "  • Uses 'pwsh' command instead of 'powershell'" -ForegroundColor Gray
        Write-Host "  • Side-by-side with Windows PowerShell" -ForegroundColor Gray
        Write-Host "  • Built on .NET Core/.NET 5+" -ForegroundColor Gray
        Write-Host "  • Regular updates via package managers" -ForegroundColor Gray

        # Try to install useful modules
        Write-Host "`nInstalling useful PowerShell modules..." -ForegroundColor Cyan
        $modules = @("PSReadLine", "PowerShellGet", "Terminal-Icons")

        foreach ($module in $modules) {
            try {
                Write-Host "Installing $module..." -ForegroundColor White
                pwsh -Command "Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser" 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  [+] $module installed" -ForegroundColor Green
                } else {
                    Write-Host "  [!] $module installation failed" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "  [!] Error installing $module" -ForegroundColor Yellow
            }
        }
    }

    return $verifyResult
}

function Test-PowerShell {
    Write-Host "`n[*] Testing PowerShell 7+ Installation" -ForegroundColor Cyan

    $result = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result.Success) {
        try {
            # Get version info
            $version = pwsh --version 2>$null
            Write-Host "[+] PowerShell version: $version" -ForegroundColor Green

            # Test PowerShell functionality
            $hostInfo = pwsh -Command "Get-Host | Select-Object Name, Version" 2>$null
            if ($hostInfo) {
                Write-Host "[+] PowerShell host is responsive" -ForegroundColor Green
            }

            # Check for common modules
            $modules = pwsh -Command "Get-Module -ListAvailable | Where-Object { $_.Name -in @('PSReadLine', 'PowerShellGet', 'Terminal-Icons') } | Select-Object Name, Version" 2>$null
            if ($modules) {
                Write-Host "[+] Additional modules available:" -ForegroundColor Green
                $modulesList = $modules -split "`n" | Where-Object { $_.Trim() -ne "" }
                foreach ($moduleInfo in $modulesList | Select-Object -First 5) {
                    if ($moduleInfo.Trim()) {
                        Write-Host "    $($moduleInfo.Trim())" -ForegroundColor Gray
                    }
                }
            }

            # Test JSON handling (PowerShell 7+ feature)
            $jsonTest = pwsh -Command "'{\`"test\`": \`"value\`"}' | ConvertFrom-Json | ConvertTo-Json -Compress" 2>$null
            if ($jsonTest -eq '{"test":"value"}') {
                Write-Host "[+] JSON processing works correctly" -ForegroundColor Green
            }

            # Compare with Windows PowerShell version
            if (Get-Command "powershell" -ErrorAction SilentlyContinue) {
                $winPSVersion = powershell -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
                if ($winPSVersion) {
                    Write-Host "[i] Windows PowerShell version: $winPSVersion" -ForegroundColor Gray
                    Write-Host "[i] Both PowerShell versions are available" -ForegroundColor Gray
                }
            }

        }
        catch {
            Write-Host "[!] PowerShell 7+ functionality test had issues" -ForegroundColor Yellow
        }
    }

    return $result
}

function Update-PowerShell {
    Write-Host "`n[*] Updating PowerShell 7+" -ForegroundColor Cyan

    try {
        # Try WinGet update first
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for PowerShell updates via WinGet..." -ForegroundColor White
            winget upgrade Microsoft.PowerShell --silent
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] PowerShell updated via WinGet" -ForegroundColor Green
                return $true
            }
        }

        # Try Chocolatey update
        if (Get-Command "choco" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for PowerShell updates via Chocolatey..." -ForegroundColor White
            choco upgrade powershell-core -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] PowerShell updated via Chocolatey" -ForegroundColor Green
                return $true
            }
        }

        # Try Scoop update
        if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for PowerShell updates via Scoop..." -ForegroundColor White
            scoop update powershell
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] PowerShell updated via Scoop" -ForegroundColor Green
                return $true
            }
        }

        Write-Host "[!] Could not update PowerShell automatically" -ForegroundColor Yellow
        Write-Host "Check: https://github.com/PowerShell/PowerShell/releases" -ForegroundColor Gray
        return $false
    }
    catch {
        Write-Host "[X] Failed to update PowerShell: $($_.Exception.Message)" -ForegroundColor Red
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
        'install' { Install-PowerShell -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-PowerShell }
        'update' { Update-PowerShell }
    }
}

# Export functions for module use
Export-ModuleMember -Function Install-PowerShell, Test-PowerShell, Update-PowerShell