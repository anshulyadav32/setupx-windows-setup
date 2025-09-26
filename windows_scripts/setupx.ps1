#!/usr/bin/env powershell
# SETUPX - Modular Windows Development Environment Setup
# Main Command Line Interface
# Version: 2.0

param(
    [string]$Action = "help",
    [string]$Module = "",
    [string]$Component = "",
    [switch]$Help,
    [switch]$Verbose
)

# Global Configuration
$Global:SetupxConfig = @{
    ScriptRoot = $PSScriptRoot
    ModulesPath = Join-Path $PSScriptRoot "modules"
    LogPath = Join-Path $PSScriptRoot "logs"
    Verbose = $Verbose
}

# Color Configuration
$Global:SetupxColors = @{
    Primary = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Secondary = "Magenta"
    Dim = "Gray"
}

# Ensure logs directory exists
if (!(Test-Path $Global:SetupxConfig.LogPath)) {
    New-Item -ItemType Directory -Path $Global:SetupxConfig.LogPath -Force | Out-Null
}

# Core Functions
function Write-SetupxOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline,
        [switch]$Timestamp
    )
    
    $timestamp = if ($Timestamp) { "[$(Get-Date -Format 'HH:mm:ss')] " } else { "" }
    $fullMessage = "$timestamp$Message"
    
    if ($NoNewline) {
        Write-Host $fullMessage -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $fullMessage -ForegroundColor $Color
    }
    
    # Log to file if verbose
    if ($Global:SetupxConfig.Verbose) {
        Add-Content -Path (Join-Path $Global:SetupxConfig.LogPath "setupx.log") -Value $fullMessage
    }
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-AvailableModules {
    $modules = @()
    if (Test-Path $Global:SetupxConfig.ModulesPath) {
        $moduleDirectories = Get-ChildItem -Path $Global:SetupxConfig.ModulesPath -Directory
        foreach ($moduleDir in $moduleDirectories) {
            $configPath = Join-Path $moduleDir.FullName "module.json"
            $moduleInfo = @{
                Name = $moduleDir.Name
                Path = $moduleDir.FullName
                ConfigPath = $configPath
                HasConfig = Test-Path $configPath
            }
            
            if ($moduleInfo.HasConfig) {
                try {
                    $config = Get-Content $configPath -Raw | ConvertFrom-Json
                    $moduleInfo.Description = $config.description
                    $moduleInfo.Components = $config.components
                    $moduleInfo.Version = $config.version
                }
                catch {
                    $moduleInfo.Description = "Configuration error"
                    $moduleInfo.Components = @()
                }
            }
            else {
                $moduleInfo.Description = "No configuration found"
                $moduleInfo.Components = @()
            }
            
            $modules += $moduleInfo
        }
    }
    return $modules
}

function Get-PackageManagers {
    $managers = @()
    
    # Check WinGet
    try {
        $wingetVersion = winget --version 2>$null
        if ($wingetVersion) {
            $managers += @{
                Name = "WinGet"
                Available = $true
                Version = $wingetVersion
                Type = "Microsoft Official"
            }
        }
    }
    catch {
        $managers += @{
            Name = "WinGet"
            Available = $false
            Version = "Not installed"
            Type = "Microsoft Official"
        }
    }
    
    # Check Chocolatey
    try {
        $chocoVersion = choco --version 2>$null
        if ($chocoVersion) {
            $managers += @{
                Name = "Chocolatey"
                Available = $true
                Version = $chocoVersion
                Type = "Community"
            }
        }
    }
    catch {
        $managers += @{
            Name = "Chocolatey"
            Available = $false
            Version = "Not installed"
            Type = "Community"
        }
    }
    
    # Check Scoop
    try {
        $scoopVersion = scoop --version 2>$null
        if ($scoopVersion) {
            $managers += @{
                Name = "Scoop"
                Available = $true
                Version = $scoopVersion
                Type = "Portable"
            }
        }
    }
    catch {
        $managers += @{
            Name = "Scoop"
            Available = $false
            Version = "Not installed"
            Type = "Portable"
        }
    }
    
    return $managers
}

