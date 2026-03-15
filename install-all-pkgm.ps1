# SetupX One-Script Installer for All Package Managers
# Installs SetupX, then installs all package managers via: setupx pgkm

param(
    [string]$InstallPath = "C:\tools\setupx",
    [switch]$Force = $true
)

$RepoOwner = "anshulyadav-git"
$RepoName = "setupx-windows-setup"
$RepoBranch = "main"


$installScriptPath = $null
if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $installScriptPath = Join-Path $PSScriptRoot "install.ps1"
}

Write-Host "SetupX All Package Managers Installer" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

try {
    if ($installScriptPath -and (Test-Path -LiteralPath $installScriptPath)) {
        Write-Host "Using local install.ps1" -ForegroundColor Gray
        & $installScriptPath -InstallPath $InstallPath -Force:$Force
    }
    else {
        Write-Host "Local install.ps1 not found. Downloading installer..." -ForegroundColor Yellow
        $installUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$RepoBranch/install.ps1"
        $installBody = Invoke-RestMethod -Uri $installUrl
        $installBlock = [ScriptBlock]::Create($installBody)
        & $installBlock -InstallPath $InstallPath -Force:$Force
    }


    $setupxPath = Join-Path $InstallPath "setupx.ps1"
    if (-not (Test-Path -LiteralPath $setupxPath)) {
        throw "setupx.ps1 was not found after installation at $setupxPath"
    }

    # Ensure current process can resolve setupx in case PATH has not refreshed.

    if ($env:PATH -notlike "*$InstallPath*") {
        $env:PATH = "$env:PATH;$InstallPath"
    }


    Write-Host ""
    Write-Host "Installing all package managers (setupx pgkm)..." -ForegroundColor Cyan
    & $setupxPath pgkm


    if ($LASTEXITCODE -ne 0) {
        throw "setupx pgkm exited with code $LASTEXITCODE"
    }

    Write-Host ""
    Write-Host "All package manager installation flow completed." -ForegroundColor Green

    Write-Host "\nRefreshing environment variables (refreshenv)..." -ForegroundColor Yellow
    try {
        refreshenv
        Write-Host "Environment variables refreshed. You may need to restart your terminal for all changes to take effect." -ForegroundColor Yellow
    } catch {
        Write-Host "refreshenv command not found. Please restart your terminal to ensure all environment changes are applied." -ForegroundColor Red
    }
}
catch {
    Write-Host "" 
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
