# Run as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

# Install Chocolatey if not installed
if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

$os = Get-CimInstance Win32_OperatingSystem
$isServer = $os.ProductType -ne 1
$needsReboot = $false

if ($isServer) {
    Write-Host "Windows Server detected. Installing Docker Engine package..."

    $containersFeature = Get-WindowsFeature -Name Containers
    if ($containersFeature.InstallState -ne 'Installed') {
        Write-Host "Installing Windows feature: Containers..."
        $featureResult = Install-WindowsFeature -Name Containers
        if ($featureResult.RestartNeeded -eq 'Yes') {
            $needsReboot = $true
        }
    }

    choco install docker-engine -y --no-progress
} else {
    Write-Host "Client Windows detected. Installing Docker Desktop package..."
    choco install docker-desktop -y --no-progress
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker package installation failed. Check C:\ProgramData\chocolatey\logs\chocolatey.log"
    exit 1
}

if ($isServer) {
    Write-Host "Attempting to start Docker service..."
    sc.exe start docker | Out-Null
    Start-Sleep -Seconds 2

    $dockerService = Get-Service -Name docker -ErrorAction SilentlyContinue
    if ($dockerService -and $dockerService.Status -eq 'Running') {
        Write-Host "Docker Engine is running."
    } else {
        Write-Host "Docker Engine installed, but service is not running yet."
        Write-Host "A reboot is typically required after enabling Containers."
        $needsReboot = $true
    }
}

if ($needsReboot) {
    Write-Host "Installation completed. Reboot this machine, then run scripts\verify-installation.ps1"
} else {
    Write-Host "Installation completed. Run scripts\verify-installation.ps1 to validate setup."
}