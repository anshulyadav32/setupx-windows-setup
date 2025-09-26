# Docker Desktop Component for setupx
# Installs Docker Desktop for Windows

# Component configuration
$ComponentConfig = @{
    name = "docker"
    displayName = "Docker Desktop"
    description = "Containerization platform for building and running applications"

    # Executables to test
    executableNames = @("docker.exe", "docker")

    # Version commands
    versionCommands = @("docker --version")

    # Test commands
    testCommands = @(
        "docker --version",
        "docker system info"
    )

    # Installation settings
    requiresAdmin = $true
    category = "containers"

    # Test paths
    testPaths = @(
        "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe",
        "${env:LOCALAPPDATA}\Docker\Docker Desktop.exe"
    )
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-Docker {
    param([switch]$Force, [switch]$SkipTest)

    Write-Host "`n[*] Installing Docker Desktop" -ForegroundColor Blue

    # Check current status
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-Host "[+] Docker Desktop is already installed and working!" -ForegroundColor Green
            return $testResult
        }
    }

    # Check system requirements
    Write-Host "Checking system requirements..." -ForegroundColor Yellow

    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Write-Host "[X] Docker Desktop requires Windows 10 or later" -ForegroundColor Red

        $result = [ComponentResult]::new()
        $result.Name = $ComponentConfig.displayName
        $result.Success = $false
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Windows version not supported"
        return $result
    }

    # Check for Hyper-V or WSL 2
    $hyperVFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue

    if ((-not $hyperVFeature -or $hyperVFeature.State -ne "Enabled") -and
        (-not $wslFeature -or $wslFeature.State -ne "Enabled")) {
        Write-Host "[!] Neither Hyper-V nor WSL 2 is enabled" -ForegroundColor Yellow
        Write-Host "Docker Desktop requires either Hyper-V or WSL 2" -ForegroundColor Gray

        $enableWSL = Read-Host "Would you like to enable WSL 2? (y/N)"
        if ($enableWSL -eq "y" -or $enableWSL -eq "Y") {
            try {
                Write-Host "Enabling WSL features..." -ForegroundColor White
                Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
                Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
                Write-Host "[+] WSL features enabled (restart required)" -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Failed to enable WSL features" -ForegroundColor Yellow
            }
        }
    }

    Write-Host "Installing Docker Desktop..." -ForegroundColor Yellow

    $installed = $false

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Installing via WinGet..." -ForegroundColor White
            winget install --id Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Docker Desktop installed via WinGet" -ForegroundColor Green
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
            choco install docker-desktop -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Docker Desktop installed via Chocolatey" -ForegroundColor Green
                $installed = $true
            }
        }
        catch {
            Write-Host "[!] Chocolatey installation failed" -ForegroundColor Yellow
        }
    }

    if (-not $installed) {
        Write-Host "[X] Failed to install Docker Desktop automatically" -ForegroundColor Red
        Write-Host "`nManual installation:" -ForegroundColor Cyan
        Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Gray

        $result = [ComponentResult]::new()
        $result.Name = $ComponentConfig.displayName
        $result.Success = $false
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Automatic installation failed - manual installation required"
        return $result
    }

    # Docker Desktop requires a restart to complete installation
    Write-Host "`n[!] Docker Desktop installation completed" -ForegroundColor Green
    Write-Host "[!] A system restart may be required for Docker to work properly" -ForegroundColor Yellow

    # Wait a moment before testing
    Start-Sleep -Seconds 5

    # Try to verify installation (may not work until restart)
    Write-Host "`nChecking Docker installation..." -ForegroundColor Cyan

    # Check if Docker Desktop executable exists
    $dockerDesktopPaths = @(
        "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe",
        "${env:LOCALAPPDATA}\Docker\Docker Desktop.exe"
    )

    $dockerDesktopFound = $false
    foreach ($path in $dockerDesktopPaths) {
        if (Test-Path $path) {
            Write-Host "[+] Docker Desktop executable found at: $path" -ForegroundColor Green
            $dockerDesktopFound = $true
            break
        }
    }

    if ($dockerDesktopFound) {
        Write-Host "`n[i] Docker Desktop Features:" -ForegroundColor Cyan
        Write-Host "  • Container orchestration and management" -ForegroundColor White
        Write-Host "  • Kubernetes integration" -ForegroundColor White
        Write-Host "  • Docker Compose for multi-container apps" -ForegroundColor White
        Write-Host "  • Volume and network management" -ForegroundColor White
        Write-Host "  • Integration with development tools" -ForegroundColor White

        Write-Host "`n[i] Getting Started:" -ForegroundColor Cyan
        Write-Host "  1. Start Docker Desktop from Start Menu" -ForegroundColor White
        Write-Host "  2. Wait for Docker to start (may take a few minutes)" -ForegroundColor White
        Write-Host "  3. Test with: docker run hello-world" -ForegroundColor White

        Write-Host "`n[i] Common Docker Commands:" -ForegroundColor Cyan
        Write-Host "  docker --version             - Show Docker version" -ForegroundColor White
        Write-Host "  docker run hello-world       - Test installation" -ForegroundColor White
        Write-Host "  docker ps                    - List running containers" -ForegroundColor White
        Write-Host "  docker images                - List downloaded images" -ForegroundColor White
        Write-Host "  docker pull [image]          - Download an image" -ForegroundColor White

        Write-Host "`n[!] Important Notes:" -ForegroundColor Yellow
        Write-Host "  • Docker Desktop must be running to use Docker commands" -ForegroundColor Gray
        Write-Host "  • First startup may take several minutes" -ForegroundColor Gray
        Write-Host "  • WSL 2 backend is recommended for better performance" -ForegroundColor Gray
    }

    $result = [ComponentResult]::new()
    $result.Name = $ComponentConfig.displayName
    $result.Success = $dockerDesktopFound
    $result.Status = if ($dockerDesktopFound) { [ComponentStatus]::Installed } else { [ComponentStatus]::NotInstalled }
    $result.Message = if ($dockerDesktopFound) { "Docker Desktop installed - restart may be required" } else { "Installation verification failed" }

    return $result
}

