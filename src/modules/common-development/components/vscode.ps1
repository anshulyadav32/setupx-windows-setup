# Visual Studio Code Component for setupx
# Installs VS Code with essential extensions

# Component configuration
$ComponentConfig = @{
    name = "vscode"
    displayName = "Visual Studio Code"
    description = "Lightweight but powerful source code editor"

    # Executables to test
    executableNames = @("code.exe", "code")

    # Version commands
    versionCommands = @("code --version")

    # Test commands
    testCommands = @(
        "code --version",
        "code --list-extensions"
    )

    # Installation settings
    requiresAdmin = $false
    category = "editor"

    # Test paths
    testPaths = @(
        "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles}\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
    )
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-VSCode {
    param([switch]$Force, [switch]$SkipTest)

    Write-Host "`n[*] Installing Visual Studio Code" -ForegroundColor Blue

    # Check current status
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-Host "[+] VS Code is already installed and working!" -ForegroundColor Green
            return $testResult
        }
    }

    Write-Host "Installing Visual Studio Code..." -ForegroundColor Yellow

    $installed = $false

    # Try WinGet first (user scope)
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Installing via WinGet..." -ForegroundColor White
            winget install --id Microsoft.VisualStudioCode --silent --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] VS Code installed via WinGet" -ForegroundColor Green
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
            choco install vscode -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] VS Code installed via Chocolatey" -ForegroundColor Green
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
            scoop install vscode
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] VS Code installed via Scoop" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] Scoop installation failed" -ForegroundColor Yellow
        }
    }

    if (-not $installed) {
        Write-Host "[X] Failed to install VS Code automatically" -ForegroundColor Red
        Write-Host "`nManual installation:" -ForegroundColor Cyan
        Write-Host "Download from: https://code.visualstudio.com/" -ForegroundColor Gray

        $result = [ComponentResult]::new()
        $result.Name = $ComponentConfig.displayName
        $result.Success = $false
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Automatic installation failed - manual installation required"
        return $result
    }

    # Wait for installation to complete and refresh PATH
    Start-Sleep -Seconds 5
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

    # Verify installation
    $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($verifyResult.Success) {
        Write-Host "[+] VS Code installation completed!" -ForegroundColor Green

        # Install essential extensions
        Write-Host "`nInstalling essential extensions..." -ForegroundColor Cyan

        $essentialExtensions = @(
            @{ id = "ms-vscode.powershell"; name = "PowerShell" },
            @{ id = "ms-vscode-remote.remote-wsl"; name = "Remote - WSL" },
            @{ id = "ms-vscode.vscode-json"; name = "JSON Language Features" },
            @{ id = "redhat.vscode-yaml"; name = "YAML" },
            @{ id = "ms-vscode.hexeditor"; name = "Hex Editor" },
            @{ id = "formulahendry.code-runner"; name = "Code Runner" }
        )

        $installedExtensions = @()
        foreach ($ext in $essentialExtensions) {
            try {
                Write-Host "Installing $($ext.name)..." -ForegroundColor White
                code --install-extension $ext.id --force 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  [+] $($ext.name)" -ForegroundColor Green
                    $installedExtensions += $ext.name
                } else {
                    Write-Host "  [!] Failed: $($ext.name)" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "  [!] Error installing $($ext.name)" -ForegroundColor Yellow
            }
        }

        Write-Host "`n[i] VS Code Usage:" -ForegroundColor Cyan
        Write-Host "  code .                       - Open current directory" -ForegroundColor White
        Write-Host "  code filename.txt           - Open specific file" -ForegroundColor White
        Write-Host "  code --list-extensions      - List installed extensions" -ForegroundColor White
        Write-Host "  code --install-extension id - Install extension" -ForegroundColor White

        Write-Host "`n[i] Essential Extensions Installed:" -ForegroundColor Cyan
        foreach ($extName in $installedExtensions) {
            Write-Host "  • $extName" -ForegroundColor White
        }

        Write-Host "`n[i] Recommended Extensions:" -ForegroundColor Cyan
        Write-Host "  • GitLens — Git supercharged" -ForegroundColor Gray
        Write-Host "  • Bracket Pair Colorizer" -ForegroundColor Gray
        Write-Host "  • Auto Rename Tag" -ForegroundColor Gray
        Write-Host "  • Material Theme" -ForegroundColor Gray
        Write-Host "  • Live Server" -ForegroundColor Gray
    }

    return $verifyResult
}

function Test-VSCode {
    Write-Host "`n[*] Testing VS Code Installation" -ForegroundColor Cyan

    $result = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result.Success) {
        try {
            # Get version info
            $versionOutput = code --version 2>$null
            if ($versionOutput) {
                $versionLines = $versionOutput -split "`n"
                Write-Host "[+] VS Code version: $($versionLines[0])" -ForegroundColor Green
                if ($versionLines.Count -gt 1) {
                    Write-Host "    Commit: $($versionLines[1])" -ForegroundColor Gray
                }
            }

            # List installed extensions
            $extensions = code --list-extensions 2>$null
            if ($extensions) {
                $extCount = ($extensions | Measure-Object).Count
                Write-Host "[+] $extCount extensions installed" -ForegroundColor Green

                # Show first few extensions
                $extensionsList = $extensions | Select-Object -First 5
                foreach ($ext in $extensionsList) {
                    Write-Host "    • $ext" -ForegroundColor Gray
                }
                if ($extCount -gt 5) {
                    Write-Host "    ... and $($extCount - 5) more" -ForegroundColor Gray
                }
            }

            # Test if code command works
            $testFile = Join-Path $env:TEMP "vscode-test.txt"
            "VS Code test file" | Out-File -FilePath $testFile

            # Test opening file (should not block)
            Start-Process "code" -ArgumentList $testFile -WindowStyle Hidden
            Start-Sleep -Seconds 2
            Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue

            Write-Host "[+] VS Code command-line integration works" -ForegroundColor Green

        }
        catch {
            Write-Host "[!] VS Code functionality test had issues" -ForegroundColor Yellow
        }
    }

    return $result
}

function Update-VSCode {
    Write-Host "`n[*] Updating VS Code" -ForegroundColor Cyan

    try {
        # Try WinGet update first
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for VS Code updates via WinGet..." -ForegroundColor White
            winget upgrade Microsoft.VisualStudioCode --silent
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] VS Code updated via WinGet" -ForegroundColor Green
                return $true
            }
        }

        # Try Chocolatey update
        if (Get-Command "choco" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for VS Code updates via Chocolatey..." -ForegroundColor White
            choco upgrade vscode -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] VS Code updated via Chocolatey" -ForegroundColor Green
                return $true
            }
        }

        Write-Host "[!] VS Code has built-in auto-updates" -ForegroundColor Yellow
        Write-Host "Check for updates: Help > Check for Updates in VS Code" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "[X] Failed to update VS Code: $($_.Exception.Message)" -ForegroundColor Red
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
        'install' { Install-VSCode -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-VSCode }
        'update' { Update-VSCode }
    }
}

# Export functions for module use
# Functions are available for use
