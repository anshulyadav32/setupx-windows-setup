# SetupX Complete Installer
# One script to install everything - modules, CLI, and dependencies

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Install-SetupxComplete {
    param([switch]$Force)
    
    Write-ColorOutput "`nSETUPX COMPLETE INSTALLER" "Cyan"
    Write-ColorOutput "Installing SetupX with all modules and dependencies..." "White"
    Write-ColorOutput ""
    
    # Check if running as Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    if ($isAdmin) {
        Write-ColorOutput "INFO: Running as Administrator" "Yellow"
        Write-ColorOutput "NOTE: Some package managers (like Scoop) work better as regular user" "Yellow"
        Write-ColorOutput "For best results, consider running as regular user for package manager installation" "Cyan"
        Write-ColorOutput ""
    } else {
        Write-ColorOutput "INFO: Running as regular user - optimal for package manager installation" "Green"
        Write-ColorOutput ""
    }
    
    $installPath = "C:\setupx"
    $tempDir = Join-Path $env:TEMP "setupx-install"
    
    # Check if C:\setupx already exists
    if (Test-Path $installPath) {
        if ($Force) {
            Write-ColorOutput "INFO: Force mode enabled - overwriting existing installation" "Yellow"
        } else {
            Write-ColorOutput "WARNING: SetupX already exists at $installPath" "Yellow"
            Write-ColorOutput "This will overwrite existing files. Continue? (y/N)" "Yellow"
            $response = Read-Host
            if ($response -ne "y" -and $response -ne "Y") {
                Write-ColorOutput "Installation cancelled." "Red"
                return
            }
        }
        Write-ColorOutput "Proceeding with installation..." "Green"
    }
    
    # Create temp directory
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    Write-ColorOutput "Downloading SetupX..." "Magenta"
    
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
            
            # Download component scripts for specific modules
            if ($module -eq "package-managers") {
                $componentsDir = Join-Path $moduleDir "components"
                if (-not (Test-Path $componentsDir)) {
                    New-Item -ItemType Directory -Path $componentsDir -Force | Out-Null
                }
                
                $componentScripts = @("chocolatey.ps1", "scoop.ps1", "winget.ps1", "npm.ps1")
                foreach ($script in $componentScripts) {
                    try {
                        $scriptUrl = $baseUrl + "src/modules/$module/$script"
                        $scriptPath = Join-Path $componentsDir $script
                        Invoke-RestMethod -Uri $scriptUrl -OutFile $scriptPath
                        Write-ColorOutput "    Downloaded $script" "Green"
                    } catch {
                        Write-ColorOutput "    WARNING: Failed to download $script" "Yellow"
                    }
                }
            }
            
            if ($module -eq "web-development") {
                $componentScripts = @("nodejs.ps1", "yarn.ps1", "browsers.ps1", "react-tools.ps1", "vue-tools.ps1", "angular-tools.ps1", "webpack-tools.ps1")
                foreach ($script in $componentScripts) {
                    try {
                        $scriptUrl = $baseUrl + "src/modules/$module/$script"
                        $scriptPath = Join-Path $moduleDir $script
                        Invoke-RestMethod -Uri $scriptUrl -OutFile $scriptPath
                        Write-ColorOutput "    Downloaded $script" "Green"
                    } catch {
                        Write-ColorOutput "    WARNING: Failed to download $script" "Yellow"
                    }
                }
            }
            
            Write-ColorOutput "    SUCCESS: $module module downloaded" "Green"
        } catch {
            Write-ColorOutput "    ERROR: Failed to download $module module - $($_.Exception.Message)" "Red"
        }
    }
    
    # Install SetupX
    Write-ColorOutput "Installing SetupX..." "Magenta"
    try {
        # Create installation directory if it doesn't exist
        if (-not (Test-Path $installPath)) {
            New-Item -ItemType Directory -Path $installPath -Force | Out-Null
            Write-ColorOutput "  SUCCESS: Created installation directory" "Green"
        } else {
            Write-ColorOutput "  INFO: Installation directory already exists" "Yellow"
        }
        
        # Copy all files from temp directory
        Write-ColorOutput "  Copying SetupX files..." "Yellow"
        Copy-Item -Path "$tempDir\*" -Destination $installPath -Recurse -Force
        Write-ColorOutput "  SUCCESS: SetupX files copied" "Green"
        
    } catch {
        Write-ColorOutput "  ERROR: Installation failed - $($_.Exception.Message)" "Red"
    }
    
    # Create components directory for package-managers
    Write-ColorOutput "Setting up component scripts..." "Magenta"
    $packageManagersDir = Join-Path $installPath "modules\package-managers"
    $componentsDir = Join-Path $packageManagersDir "components"
    
    if (-not (Test-Path $componentsDir)) {
        New-Item -ItemType Directory -Path $componentsDir -Force | Out-Null
        Write-ColorOutput "  SUCCESS: Created components directory" "Green"
    }
    
    # Copy component scripts from temp directory if they exist
    $tempComponentsDir = Join-Path $tempDir "src\modules\package-managers\components"
    if (Test-Path $tempComponentsDir) {
        Copy-Item -Path "$tempComponentsDir\*" -Destination $componentsDir -Force
        Write-ColorOutput "  SUCCESS: Copied component scripts" "Green"
    }
    
     # Handle package manager installation based on admin status
     Write-ColorOutput "Setting up package managers..." "Magenta"
     if ($isAdmin) {
         Write-ColorOutput "  INFO: Admin mode - Scoop installation will be skipped" "Yellow"
         Write-ColorOutput "  REASON: Scoop installation is disabled for Administrator users" "Cyan"
         Write-ColorOutput "  SOLUTION: Run as regular user to install Scoop properly" "Cyan"
         Write-ColorOutput "  ALTERNATIVE: Use 'setupx install package-managers' as regular user" "Cyan"
     } else {
         Write-ColorOutput "  INFO: Regular user mode - optimal for package manager installation" "Green"
         Write-ColorOutput "  NOTE: Scoop will install properly for regular users" "Green"
     }
    
    # Create main setupx.ps1 entry point
    Write-ColorOutput "Creating main entry point..." "Magenta"
    $mainEntryPoint = @"