function Test-Component {
    param(
        [string]$ComponentName,
        [string]$TestCommand,
        [string]$TestPath
    )
    
    $result = @{
        Name = $ComponentName
        Installed = $false
        Version = "Unknown"
        TestMethod = "Unknown"
        Error = $null
    }
    
    # Test by command
    if ($TestCommand) {
        try {
            $output = Invoke-Expression $TestCommand 2>$null
            if ($LASTEXITCODE -eq 0 -or $output) {
                $result.Installed = $true
                $result.Version = $output
                $result.TestMethod = "Command"
            }
        }
        catch {
            $result.Error = $_.Exception.Message
        }
    }
    
    # Test by path
    if (!$result.Installed -and $TestPath) {
        if (Test-Path $TestPath) {
            $result.Installed = $true
            $result.TestMethod = "Path"
        }
    }
    
    return $result
}

function Install-Component {
    param(
        [string]$ComponentName,
        [string]$PackageName,
        [string]$PackageManager = "winget"
    )
    
    Write-SetupxOutput "Installing $ComponentName using $PackageManager..." $Global:SetupxColors.Info
    
    try {
        switch ($PackageManager.ToLower()) {
            "winget" {
                winget install $PackageName --accept-package-agreements --accept-source-agreements
            }
            "choco" {
                choco install $PackageName -y
            }
            "scoop" {
                scoop install $PackageName
            }
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-SetupxOutput "✅ $ComponentName installed successfully!" $Global:SetupxColors.Success
            return $true
        }
        else {
            Write-SetupxOutput "❌ Failed to install $ComponentName" $Global:SetupxColors.Error
            return $false
        }
    }
    catch {
        Write-SetupxOutput "❌ Error installing $ComponentName: $($_.Exception.Message)" $Global:SetupxColors.Error
        return $false
    }
}

function Show-Banner {
    Write-SetupxOutput ""
    Write-SetupxOutput "╔══════════════════════════════════════════════════════════════╗" $Global:SetupxColors.Primary
    Write-SetupxOutput "║                    SETUPX v2.0                              ║" $Global:SetupxColors.Primary
    Write-SetupxOutput "║              Modular Windows Development Setup               ║" $Global:SetupxColors.Primary
    Write-SetupxOutput "╚══════════════════════════════════════════════════════════════╝" $Global:SetupxColors.Primary
    Write-SetupxOutput ""
}

function Show-Help {
    Show-Banner
    Write-SetupxOutput "USAGE:" $Global:SetupxColors.Secondary
    Write-SetupxOutput "  setupx [command] [options]" $Global:SetupxColors.Info
    Write-SetupxOutput ""
    Write-SetupxOutput "COMMANDS:" $Global:SetupxColors.Secondary
    Write-SetupxOutput "  -h, -help              Show this help message" $Global:SetupxColors.Info
    Write-SetupxOutput "  list                    List all available modules" $Global:SetupxColors.Info
    Write-SetupxOutput "  status                  Show system status" $Global:SetupxColors.Info
    Write-SetupxOutput "  install <module>        Install a specific module" $Global:SetupxColors.Info
    Write-SetupxOutput "  test <module>           Test module components" $Global:SetupxColors.Info
    Write-SetupxOutput "  components <module>     List module components" $Global:SetupxColors.Info
    Write-SetupxOutput "  menu                    Show interactive menu" $Global:SetupxColors.Info
    Write-SetupxOutput ""
    Write-SetupxOutput "EXAMPLES:" $Global:SetupxColors.Secondary
    Write-SetupxOutput "  setupx -h" $Global:SetupxColors.Info
    Write-SetupxOutput "  setupx list" $Global:SetupxColors.Info
    Write-SetupxOutput "  setupx install package-managers" $Global:SetupxColors.Info
    Write-SetupxOutput "  setupx test package-managers" $Global:SetupxColors.Info
    Write-SetupxOutput "  setupx components package-managers" $Global:SetupxColors.Info
    Write-SetupxOutput ""
    Write-SetupxOutput "PACKAGE MANAGERS:" $Global:SetupxColors.Secondary
    Write-SetupxOutput "  • WinGet (Microsoft Official)" $Global:SetupxColors.Info
    Write-SetupxOutput "  • Chocolatey (Community)" $Global:SetupxColors.Info
    Write-SetupxOutput "  • Scoop (Portable Apps)" $Global:SetupxColors.Info
}