function Test-Docker {
    Write-Host "`n[*] Testing Docker Desktop Installation" -ForegroundColor Cyan

    # Check if Docker Desktop executable exists
    $dockerDesktopPaths = @(
        "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe",
        "${env:LOCALAPPDATA}\Docker\Docker Desktop.exe"
    )

    $dockerDesktopFound = $false
    foreach ($path in $dockerDesktopPaths) {
        if (Test-Path $path) {
            Write-Host "[+] Docker Desktop executable found" -ForegroundColor Green
            $dockerDesktopFound = $true
            break
        }
    }

    if (-not $dockerDesktopFound) {
        Write-Host "[X] Docker Desktop executable not found" -ForegroundColor Red

        $result = [ComponentResult]::new()
        $result.Name = $ComponentConfig.displayName
        $result.Success = $false
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Docker Desktop not installed"
        return $result
    }

    # Test Docker CLI
    try {
        $version = docker --version 2>$null
        if ($version) {
            Write-Host "[+] Docker CLI: $version" -ForegroundColor Green
        } else {
            Write-Host "[!] Docker CLI not available (Docker Desktop may not be running)" -ForegroundColor Yellow
        }

        # Try to get Docker system info (this requires Docker daemon to be running)
        $systemInfo = docker system info 2>$null
        if ($systemInfo) {
            Write-Host "[+] Docker daemon is running" -ForegroundColor Green

            # Parse some basic info
            $lines = $systemInfo -split "`n"
            $serverVersion = ($lines | Where-Object { $_ -match "Server Version:" }) -replace "Server Version:\s*", ""
            if ($serverVersion) {
                Write-Host "    Server Version: $serverVersion" -ForegroundColor Gray
            }

            $containers = ($lines | Where-Object { $_ -match "Containers:" }) -replace "Containers:\s*", ""
            if ($containers) {
                Write-Host "    Containers: $containers" -ForegroundColor Gray
            }
        } else {
            Write-Host "[!] Docker daemon not running" -ForegroundColor Yellow
            Write-Host "    Start Docker Desktop and try again" -ForegroundColor Gray
        }

    }
    catch {
        Write-Host "[!] Docker CLI test failed" -ForegroundColor Yellow
    }

    # Check for Docker Compose
    try {
        $composeVersion = docker-compose --version 2>$null
        if ($composeVersion) {
            Write-Host "[+] Docker Compose: $composeVersion" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[!] Docker Compose not available" -ForegroundColor Yellow
    }

    $result = [ComponentResult]::new()
    $result.Name = $ComponentConfig.displayName
    $result.Success = $dockerDesktopFound
    $result.Status = [ComponentStatus]::Installed
    $result.Message = "Docker Desktop is installed"

    return $result
}

function Update-Docker {
    Write-Host "`n[*] Updating Docker Desktop" -ForegroundColor Cyan

    try {
        # Try WinGet update first
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for Docker Desktop updates via WinGet..." -ForegroundColor White
            winget upgrade Docker.DockerDesktop --silent
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Docker Desktop updated via WinGet" -ForegroundColor Green
                return $true
            }
        }

        # Try Chocolatey update
        if (Get-Command "choco" -ErrorAction SilentlyContinue) {
            Write-Host "Checking for Docker Desktop updates via Chocolatey..." -ForegroundColor White
            choco upgrade docker-desktop -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[+] Docker Desktop updated via Chocolatey" -ForegroundColor Green
                return $true
            }
        }

        Write-Host "[!] Docker Desktop has built-in update notifications" -ForegroundColor Yellow
        Write-Host "Check for updates in Docker Desktop settings" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "[X] Failed to update Docker Desktop: $($_.Exception.Message)" -ForegroundColor Red
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
        'install' { Install-Docker -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-Docker }
        'update' { Update-Docker }
    }
}

# Export functions for module use
Export-ModuleMember -Function Install-Docker, Test-Docker, Update-Docker