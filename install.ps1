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
            
            # Download component scripts for package-managers module
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
        Write-ColorOutput "  NOTE: Scoop should be installed per-user, not system-wide" "Cyan"
        Write-ColorOutput "  RECOMMENDATION: Run as regular user for complete package manager installation" "Cyan"
    } else {
        Write-ColorOutput "  INFO: Regular user mode - optimal for package manager installation" "Green"
        Write-ColorOutput "  NOTE: Scoop will be installed per-user (recommended)" "Green"
    }
    
    # Create main setupx.ps1 entry point
    Write-ColorOutput "Creating main entry point..." "Magenta"
    $mainEntryPoint = @"
# SetupX Main Entry Point
# This is the main entry point for SetupX

# Import core modules
. "`$PSScriptRoot\utils\logger.ps1"
. "`$PSScriptRoot\core\module-manager.ps1"
. "`$PSScriptRoot\core\package-manager.ps1"

function Show-SetupxBanner {
    Write-Host ""
    Write-Host "SETUPX v2.0 - Modular Windows Development Setup" -ForegroundColor Cyan
    Write-Host ""
}

function Show-SetupxHelp {
    Show-SetupxBanner
    Write-Host "USAGE: setupx [command] [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "COMMANDS:" -ForegroundColor Yellow
    Write-Host "  -h, -help              Show this help message" -ForegroundColor White
    Write-Host "  list                   List all available modules" -ForegroundColor White
    Write-Host "  status                 Show system status" -ForegroundColor White
    Write-Host "  install [module]       Install a specific module" -ForegroundColor White
    Write-Host "  test [module]          Test module components" -ForegroundColor White
    Write-Host "  components [module]    List module components" -ForegroundColor White
    Write-Host "  menu                   Show interactive menu" -ForegroundColor White
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  setupx -h" -ForegroundColor White
    Write-Host "  setupx list" -ForegroundColor White
    Write-Host "  setupx install package-managers" -ForegroundColor White
    Write-Host "  setupx test package-managers" -ForegroundColor White
    Write-Host "  setupx components package-managers" -ForegroundColor White
    Write-Host ""
    Write-Host "PACKAGE MANAGERS:" -ForegroundColor Yellow
    Write-Host "  WinGet (Microsoft Official)" -ForegroundColor White
    Write-Host "  Chocolatey (Community)" -ForegroundColor White
    Write-Host "  Scoop (Portable Apps)" -ForegroundColor White
    Write-Host ""
}

function Show-SetupxList {
    Show-SetupxBanner
    Write-Host "Available Development Modules:" -ForegroundColor Yellow
    Write-Host ""
    
    `$modules = Get-AvailableModules
    if (`$modules.Count -eq 0) {
        Write-Host "Total modules: 0" -ForegroundColor Red
        Write-Host "No modules found. Check your installation." -ForegroundColor Yellow
    } else {
        foreach (`$module in `$modules) {
            Write-Host "Module: `$(`$module.DisplayName)" -ForegroundColor White
            Write-Host "  Description: `$(`$module.Description)" -ForegroundColor Gray
            Write-Host "  Components: `$(`$module.Components.Count)" -ForegroundColor Gray
            Write-Host ""
        }
        Write-Host "Total modules: `$(`$modules.Count)" -ForegroundColor Green
    }
}

function Show-SetupxStatus {
    Show-SetupxBanner
    Write-Host "System Status:" -ForegroundColor Yellow
    Write-Host ""
    
    # Show package manager status
    Show-PackageManagerStatus
    
    # Show module status
    `$modules = Get-AvailableModules
    Write-Host "Modules:" -ForegroundColor Yellow
    Write-Host "  Total modules: `$(`$modules.Count)" -ForegroundColor White
    Write-Host "  Configured modules: `$(`$modules.Count)" -ForegroundColor White
    Write-Host ""
}

function Show-SetupxComponents {
    param([string]`$ModuleName)
    
    if (-not `$ModuleName) {
        Write-Host "Module name required. Use: setupx components [module]" -ForegroundColor Red
        return
    }
    
    Show-SetupxBanner
    Write-Host "Components for module: `$ModuleName" -ForegroundColor Yellow
    Write-Host ""
    
    `$components = Get-ModuleComponents `$ModuleName
    if (`$components.Count -eq 0) {
        Write-Host "No components found for module: `$ModuleName" -ForegroundColor Red
    } else {
        foreach (`$component in `$components) {
            Write-Host "Component: `$(`$component.displayName)" -ForegroundColor White
            Write-Host "  Script: `$(`$component.scriptName)" -ForegroundColor Gray
            Write-Host ""
        }
        Write-Host "Total components: `$(`$components.Count)" -ForegroundColor Green
    }
}

function Show-SetupxMenu {
    Show-SetupxBanner
    Write-Host "Interactive SetupX Menu" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. List all modules" -ForegroundColor White
    Write-Host "2. Show system status" -ForegroundColor White
    Write-Host "3. Install package managers" -ForegroundColor White
    Write-Host "4. Install specific module" -ForegroundColor White
    Write-Host "5. Show help" -ForegroundColor White
    Write-Host "0. Exit" -ForegroundColor White
    Write-Host ""
    
    `$choice = Read-Host "Enter your choice (0-5)"
    
    switch (`$choice) {
        "1" { Show-SetupxList }
        "2" { Show-SetupxStatus }
        "3" { Install-Module "package-managers" }
        "4" {
            `$moduleName = Read-Host "Enter module name"
            Install-Module `$moduleName
        }
        "5" { Show-SetupxHelp }
        "0" { 
            Write-Host "Goodbye!" -ForegroundColor Green
            exit
        }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Show-SetupxMenu
        }
    }
}

# Handle commands
`$Command = `$args[0]
`$ModuleName = `$args[1]

switch (`$Command) {
    "-h" { Show-SetupxHelp }
    "-help" { Show-SetupxHelp }
    "help" { Show-SetupxHelp }
    "list" { Show-SetupxList }
    "status" { Show-SetupxStatus }
    "install" { Install-Module `$ModuleName }
    "test" { 
        if (`$ModuleName) {
            Write-Host "Testing module: `$ModuleName" -ForegroundColor Yellow
            # Add module testing logic here
        } else {
            Write-Host "Module name required for testing" -ForegroundColor Red
        }
    }
    "components" { Show-SetupxComponents `$ModuleName }
    "menu" { Show-SetupxMenu }
    default { 
        if (`$Command) {
            Write-Host "Unknown command: `$Command" -ForegroundColor Red
            Write-Host "Use 'setupx -h' for help" -ForegroundColor Yellow
        } else {
            Show-SetupxMenu
        }
    }
}
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
# Check for force parameter
$Force = $false
if ($args -contains "-Force" -or $args -contains "--force") {
    $Force = $true
}

Install-SetupxComplete -Force:$Force