# SetupX - Main Entry Point
# Modular Windows Development Environment Setup Tool

# Get the script directory
`$ScriptDir = Split-Path -Parent `$MyInvocation.MyCommand.Path

# Import the main CLI
. "`$ScriptDir\src\cli\setupx-cli.ps1" @args
"@
    
    $mainPath = Join-Path $installPath "setupx.ps1"
    Set-Content -Path $mainPath -Value $mainEntryPoint -Force
    Write-ColorOutput "  SUCCESS: Main entry point created" "Green"
    
     # Update setupx.cmd wrapper
     Write-ColorOutput "Updating command wrapper..." "Magenta"
     $cmdPath = Join-Path $installPath "setupx.cmd"
     $cmdContent = @"
@echo off
powershell -ExecutionPolicy Bypass -File "C:\setupx\setupx.ps1" %*
"@
     
     Set-Content -Path $cmdPath -Value $cmdContent -Force
     Write-ColorOutput "  SUCCESS: Command wrapper updated" "Green"
     
     # Add SetupX to system PATH
     Write-ColorOutput "Adding SetupX to system PATH..." "Magenta"
     try {
         $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
         if ($currentPath -notlike "*$installPath*") {
             [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$installPath", "Machine")
             Write-ColorOutput "  SUCCESS: Added SetupX to system PATH" "Green"
         } else {
             Write-ColorOutput "  INFO: SetupX already in system PATH" "Yellow"
         }
         
         # Refresh current session PATH
         $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine")
         Write-ColorOutput "  SUCCESS: Refreshed current session PATH" "Green"
     } catch {
         Write-ColorOutput "  WARNING: Could not update system PATH (may need admin privileges)" "Yellow"
         Write-ColorOutput "  NOTE: You can manually add C:\setupx to your PATH" "Cyan"
     }
    
    # Cleanup
    Write-ColorOutput "Cleaning up temporary files..." "Magenta"
    Remove-Item -Path $tempDir -Recurse -Force
    Write-ColorOutput "  SUCCESS: Cleanup completed" "Green"
    
    Write-ColorOutput "`nSetupX installation complete!" "Green"
    Write-ColorOutput "You can now use 'setupx' command from anywhere!" "White"
    Write-ColorOutput ""
    
    # Provide specific instructions based on admin status
    if ($isAdmin) {
        Write-ColorOutput "IMPORTANT: You ran this as Administrator" "Yellow"
        Write-ColorOutput "For best package manager experience, also run as regular user:" "Cyan"
        Write-ColorOutput "  1. Open PowerShell as regular user (not 'Run as Administrator')" "White"
        Write-ColorOutput "  2. Run: setupx install package-managers" "White"
        Write-ColorOutput "  3. This will install Scoop properly for regular user" "White"
        Write-ColorOutput ""
    }
    
    Write-ColorOutput "Test your installation:" "Cyan"
    Write-ColorOutput "  setupx -h          # Show help" "White"
    Write-ColorOutput "  setupx list        # List modules" "White"
    Write-ColorOutput "  setupx status      # Show status" "White"
    Write-ColorOutput "  setupx menu        # Interactive menu" "White"
    Write-ColorOutput "  setupx install package-managers  # Install package managers" "White"
}

# Execute installation
# Check for force parameter from command line or pipeline
$Force = $false

# Check command line arguments
if ($args -contains "-Force" -or $args -contains "--force") {
    $Force = $true
}

# Check if script was called with -Force parameter
if ($MyInvocation.Line -like "*-Force*") {
    $Force = $true
}

# Check for force parameter in the calling context
if ($PSBoundParameters.ContainsKey('Force')) {
    $Force = $PSBoundParameters.Force
}

Install-SetupxComplete -Force:$Force