function Show-ModuleList {
    Show-Banner
    Write-SetupxOutput "📦 Available Development Modules:" $Global:SetupxColors.Secondary
    Write-SetupxOutput ""
    
    $modules = Get-AvailableModules
    foreach ($module in $modules) {
        $status = if ($module.HasConfig) { "✅" } else { "⚠️" }
        Write-SetupxOutput "  $status $($module.Name)" $Global:SetupxColors.Info
        Write-SetupxOutput "     Description: $($module.Description)" $Global:SetupxColors.Dim
        Write-SetupxOutput "     Components: $($module.Components.Count)" $Global:SetupxColors.Dim
        Write-SetupxOutput ""
    }
    
    Write-SetupxOutput "Total modules: $($modules.Count)" $Global:SetupxColors.Secondary
}

function Show-SystemStatus {
    Show-Banner
    Write-SetupxOutput "📊 System Status:" $Global:SetupxColors.Secondary
    Write-SetupxOutput ""
    
    # Administrator check
    $isAdmin = Test-Administrator
    $adminStatus = if ($isAdmin) { "✅ Administrator" } else { "⚠️ Standard User" }
    Write-SetupxOutput "  $adminStatus" $Global:SetupxColors.Info
    
    # Package managers
    Write-SetupxOutput ""
    Write-SetupxOutput "🔧 Package Managers:" $Global:SetupxColors.Secondary
    $managers = Get-PackageManagers
    foreach ($manager in $managers) {
        $status = if ($manager.Available) { "✅" } else { "❌" }
        Write-SetupxOutput "  $status $($manager.Name) ($($manager.Type))" $Global:SetupxColors.Info
        Write-SetupxOutput "     Version: $($manager.Version)" $Global:SetupxColors.Dim
    }
    
    # Modules
    Write-SetupxOutput ""
    Write-SetupxOutput "📦 Modules:" $Global:SetupxColors.Secondary
    $modules = Get-AvailableModules
    $configuredModules = ($modules | Where-Object { $_.HasConfig }).Count
    Write-SetupxOutput "  Total modules: $($modules.Count)" $Global:SetupxColors.Info
    Write-SetupxOutput "  Configured modules: $configuredModules" $Global:SetupxColors.Info
}

function Show-ModuleComponents {
    param([string]$ModuleName)
    
    if (!$ModuleName) {
        Write-SetupxOutput "❌ Module name required. Use: setupx components <module>" $Global:SetupxColors.Error
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-SetupxOutput "❌ Module '$ModuleName' not found" $Global:SetupxColors.Error
        return
    }
    
    Show-Banner
    Write-SetupxOutput "🔧 Components in '$ModuleName' module:" $Global:SetupxColors.Secondary
    Write-SetupxOutput ""
    
    if ($module.Components) {
        foreach ($component in $module.Components) {
            Write-SetupxOutput "  • $($component.name)" $Global:SetupxColors.Info
            Write-SetupxOutput "    Description: $($component.description)" $Global:SetupxColors.Dim
            Write-SetupxOutput "    Package: $($component.package)" $Global:SetupxColors.Dim
            Write-SetupxOutput ""
        }
    }
    else {
        Write-SetupxOutput "  No components configured" $Global:SetupxColors.Warning
    }
}

function Test-ModuleComponents {
    param([string]$ModuleName)
    
    if (!$ModuleName) {
        Write-SetupxOutput "❌ Module name required. Use: setupx test <module>" $Global:SetupxColors.Error
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-SetupxOutput "❌ Module '$ModuleName' not found" $Global:SetupxColors.Error
        return
    }
    
    Show-Banner
    Write-SetupxOutput "🧪 Testing components in '$ModuleName' module:" $Global:SetupxColors.Secondary
    Write-SetupxOutput ""
    
    if ($module.Components) {
        $totalComponents = $module.Components.Count
        $installedComponents = 0
        
        foreach ($component in $module.Components) {
            Write-SetupxOutput "Testing $($component.name)..." $Global:SetupxColors.Info -NoNewline
            
            $testResult = Test-Component -ComponentName $component.name -TestCommand $component.testCommand -TestPath $component.testPath
            
            if ($testResult.Installed) {
                Write-SetupxOutput " ✅ INSTALLED" $Global:SetupxColors.Success
                $installedComponents++
            }
            else {
                Write-SetupxOutput " ❌ NOT INSTALLED" $Global:SetupxColors.Error
            }
        }
        
        Write-SetupxOutput ""
        Write-SetupxOutput "📊 Test Results:" $Global:SetupxColors.Secondary
        Write-SetupxOutput "  Installed: $installedComponents/$totalComponents" $Global:SetupxColors.Info
        $percentage = [math]::Round(($installedComponents / $totalComponents) * 100, 1)
        Write-SetupxOutput "  Completion: $percentage%" $Global:SetupxColors.Info
    }
    else {
        Write-SetupxOutput "  No components to test" $Global:SetupxColors.Warning
    }
}

