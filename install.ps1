# SetupX Installation Script
# Installs SetupX to the system and adds it to PATH

param(
    [string]$InstallPath = "C:\tools\setupx",
    [switch]$Force = $false
)

$RepoOwner = "anshulyadav-git"
$RepoName = "setupx-windows-setup"
$RepoBranch = "main"

function Get-InstallSourcePath {
    <#
    .SYNOPSIS
    Resolves source files for installation when running locally or via iwr|iex.
    #>
    param(
        [string]$PreferredRoot
    )

    $localRoot = $null
    if ($PreferredRoot -and (Test-Path -LiteralPath $PreferredRoot)) {
        $localRoot = $PreferredRoot
    }

    if (-not $localRoot -and $PSScriptRoot -and (Test-Path -LiteralPath $PSScriptRoot)) {
        $localRoot = $PSScriptRoot
    }

    if ($localRoot -and (Test-Path -LiteralPath (Join-Path $localRoot "setupx.ps1")) -and (Test-Path -LiteralPath (Join-Path $localRoot "src"))) {
        Write-Host "Using local source: $localRoot" -ForegroundColor Gray
        return [PSCustomObject]@{
            SourcePath = $localRoot
            TempPath = $null
        }
    }

    # Fallback for one-line installs: download the repository archive.
    $tempRoot = Join-Path $env:TEMP ("setupx-install-" + [guid]::NewGuid().ToString("N"))
    $zipPath = Join-Path $tempRoot "setupx.zip"
    $extractPath = Join-Path $tempRoot "extract"
    $zipUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$RepoBranch.zip"

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null

    Write-Host "Downloading SetupX source archive..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

    Write-Host "Extracting source archive..." -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    $sourcePath = Join-Path $extractPath "$RepoName-$RepoBranch"
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Could not locate extracted source folder: $sourcePath"
    }

    Write-Host "Using downloaded source: $sourcePath" -ForegroundColor Gray
    return [PSCustomObject]@{
        SourcePath = $sourcePath
        TempPath = $tempRoot
    }
}

# Check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Get the current script location (works for local script execution)
$ScriptRoot = $null
try {
    if ($MyInvocation.MyCommand.Path) {
        $ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
}
catch {
    $ScriptRoot = $null
}

Write-Host "SetupX Installation Script" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if already installed
if ((Test-Path -LiteralPath $InstallPath) -and (-not $Force)) {
    Write-Host "SetupX is already installed at: $InstallPath" -ForegroundColor Yellow
    $response = Read-Host "Do you want to reinstall? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "Installing SetupX to: $InstallPath" -ForegroundColor Green

try {
    $sourceInfo = Get-InstallSourcePath -PreferredRoot $ScriptRoot
    $sourcePath = $sourceInfo.SourcePath

    # Create installation directory
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-Host "[OK] Created installation directory" -ForegroundColor Green
    }

    # Copy all files to installation directory
    $destinationPath = $InstallPath

    Write-Host "Copying files..." -ForegroundColor Yellow

    # Copy all files and folders from source to destination.
    Copy-Item -Path (Join-Path $sourcePath "*") -Destination $destinationPath -Recurse -Force

    Write-Host "[OK] Files copied successfully" -ForegroundColor Green

    # Create setupx.ps1 in installation directory (main entry point)
    $setupxContent = @"
# SetupX Main Entry Point
# This file is the main entry point for SetupX

param(
    [Parameter(Position=0)]
    [string]`$Command,
    
    [Parameter(Position=1, ValueFromRemainingArguments=`$true)]
    [string[]]`$Arguments
)

# Set the script root to the installation directory
`$PSScriptRoot = Split-Path -Parent `$MyInvocation.MyCommand.Definition

# Import core modules
. "`$PSScriptRoot\src\utils\logger.ps1"
. "`$PSScriptRoot\src\utils\helpers.ps1"
. "`$PSScriptRoot\src\core\engine.ps1"
. "`$PSScriptRoot\src\core\json-loader.ps1"

# Call the main setupx.ps1 with all arguments
`$mainScriptPath = Join-Path `$PSScriptRoot "setupx.ps1"

if (Test-Path `$mainScriptPath) {
    & `$mainScriptPath `$Command @Arguments
} else {
    Write-Host "Error: setupx.ps1 not found in `$PSScriptRoot" -ForegroundColor Red
    Write-Host "Please ensure SetupX is properly installed." -ForegroundColor Yellow
}
"@

    $setupxPath = Join-Path $InstallPath "setupx.ps1"
    $setupxContent | Out-File -FilePath $setupxPath -Encoding UTF8
    Write-Host "[OK] Created main entry point" -ForegroundColor Green

    # Create wsx.ps1 alias
    $wsxContent = @"
# WSX - Alias for SetupX CLI
# This is a shorter alternative command name for SetupX

param(
    [Parameter(Position=0)]
    [string]`$Command,
    
    [Parameter(Position=1, ValueFromRemainingArguments=`$true)]
    [string[]]`$Arguments
)

# Call the main SetupX CLI with all arguments
`$setupxPath = Join-Path `$PSScriptRoot "setupx.ps1"

if (Test-Path `$setupxPath) {
    & `$setupxPath `$Command @Arguments
} else {
    Write-Host "Error: setupx.ps1 not found in `$PSScriptRoot" -ForegroundColor Red
    Write-Host "Please ensure SetupX is properly installed." -ForegroundColor Yellow
}
"@

    $wsxPath = Join-Path $InstallPath "wsx.ps1"
    $wsxContent | Out-File -FilePath $wsxPath -Encoding UTF8
    Write-Host "[OK] Created wsx alias" -ForegroundColor Green

    # Create sx.ps1 alias (preferred short command)
    $sxContent = @"
