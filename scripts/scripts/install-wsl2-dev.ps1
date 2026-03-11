# Install WSL2 prerequisites and developer apps (VS Code + Google Chrome)

# Run as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

# In PowerShell 7+, non-zero native exits can become terminating errors.
if (Get-Variay
ble PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $global:PSNativeCommandUseErrorActionPreference = $false
}

function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is already installed."
        return
    }

    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Error "Chocolatey installation failed."
        exit 1
    }
}

function Install-WithChocolatey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        [string]$DisplayName = $PackageName
    )

    Write-Host "Installing $DisplayName with Chocolatey..."
    $output = choco install $PackageName -y --no-progress 2>&1
    $exitCode = $LASTEXITCODE

    if ($output) {
        $output | ForEach-Object { Write-Host $_ }
    }

    if ($exitCode -ne 0 -and -not ($output -match 'already installed')) {
        Write-Error "Failed to install $DisplayName (package: $PackageName)."
        exit 1
    }
}

function Install-Chrome {
    Write-Host "Installing Google Chrome with Chocolatey..."
    $output = choco install googlechrome -y --no-progress 2>&1
    $exitCode = $LASTEXITCODE

    if ($output) {
        $output | ForEach-Object { Write-Host $_ }
    }

    if ($exitCode -eq 0 -or ($output -match 'already installed')) {
        return
    }

    if ($output -match 'Checksum' -or $output -match 'hashes do not match') {
        Write-Host "Retrying Google Chrome install with --ignore-checksums due upstream package checksum mismatch..."
        $retryOutput = choco install googlechrome -y --no-progress --ignore-checksums 2>&1
        $retryExitCode = $LASTEXITCODE

        if ($retryOutput) {
            $retryOutput | ForEach-Object { Write-Host $_ }
        }

        if ($retryExitCode -eq 0 -or ($retryOutput -match 'already installed')) {
            return
        }
    }

    Write-Error "Failed to install Google Chrome."
    exit 1
}

function Enable-WSL2 {
    $needsReboot = $false
    $validFeatureExitCodes = @(0, 3010, 1641)

    Write-Host "Enabling Windows features for WSL2..."
    $wslFeature = dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    if ($validFeatureExitCodes -notcontains $LASTEXITCODE) {
        Write-Error "Failed to enable Microsoft-Windows-Subsystem-Linux feature."
        exit 1
    }
    if ($LASTEXITCODE -ne 0) {
        $needsReboot = $true
    }

    $vmpFeature = dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    if ($validFeatureExitCodes -notcontains $LASTEXITCODE) {
        Write-Error "Failed to enable VirtualMachinePlatform feature."
        exit 1
    }
    if ($LASTEXITCODE -ne 0) {
        $needsReboot = $true
    }

    if (($wslFeature -join "`n") -match 'restart needed|restart required' -or ($vmpFeature -join "`n") -match 'restart needed|restart required') {
        $needsReboot = $true
    }

    try {
        wsl --set-default-version 2 | Out-Host
    } catch {
        Write-Host "Could not set WSL default version yet. This may succeed after reboot."
        $needsReboot = $true
    }

    try {
        wsl --install -d Ubuntu | Out-Host
    } catch {
        Write-Host "Ubuntu installation command did not complete. You can run it after reboot: wsl --install -d Ubuntu"
        $needsReboot = $true
    }

    if ($needsReboot) {
        Write-Host "WSL2 feature changes require a reboot. Reboot and rerun this script if needed."
    } else {
        Write-Host "WSL2 prerequisites were configured successfully."
    }
}

Install-Chocolatey
Enable-WSL2
Install-WithChocolatey -PackageName "vscode" -DisplayName "Visual Studio Code"
Install-Chrome

Write-Host "WSL2 + app setup completed."
Write-Host "If you rebooted, run: wsl -l -v to verify distro status."
