# SetupX Modular Auto-Install
# Downloads and installs SetupX with modular structure

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Install-SetupxModular {
    Write-ColorOutput "`nSETUPX MODULAR INSTALLER" "Cyan"
    Write-ColorOutput "Installing SetupX with modular structure..." "White"
    Write-ColorOutput ""
    
    $installPath = "C:\setupx"
    $tempDir = Join-Path $env:TEMP "setupx-modular"
    
    # Create temp directory
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    Write-ColorOutput "Downloading SetupX modular structure..." "Magenta"
    
    # Download main files
    $files = @(
        "setupx.ps1",
        "src/utils/logger.ps1",
        "src/utils/helpers.ps1", 
        "src/core/module-manager.ps1",
        "src/core/package-manager.ps1",
        "src/cli/setupx-cli.ps1",
        "src/config/setupx.json",
        "src/installers/setupx-installer.ps1"
    )
    
    $baseUrl = "https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/"
    
    foreach ($file in $files) {
        try {
            Write-ColorOutput "  Downloading $file..." "Yellow"
            $url = $baseUrl + $file
            $localPath = Join-Path $tempDir $file
            $fileDir = Split-Path $localPath -Parent
            
            if (-not (Test-Path $fileDir)) {
                New-Item -ItemType Directory -Path $fileDir -Force | Out-Null
            }
            
            Invoke-RestMethod -Uri $url -OutFile $localPath
            Write-ColorOutput "    SUCCESS: $file downloaded" "Green"
        } catch {
            Write-ColorOutput "    ERROR: Failed to download $file - $($_.Exception.Message)" "Red"
        }
    }
    
    # Download modules
    Write-ColorOutput "Downloading SetupX modules..." "Magenta"
    $modules = @(
        "package-managers",
        "web-development", 
        "mobile-development",
        "backend-development",
        "cloud-development",
        "common-development"
    )
    
    foreach ($module in $modules) {
        try {
            Write-ColorOutput "  Downloading $module module..." "Yellow"
            $moduleDir = Join-Path $tempDir "src\modules\$module"
            if (-not (Test-Path $moduleDir)) {
                New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null
            }
            
            # Download module.json
            $moduleJsonUrl = $baseUrl + "src/modules/$module/module.json"
            $moduleJsonPath = Join-Path $moduleDir "module.json"
            Invoke-RestMethod -Uri $moduleJsonUrl -OutFile $moduleJsonPath
            
            Write-ColorOutput "    SUCCESS: $module module downloaded" "Green"
        } catch {
            Write-ColorOutput "    ERROR: Failed to download $module module - $($_.Exception.Message)" "Red"
        }
    }
    
    # Install SetupX
    Write-ColorOutput "Installing SetupX..." "Magenta"
    try {
        $installerPath = Join-Path $tempDir "src\installers\setupx-installer.ps1"
        if (Test-Path $installerPath) {
            . $installerPath
            Install-Setupx -InstallPath $installPath
        } else {
            Write-ColorOutput "  ERROR: Installer not found" "Red"
        }
    } catch {
        Write-ColorOutput "  ERROR: Installation failed - $($_.Exception.Message)" "Red"
    }
    
    # Cleanup
    Write-ColorOutput "Cleaning up temporary files..." "Magenta"
    Remove-Item -Path $tempDir -Recurse -Force
    Write-ColorOutput "  SUCCESS: Cleanup completed" "Green"
    
    Write-ColorOutput "`nSetupX Modular Installation Complete!" "Green"
    Write-ColorOutput "You can now use 'setupx' command from anywhere!" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Test your installation:" "Cyan"
    Write-ColorOutput "  setupx -h          # Show help" "White"
    Write-ColorOutput "  setupx list        # List modules" "White"
    Write-ColorOutput "  setupx status      # Show status" "White"
    Write-ColorOutput "  setupx menu        # Interactive menu" "White"
}

# Execute installation
Install-SetupxModular
