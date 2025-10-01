# SetupX - Modular Windows Development Environment Setup Tool
# JSON-Driven CLI Architecture
# Version: 2.0.0

param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Import core modules
. "$PSScriptRoot\src\utils\logger.ps1"
. "$PSScriptRoot\src\utils\helpers.ps1"
. "$PSScriptRoot\src\core\engine.ps1"
. "$PSScriptRoot\src\core\json-loader.ps1"

function Show-Banner {
    # Load config for version
    $configPath = Join-Path $PSScriptRoot "config.json"
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    
    $version = $config.version
    $title = $config.cli.banner.title
    $subtitle = $config.cli.banner.subtitle
    $description = $config.cli.banner.description
    
    $banner = @"

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ███████╗███████╗████████╗██╗   ██╗██████╗ ██╗  ██╗    ║
║   ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗╚██╗██╔╝    ║
║   ███████╗█████╗     ██║   ██║   ██║██████╔╝ ╚███╔╝     ║
║   ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝  ██╔██╗     ║
║   ███████║███████╗   ██║   ╚██████╔╝██║     ██╔╝ ██╗    ║
║   ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝  ╚═╝    ║
║                                                           ║
║          $subtitle          ║
║                   $description                ║
║                      Version $version                      ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor Cyan
}

function Show-Help {
    Show-Banner
    
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "    setupx <command> [arguments]`n" -ForegroundColor White
    
    Write-Host "COMMANDS:" -ForegroundColor Yellow
    Write-Host "    help                          Show this help message" -ForegroundColor White
    Write-Host "    list                          List all available modules" -ForegroundColor White
    Write-Host "    list-all                      List all components from all modules" -ForegroundColor White
    Write-Host "    status                        Show system status and installed components" -ForegroundColor White
    Write-Host "    install <component>           Install a specific component" -ForegroundColor White
    Write-Host "    remove <component>            Remove/uninstall a component" -ForegroundColor White
    Write-Host "    update <component>            Update a component" -ForegroundColor White
    Write-Host "    check <component>             Check if a component is installed" -ForegroundColor White
    Write-Host "    verify <component>            Verify component installation" -ForegroundColor White
    Write-Host "    test <component>              Test component functionality" -ForegroundColor White
    Write-Host "    install-module <module>       Install all components in a module" -ForegroundColor White
    Write-Host "    list-module <module>          List components in a specific module" -ForegroundColor White
    Write-Host "    search <query>                Search for components" -ForegroundColor White
    Write-Host "    version                       Show SetupX version`n" -ForegroundColor White
    
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "    setupx list                   # List all modules" -ForegroundColor DarkGray
    Write-Host "    setupx list-all               # List all components" -ForegroundColor DarkGray
    Write-Host "    setupx install chocolatey     # Install Chocolatey" -ForegroundColor DarkGray
    Write-Host "    setupx install nodejs         # Install Node.js" -ForegroundColor DarkGray
    Write-Host "    setupx check git              # Check if Git is installed" -ForegroundColor DarkGray
    Write-Host "    setupx install-module web-development  # Install all web dev tools" -ForegroundColor DarkGray
    Write-Host "    setupx list-module package-managers    # List package managers" -ForegroundColor DarkGray
    Write-Host "    setupx search docker          # Search for Docker component`n" -ForegroundColor DarkGray
    
    Write-Host "AVAILABLE MODULES:" -ForegroundColor Yellow
    $modules = Get-AllModuleConfigs
    foreach ($module in $modules | Sort-Object priority) {
        Write-Host "    $($module.name)" -ForegroundColor Cyan -NoNewline
        Write-Host " - $($module.description)" -ForegroundColor Gray
    }
    
    Write-Host "`nFor more information: https://github.com/anshulyadav32/setupx-windows-setup" -ForegroundColor Cyan
}

