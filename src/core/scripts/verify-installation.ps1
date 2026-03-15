# Verify Docker CLI
try {
    $dockerVersion = docker --version
    Write-Host "Docker CLI detected: $dockerVersion"
} catch {
    Write-Host "Docker command not found. Installation is incomplete."
    exit 1
}

$os = Get-CimInstance Win32_OperatingSystem
$isServer = $os.ProductType -ne 1

if ($isServer) {
    $dockerService = Get-Service -Name "docker" -ErrorAction SilentlyContinue
    if (-not $dockerService) {
        Write-Host "Docker service is missing on this server."
        exit 1
    }

    if ($dockerService.Status -ne 'Running') {
        Write-Host "Docker service is not running."
        Write-Host "Try: sc.exe start docker"
        Write-Host "If start fails with vmcompute.dll error, reboot and retry."
        exit 1
    }
}

try {
    $serverVersion = docker version --format '{{.Server.Version}}'
    if ($serverVersion) {
        Write-Host "Docker daemon reachable. Server version: $serverVersion"
    }
} catch {
    Write-Host "Docker daemon is not reachable yet."
    if ($isServer) {
        Write-Host "On Windows Server, this is commonly fixed by rebooting after Containers feature install."
    } else {
        Write-Host "On client Windows, launch Docker Desktop and wait for the engine to start."
    }
    exit 1
}

Write-Host "Docker installation verified successfully."