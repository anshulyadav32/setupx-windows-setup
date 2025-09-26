# Git Component for setupx
# Installs and configures Git version control system

# Component configuration
$ComponentConfig = @{
    name = "git"
    displayName = "Git Version Control"
    description = "Distributed version control system"

    # Executables to test
    executableNames = @("git.exe", "git")

    # Version commands
    versionCommands = @("git --version")

    # Test commands
    testCommands = @(
        "git --version",
        "git config --list --global"
    )

    # Installation settings
    requiresAdmin = $true
    category = "version-control"

    # Test paths
    testPaths = @(
        "${env:ProgramFiles}\Git\bin\git.exe",
        "${env:ProgramFiles(x86)}\Git\bin\git.exe"
    )
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-Git {
    param([switch]$Force, [switch]$SkipTest)

    Write-Host "`n[*] Installing Git Version Control" -ForegroundColor Blue

    # Check current status
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-Host "[+] Git is already installed and working!" -ForegroundColor Green
            return $testResult
        }
    }

    # Check administrator privileges
    if (-not (Test-Administrator)) {
        throw "Git installation requires Administrator privileges"
    }

    Write-Host "Installing Git..." -ForegroundColor Yellow

    $installed = $false

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Installing via WinGet..." -ForegroundColor White
            winget install --id Git.Git --silent --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Git installed via WinGet" -ForegroundColor Green
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
            choco install git -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Git installed via Chocolatey" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] Chocolatey installation failed" -ForegroundColor Yellow
        }
    }

    if (-not $installed) {
        Write-Host "[X] Failed to install Git automatically" -ForegroundColor Red
        Write-Host "`nManual installation options:" -ForegroundColor Cyan
        Write-Host "1. Download from: https://git-scm.com/download/win" -ForegroundColor Gray
        Write-Host "2. Use GitHub Desktop: https://desktop.github.com/" -ForegroundColor Gray

        $result = [ComponentResult]::new()
        $result.Name = $ComponentConfig.displayName
        $result.Success = $false
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Automatic installation failed - manual installation required"
        return $result
    }

    # Wait for installation to complete
    Start-Sleep -Seconds 3

    # Refresh environment variables
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

    # Verify installation
    $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($verifyResult.Success) {
        Write-Host "[+] Git installation completed!" -ForegroundColor Green

        # Show Git configuration help
        Write-Host "`n[i] Git Configuration Steps:" -ForegroundColor Cyan
        Write-Host "  git config --global user.name \"Your Name\"" -ForegroundColor White
        Write-Host "  git config --global user.email \"your.email@example.com\"" -ForegroundColor White
        Write-Host "  git config --global init.defaultBranch main" -ForegroundColor White

        Write-Host "`n[i] Useful Git Commands:" -ForegroundColor Cyan
        Write-Host "  git clone [url]              - Clone a repository" -ForegroundColor White
        Write-Host "  git add .                    - Stage all changes" -ForegroundColor White
        Write-Host "  git commit -m \"message\"      - Commit changes" -ForegroundColor White
        Write-Host "  git push                     - Push to remote" -ForegroundColor White
        Write-Host "  git pull                     - Pull from remote" -ForegroundColor White
        Write-Host "  git status                   - Check status" -ForegroundColor White

        Write-Host "`n[i] SSH Key Setup (Optional):" -ForegroundColor Cyan
        Write-Host "  ssh-keygen -t rsa -b 4096 -C \"your.email@example.com\"" -ForegroundColor White
        Write-Host "  Add the public key to GitHub/GitLab/Bitbucket" -ForegroundColor Gray
    }

    return $verifyResult
}

function Test-Git {
    Write-Host "`n[*] Testing Git Installation" -ForegroundColor Cyan

    $result = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result.Success) {
        # Additional Git-specific tests
        try {
            $version = git --version 2>$null
            Write-Host "[+] Git version: $version" -ForegroundColor Green

            # Check global configuration
            $userName = git config --global user.name 2>$null
            $userEmail = git config --global user.email 2>$null

            if ($userName -and $userEmail) {
                Write-Host "[+] Git is configured:" -ForegroundColor Green
                Write-Host "    Name: $userName" -ForegroundColor Gray
                Write-Host "    Email: $userEmail" -ForegroundColor Gray
            } else {
                Write-Host "[!] Git is not configured yet" -ForegroundColor Yellow
                Write-Host "    Run: git config --global user.name \"Your Name\"" -ForegroundColor Gray
                Write-Host "    Run: git config --global user.email \"your.email@example.com\"" -ForegroundColor Gray
            }

            # Test basic Git functionality
            $tempDir = Join-Path $env:TEMP "git-test-$(Get-Random)"
            New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
            Push-Location $tempDir

            try {
                git init 2>$null | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[+] Git repository initialization works" -ForegroundColor Green
                }

                # Create a test file and commit
                "Test file" | Out-File -FilePath "test.txt"
                git add test.txt 2>$null
                git commit -m "Test commit" 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[+] Git commit functionality works" -ForegroundColor Green
                }
            }
            catch {
                Write-Host "[!] Git basic operations test failed" -ForegroundColor Yellow
            }
            finally {
                Pop-Location
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }

        }
        catch {
            Write-Host "[!] Git functionality test failed" -ForegroundColor Yellow
        }
    }

    return $result
}

function Update-Git {
    Write-Host "`n[*] Updating Git" -ForegroundColor Cyan

    try {
        # Try WinGet update first
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for Git updates via WinGet..." -ForegroundColor White
            winget upgrade Git.Git --silent
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Git updated via WinGet" -ForegroundColor Green
                return $true
            }
        }

        # Try Chocolatey update
        if (Get-Command "choco" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for Git updates via Chocolatey..." -ForegroundColor White
            choco upgrade git -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Git updated via Chocolatey" -ForegroundColor Green
                return $true
            }
        }

        Write-Host "[!] Could not update Git automatically" -ForegroundColor Yellow
        Write-Host "Visit https://git-scm.com/download/win for manual update" -ForegroundColor Gray
        return $false
    }
    catch {
        Write-Host "[X] Failed to update Git: $($_.Exception.Message)" -ForegroundColor Red
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
        'install' { Install-Git -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-Git }
        'update' { Update-Git }
    }
}

# Export functions for module use
Export-ModuleMember -Function Install-Git, Test-Git, Update-Git