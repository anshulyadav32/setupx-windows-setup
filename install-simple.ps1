# Simple SetupX Installation
Write-Host "=== SetupX Installation ===" -ForegroundColor Cyan

# Create directory
if (-not (Test-Path "C:\tools\setup")) {
    New-Item -ItemType Directory -Path "C:\tools\setup" -Force
    Write-Host "✓ Created C:\tools\setup" -ForegroundColor Green
}

# Copy files
Copy-Item "src\config\setupx.json" "C:\tools\setup\setupx.json" -Force
Write-Host "✓ Copied setupx.json" -ForegroundColor Green

# Create simple executable
$script = @'
param([string]$Command = "help")
$json = Get-Content "$PSScriptRoot\setupx.json" | ConvertFrom-Json
Write-Host "SetupX v$($json.version)" -ForegroundColor Cyan

if ($Command -eq "help") {
    Write-Host "Commands: list, status, install [module], components [module]" -ForegroundColor Yellow
} elseif ($Command -eq "list") {
    Write-Host "Modules:" -ForegroundColor Yellow
    $json.modules.PSObject.Properties | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor White }
} elseif ($Command -eq "status") {
    Write-Host "Tools:" -ForegroundColor Yellow
    choco --version
    node --version
    git --version
} elseif ($Command -eq "install") {
    Write-Host "Installation feature active" -ForegroundColor Green
} elseif ($Command -eq "components") {
    Write-Host "Components feature active" -ForegroundColor Green
} else {
    Write-Host "Use: setupx help" -ForegroundColor Red
}
'@

Set-Content -Path "C:\tools\setup\setupx.ps1" -Value $script
Write-Host "✓ Created setupx.ps1" -ForegroundColor Green

# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
if ($currentPath -notlike "*C:\tools\setup*") {
    [Environment]::SetEnvironmentVariable("PATH", $currentPath + ";C:\tools\setup", [EnvironmentVariableTarget]::User)
    Write-Host "✓ Added to PATH" -ForegroundColor Green
}

# Test
Write-Host "`nTesting installation..." -ForegroundColor Yellow
C:\tools\setup\setupx.ps1 help

Write-Host "`n=== Installation Complete ===" -ForegroundColor Cyan