function Show-List {
    Write-Host "`nAvailable SetupX Modules:`n" -ForegroundColor Cyan
    
    $modules = Get-AllModuleConfigs
    
    if ($modules.Count -eq 0) {
        Write-Host "No modules found. Check your configuration." -ForegroundColor Yellow
        return
    }
    
    foreach ($module in $modules | Sort-Object priority) {
        $componentCount = ($module.components.PSObject.Properties | Measure-Object).Count
        
        Write-Host "  $($module.displayName)" -ForegroundColor Cyan -NoNewline
        Write-Host " ($componentCount components)" -ForegroundColor Gray
        Write-Host "    ID: $($module.name)" -ForegroundColor DarkGray
        Write-Host "    $($module.description)" -ForegroundColor White
        Write-Host ""
    }
    
    Write-Host "Total modules: $($modules.Count)" -ForegroundColor Green
    Write-Host "Use 'setupx list-module <module-name>' to see components in a module" -ForegroundColor Yellow
}

function Show-ListAll {
    Write-Host "`nAll Available Components:`n" -ForegroundColor Cyan
    
    $allComponents = Get-AllComponents
    
    if ($allComponents.Count -eq 0) {
        Write-Host "No components found. Check your configuration." -ForegroundColor Yellow
        return
    }
    
    $groupedByCategory = $allComponents | Group-Object -Property category
    
    foreach ($group in $groupedByCategory | Sort-Object Name) {
        Write-Host "`n$($group.Name):" -ForegroundColor Yellow
        
        foreach ($component in $group.Group | Sort-Object displayName) {
            $isInstalled = Test-ComponentInstalled -Component $component
            $statusIcon = if ($isInstalled) { "[+]" } else { "[ ]" }
            $statusColor = if ($isInstalled) { "Green" } else { "Gray" }
            
            Write-Host "  $statusIcon " -ForegroundColor $statusColor -NoNewline
            Write-Host "$($component.displayName)" -ForegroundColor Cyan -NoNewline
            Write-Host " ($($component.name))" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "`nTotal components: $($allComponents.Count)" -ForegroundColor Green
}

function Show-Status {
    Write-Host "`nSetupX System Status`n" -ForegroundColor Cyan
    
    # Load config for version and tools to check
    $configPath = Join-Path $PSScriptRoot "config.json"
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    
    # Show version
    Write-Host "SetupX Version: $($config.version)" -ForegroundColor Green
    Write-Host ""
    
    # Get tools to check from config
    $toolsToCheck = $config.statusCheck.commonTools
    
    # Group tools by category
    $allComponents = Get-AllComponents
    $groupedTools = @{}
    
    foreach ($toolName in $toolsToCheck) {
        $component = Get-ComponentByName -ComponentName $toolName
        if ($component) {
            $category = $component.category
            if (-not $groupedTools.ContainsKey($category)) {
                $groupedTools[$category] = @()
            }
            $groupedTools[$category] += $component
        }
    }
    
    # Display by category
    foreach ($category in $groupedTools.Keys | Sort-Object) {
        $categoryDisplay = (Get-Culture).TextInfo.ToTitleCase($category -replace '-', ' ')
        Write-Host "${categoryDisplay}:" -ForegroundColor Yellow
        
        foreach ($component in $groupedTools[$category]) {
            $isInstalled = Test-ComponentInstalled -Component $component
            if ($isInstalled) {
                Write-Host "  [+] $($component.displayName)" -ForegroundColor Green
            }
            else {
                Write-Host "  [ ] $($component.displayName)" -ForegroundColor Gray
            }
        }
        
        Write-Host ""
    }
}

function Invoke-Install {
    param([string]$ComponentName)
    
    if (-not $ComponentName) {
        Write-Host "Error: Component name required" -ForegroundColor Red
        Write-Host "Usage: setupx install `<component-name`>" -ForegroundColor Yellow
        return
    }
    
    $component = Get-ComponentByName -ComponentName $ComponentName
    
    if (-not $component) {
        Write-Host "Component '$ComponentName' not found" -ForegroundColor Red
        Write-Host "Use 'setupx list-all' to see available components" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nInstalling: $($component.displayName)" -ForegroundColor Cyan
    Write-Host "Description: $($component.description)" -ForegroundColor Gray
    Write-Host ""
    
    $result = Invoke-ComponentCommand -Component $component -Action "install"
    
    if ($result) {
        Write-Host "`n[SUCCESS] $($component.displayName) installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "`n[FAILED] Failed to install $($component.displayName)" -ForegroundColor Red
    }
}

function Invoke-Remove {
    param([string]$ComponentName)
    
    if (-not $ComponentName) {
        Write-Host "Error: Component name required" -ForegroundColor Red
        Write-Host "Usage: setupx remove `<component-name`>" -ForegroundColor Yellow
        return
    }
    
    $component = Get-ComponentByName -ComponentName $ComponentName
    
    if (-not $component) {
        Write-Host "Component '$ComponentName' not found" -ForegroundColor Red
        return
    }
    
    Write-Host "`nRemoving: $($component.displayName)" -ForegroundColor Cyan
    Write-Host ""
    
    $result = Invoke-ComponentCommand -Component $component -Action "remove"
    
    if ($result) {
        Write-Host "`n[SUCCESS] $($component.displayName) removed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "`n[FAILED] Failed to remove $($component.displayName)" -ForegroundColor Red
    }
}

function Invoke-Check {
    param([string]$ComponentName)
    
    if (-not $ComponentName) {
        Write-Host "Error: Component name required" -ForegroundColor Red
        Write-Host "Usage: setupx check `<component-name`>" -ForegroundColor Yellow
        return
    }
    
    $component = Get-ComponentByName -ComponentName $ComponentName
    
    if (-not $component) {
        Write-Host "Component '$ComponentName' not found" -ForegroundColor Red
        return
    }
    
    Write-Host "`nChecking: $($component.displayName)" -ForegroundColor Cyan
    
    $isInstalled = Test-ComponentInstalled -Component $component
    
    if ($isInstalled) {
        Write-Host "[+] $($component.displayName) is installed" -ForegroundColor Green
        
        # Show version if available
        if ($component.commands.check) {
            Write-Host "`nVersion information:" -ForegroundColor Cyan
            Invoke-ComponentCommand -Component $component -Action "check" | Out-Null
        }
    }
    else {
        Write-Host "[-] $($component.displayName) is not installed" -ForegroundColor Red
        Write-Host "Install with: setupx install $($component.name)" -ForegroundColor Yellow
    }
}

function Invoke-InstallModule {
    param([string]$ModuleName)
    
    if (-not $ModuleName) {
        Write-Host "Error: Module name required" -ForegroundColor Red
        Write-Host "Usage: setupx install-module `<module-name`>" -ForegroundColor Yellow
        return
    }
    
    $module = Get-ModuleConfig -ModuleName $ModuleName
    
    if (-not $module) {
        Write-Host "Module '$ModuleName' not found" -ForegroundColor Red
        Write-Host "Use 'setupx list' to see available modules" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nInstalling module: $($module.displayName)" -ForegroundColor Cyan
    Write-Host "$($module.description)" -ForegroundColor Gray
    Write-Host ""
    
    $componentCount = ($module.components.PSObject.Properties | Measure-Object).Count
    Write-Host "This module contains $componentCount components`n" -ForegroundColor Yellow
    
    $successCount = 0
    $failCount = 0
    
    foreach ($componentName in $module.components.PSObject.Properties.Name) {
        $component = $module.components.$componentName
        Write-Host "Installing $($component.displayName)..." -ForegroundColor Cyan
        
        $result = Invoke-ComponentCommand -Component $component -Action "install"
        
        if ($result) {
            $successCount++
        }
        else {
            $failCount++
        }
        
        Write-Host ""
    }
    
    Write-Host "`nModule installation complete:" -ForegroundColor Cyan
    Write-Host "  [+] Success: $successCount" -ForegroundColor Green
    Write-Host "  [-] Failed: $failCount" -ForegroundColor Red
}

function Invoke-ListModule {
    param([string]$ModuleName)
    
    if (-not $ModuleName) {
        Write-Host "Error: Module name required" -ForegroundColor Red
        Write-Host "Usage: setupx list-module `<module-name`>" -ForegroundColor Yellow
        return
    }
    
    $module = Get-ModuleConfig -ModuleName $ModuleName
    
    if (-not $module) {
        Write-Host "Module '$ModuleName' not found" -ForegroundColor Red
        Write-Host "Use 'setupx list' to see available modules" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nModule: $($module.displayName)" -ForegroundColor Cyan
    Write-Host "$($module.description)" -ForegroundColor Gray
    Write-Host ""
    
    foreach ($componentName in $module.components.PSObject.Properties.Name) {
        $component = $module.components.$componentName
        $isInstalled = Test-ComponentInstalled -Component $component
        $statusIcon = if ($isInstalled) { "[+]" } else { "[ ]" }
        $statusColor = if ($isInstalled) { "Green" } else { "Gray" }
        
        Write-Host "  $statusIcon " -ForegroundColor $statusColor -NoNewline
        Write-Host "$($component.displayName)" -ForegroundColor Cyan
        Write-Host "      $($component.description)" -ForegroundColor Gray
        Write-Host "      Install with: setupx install $($component.name)" -ForegroundColor DarkGray
        Write-Host ""
    }
}

function Invoke-Search {
    param([string]$Query)
    
    if (-not $Query) {
        Write-Host "Error: Search query required" -ForegroundColor Red
        Write-Host "Usage: setupx search `<query`>" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nSearching for: $Query`n" -ForegroundColor Cyan
    
    $allComponents = Get-AllComponents
    $results = $allComponents | Where-Object {
        $_.name -like "*$Query*" -or
        $_.displayName -like "*$Query*" -or
        $_.description -like "*$Query*"
    }
    
    if ($results.Count -eq 0) {
        Write-Host "No components found matching '$Query'" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Found $($results.Count) component(s):`n" -ForegroundColor Green
    
    foreach ($component in $results) {
        $isInstalled = Test-ComponentInstalled -Component $component
        $statusIcon = if ($isInstalled) { "[+]" } else { "[ ]" }
        $statusColor = if ($isInstalled) { "Green" } else { "Gray" }
        
        Write-Host "  $statusIcon " -ForegroundColor $statusColor -NoNewline
        Write-Host "$($component.displayName)" -ForegroundColor Cyan
        Write-Host "      $($component.description)" -ForegroundColor Gray
        Write-Host "      Module: $($component.moduleName)" -ForegroundColor DarkGray
        Write-Host "      Install with: setupx install $($component.name)" -ForegroundColor DarkGray
        Write-Host ""
    }
}

# Main command router
switch ($Command) {
    "help" { Show-Help }
    "-h" { Show-Help }
    "--help" { Show-Help }
    "list" { Show-List }
    "list-all" { Show-ListAll }
    "status" { Show-Status }
    "install" { Invoke-Install -ComponentName $Arguments[0] }
    "remove" { Invoke-Remove -ComponentName $Arguments[0] }
    "update" { 
        $component = Get-ComponentByName -ComponentName $Arguments[0]
        if ($component) {
            Invoke-ComponentCommand -Component $component -Action "update"
        }
    }
    "check" { Invoke-Check -ComponentName $Arguments[0] }
    "verify" {
        $component = Get-ComponentByName -ComponentName $Arguments[0]
        if ($component) {
            Invoke-ComponentCommand -Component $component -Action "verify"
        }
    }
    "test" {
        $component = Get-ComponentByName -ComponentName $Arguments[0]
        if ($component) {
            Invoke-ComponentCommand -Component $component -Action "test"
        }
    }
    "install-module" { Invoke-InstallModule -ModuleName $Arguments[0] }
    "list-module" { Invoke-ListModule -ModuleName $Arguments[0] }
    "search" { Invoke-Search -Query $Arguments[0] }
    "version" {
        Show-Banner
        Write-Host "SetupX Version: 2.0.0" -ForegroundColor Green
        Write-Host "JSON-Driven Architecture" -ForegroundColor Cyan
    }
    default {
        if ([string]::IsNullOrEmpty($Command)) {
            Show-Banner
            Write-Host "Run 'setupx help' for usage information`n" -ForegroundColor Yellow
        }
        else {
            Write-Host "Unknown command: $Command" -ForegroundColor Red
            Write-Host "Run 'setupx help' for available commands" -ForegroundColor Yellow
        }
    }
}