# SX - Preferred short alias for SetupX CLI

param(
    [Parameter(Position=0)]
    [string]`$Command,

    [Parameter(Position=1, ValueFromRemainingArguments=`$true)]
    [string[]]`$Arguments
)

`$setupxPath = Join-Path `$PSScriptRoot "setupx.ps1"

if (Test-Path `$setupxPath) {
    & `$setupxPath `$Command @Arguments
} else {
    Write-Host "Error: setupx.ps1 not found in `$PSScriptRoot" -ForegroundColor Red
    Write-Host "Please ensure SetupX is properly installed." -ForegroundColor Yellow
}
"@

    $sxPath = Join-Path $InstallPath "sx.ps1"
    $sxContent | Out-File -FilePath $sxPath -Encoding UTF8
    Write-Host "[OK] Created sx alias" -ForegroundColor Green

    # Add to PATH
    Write-Host "Adding SetupX to PATH..." -ForegroundColor Yellow
    
    # Get current PATH
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    
    if ($currentPath -notlike "*$InstallPath*") {
        $newPath = $currentPath + ";" + $InstallPath
        [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "[OK] Added to user PATH" -ForegroundColor Green
    } else {
        Write-Host "[OK] Already in PATH" -ForegroundColor Green
    }

    # Update current session PATH
    $env:PATH += ";$InstallPath"
    Write-Host "[OK] Updated current session PATH" -ForegroundColor Green

    # Test installation
    Write-Host "`nTesting installation..." -ForegroundColor Yellow
    
    $testScript = Join-Path $InstallPath "setupx.ps1"
    if (Test-Path $testScript) {
        try {
            & $testScript version 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[OK] Installation test successful" -ForegroundColor Green
            } else {
                Write-Host "[WARN] Installation test had issues but files are in place" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "[WARN] Installation test failed but files are in place" -ForegroundColor Yellow
        }
    }

    Write-Host "`nSetupX Installation Complete!" -ForegroundColor Green
    Write-Host "Installation path: $InstallPath" -ForegroundColor Cyan
    Write-Host "`nYou can now use SetupX with:" -ForegroundColor Yellow
    Write-Host "  sx help" -ForegroundColor White
    Write-Host "  setupx help" -ForegroundColor White
    Write-Host "  wsx help" -ForegroundColor White
    Write-Host "`nNote: You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Yellow

    if ($sourceInfo.TempPath -and (Test-Path -LiteralPath $sourceInfo.TempPath)) {
        Remove-Item -Path $sourceInfo.TempPath -Recurse -Force -ErrorAction SilentlyContinue
    }

} catch {
    Write-Host "`n[ERROR] Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check the error and try again." -ForegroundColor Yellow
    exit 1
}
