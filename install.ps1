# SetupX Installation Script
# Installs SetupX to the system and adds it to PATH

param(
    [string]$InstallPath = "C:\tools\setupx",
    [switch]$Force = $false
)

# Check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Get the current script location
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "SetupX Installation Script" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if already installed
if (Test-Path $InstallPath -and -not $Force) {
    Write-Host "SetupX is already installed at: $InstallPath" -ForegroundColor Yellow
    $response = Read-Host "Do you want to reinstall? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "Installing SetupX to: $InstallPath" -ForegroundColor Green

try {
    # Create installation directory
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-Host "✓ Created installation directory" -ForegroundColor Green
    }

    # Copy all files to installation directory
    $sourcePath = $ScriptRoot
    $destinationPath = $InstallPath
    
    Write-Host "Copying files..." -ForegroundColor Yellow
    
    # Copy all files and folders
    Get-ChildItem -Path $sourcePath -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring($sourcePath.Length + 1)
        $destPath = Join-Path $destinationPath $relativePath
        
        if ($_.PSIsContainer) {
            if (-not (Test-Path $destPath)) {
                New-Item -ItemType Directory -Path $destPath -Force | Out-Null
            }
        } else {
            Copy-Item -Path $_.FullName -Destination $destPath -Force
        }
    }
    
    Write-Host "✓ Files copied successfully" -ForegroundColor Green

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
    Write-Host "✓ Created main entry point" -ForegroundColor Green

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
    Write-Host "✓ Created wsx alias" -ForegroundColor Green

    # Add to PATH
    Write-Host "Adding SetupX to PATH..." -ForegroundColor Yellow
    
    # Get current PATH
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    
    if ($currentPath -notlike "*$InstallPath*") {
        $newPath = $currentPath + ";" + $InstallPath
        [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "✓ Added to user PATH" -ForegroundColor Green
    } else {
        Write-Host "✓ Already in PATH" -ForegroundColor Green
    }

    # Update current session PATH
    $env:PATH += ";$InstallPath"
    Write-Host "✓ Updated current session PATH" -ForegroundColor Green

    # Test installation
    Write-Host "`nTesting installation..." -ForegroundColor Yellow
    
    $testScript = Join-Path $InstallPath "setupx.ps1"
    if (Test-Path $testScript) {
        try {
            $testResult = & $testScript version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Installation test successful" -ForegroundColor Green
            } else {
                Write-Host "⚠ Installation test had issues but files are in place" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "⚠ Installation test failed but files are in place" -ForegroundColor Yellow
        }
    }

    Write-Host "`n🎉 SetupX Installation Complete!" -ForegroundColor Green
    Write-Host "Installation path: $InstallPath" -ForegroundColor Cyan
    Write-Host "`nYou can now use SetupX with:" -ForegroundColor Yellow
    Write-Host "  setupx help" -ForegroundColor White
    Write-Host "  wsx help" -ForegroundColor White
    Write-Host "`nNote: You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Yellow

} catch {
    Write-Host "`n❌ Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check the error and try again." -ForegroundColor Yellow
    exit 1
}