function Install-Module {
    param([string]$ModuleName)
    
    if (!$ModuleName) {
        Write-SetupxOutput "❌ Module name required. Use: setupx install <module>" $Global:SetupxColors.Error
        return
    }
    
    $modules = Get-AvailableModules
    $module = $modules | Where-Object { $_.Name -eq $ModuleName }
    
    if (!$module) {
        Write-SetupxOutput "❌ Module '$ModuleName' not found" $Global:SetupxColors.Error
        return
    }
    
    Show-Banner
    Write-SetupxOutput "🚀 Installing '$ModuleName' module:" $Global:SetupxColors.Secondary
    Write-SetupxOutput ""
    
    if ($module.Components) {
        $totalComponents = $module.Components.Count
        $installedComponents = 0
        
        foreach ($component in $module.Components) {
            Write-SetupxOutput "Installing $($component.name)..." $Global:SetupxColors.Info
            
            $success = Install-Component -ComponentName $component.name -PackageName $component.package -PackageManager $component.manager
            
            if ($success) {
                $installedComponents++
            }
        }
        
        Write-SetupxOutput ""
        Write-SetupxOutput "📊 Installation Results:" $Global:SetupxColors.Secondary
        Write-SetupxOutput "  Successfully installed: $installedComponents/$totalComponents" $Global:SetupxColors.Info
    }
    else {
        Write-SetupxOutput "  No components to install" $Global:SetupxColors.Warning
    }
}

function Show-InteractiveMenu {
    Show-Banner
    Write-SetupxOutput "🎯 Interactive Menu:" $Global:SetupxColors.Secondary
    Write-SetupxOutput ""
    Write-SetupxOutput "1. List all modules" $Global:SetupxColors.Info
    Write-SetupxOutput "2. Show system status" $Global:SetupxColors.Info
    Write-SetupxOutput "3. Install module" $Global:SetupxColors.Info
    Write-SetupxOutput "4. Test module components" $Global:SetupxColors.Info
    Write-SetupxOutput "5. Show module components" $Global:SetupxColors.Info
    Write-SetupxOutput "6. Exit" $Global:SetupxColors.Info
    Write-SetupxOutput ""
    
    $choice = Read-Host "Select option (1-6)"
    
    switch ($choice) {
        "1" { Show-ModuleList }
        "2" { Show-SystemStatus }
        "3" {
            $moduleName = Read-Host "Enter module name"
            Install-Module -ModuleName $moduleName
        }
        "4" {
            $moduleName = Read-Host "Enter module name"
            Test-ModuleComponents -ModuleName $moduleName
        }
        "5" {
            $moduleName = Read-Host "Enter module name"
            Show-ModuleComponents -ModuleName $moduleName
        }
        "6" {
            Write-SetupxOutput "👋 Goodbye!" $Global:SetupxColors.Success
            exit
        }
        default {
            Write-SetupxOutput "❌ Invalid option. Please try again." $Global:SetupxColors.Error
        }
    }
}

# Main execution logic
if ($Help -or $Action -eq "help" -or $Action -eq "-h") {
    Show-Help
    exit 0
}

switch ($Action.ToLower()) {
    "list" {
        Show-ModuleList
    }
    "status" {
        Show-SystemStatus
    }
    "install" {
        Install-Module -ModuleName $Module
    }
    "test" {
        Test-ModuleComponents -ModuleName $Module
    }
    "components" {
        Show-ModuleComponents -ModuleName $Module
    }
    "menu" {
        Show-InteractiveMenu
    }
    default {
        Write-SetupxOutput "❌ Unknown command: $Action" $Global:SetupxColors.Error
        Write-SetupxOutput "Use 'setupx -h' to see available commands" $Global:SetupxColors.Info
    }
}