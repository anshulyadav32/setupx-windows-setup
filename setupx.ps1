# SetupX - Individual Component Windows Development Setup
# Author: anshulyadav32
# Version: 2.0.0

param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1)]
    [string]$Component,
    
    [switch]$All,
    [switch]$Force
)

# Set execution policy for current process
Set-ExecutionPolicy Bypass -Scope Process -Force

# Color functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

# Banner
function Show-Banner {
    Write-Host ""
    Write-Info "============================================================"
    Write-Info "                  SetupX v2.0.0                             "
    Write-Info "      Individual Component Windows Development Setup       "
    Write-Info "============================================================"
    Write-Host ""
}

# Refresh environment variables
function Refresh-Environment {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Info "Environment refreshed!"
}

# Load configuration
function Get-Config {
    $configPath = Join-Path $PSScriptRoot "src\config\setupx.json"
    if (Test-Path $configPath) {
        return Get-Content $configPath | ConvertFrom-Json
    }
    Write-Error "Configuration file not found!"
    exit 1
}

# List all components
function Show-Components {
    $config = Get-Config
    Write-Info "`nAvailable Components:`n"
    
    $categories = @{}
    foreach ($component in $config.components.PSObject.Properties) {
        $comp = $component.Value
        $category = $comp.category
        if (-not $categories.ContainsKey($category)) {
            $categories[$category] = @()
        }
        $categories[$category] += $comp
    }
    
    foreach ($category in $categories.Keys | Sort-Object) {
        Write-Host "`n[" -NoNewline -ForegroundColor Yellow
        Write-Host $category.ToUpper() -NoNewline -ForegroundColor Cyan
        Write-Host "]" -ForegroundColor Yellow
        Write-Host ("-" * 60) -ForegroundColor DarkGray
        
        foreach ($comp in $categories[$category]) {
            Write-Host "  * " -NoNewline -ForegroundColor Green
            Write-Host "$($comp.name)" -NoNewline -ForegroundColor White
            Write-Host " - $($comp.description)" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Check component status
function Test-Component {
    param([string]$ComponentName)
    
    $config = Get-Config
    $comp = $config.components.$ComponentName
    
    if (-not $comp) {
        Write-Error "Component '$ComponentName' not found!"
        return $false
    }
    
    Write-Info "Checking $($comp.displayName)..."
    
    try {
        $result = Invoke-Expression $comp.commands.check 2>&1
        if ($LASTEXITCODE -eq 0 -or $result) {
            Write-Success "[OK] $($comp.displayName) is installed"
            Write-Host "  Version: $result" -ForegroundColor Gray
            return $true
        }
    }
    catch {
        Write-Warning "[NOT INSTALLED] $($comp.displayName) is not installed"
        return $false
    }
    
    Write-Warning "[NOT INSTALLED] $($comp.displayName) is not installed"
    return $false
}

# Install component
function Install-Component {
    param([string]$ComponentName)
    
    $config = Get-Config
    $comp = $config.components.$ComponentName
    
    if (-not $comp) {
        Write-Error "Component '$ComponentName' not found!"
        return
    }
    
    Write-Info "`nInstalling $($comp.displayName)..."
    Write-Host "Description: $($comp.description)" -ForegroundColor Gray
    Write-Host "Website: $($comp.website)" -ForegroundColor Gray
    Write-Host ""
    
    try {
        Invoke-Expression $comp.commands.install
        Refresh-Environment
        Start-Sleep -Seconds 2
        
        if (Test-Component $ComponentName) {
            Write-Success "`n[SUCCESS] $($comp.displayName) installed successfully!"
        }
        else {
            Write-Warning "`n[WARNING] Installation completed but component check failed. Try refreshing your terminal."
        }
    }
    catch {
        Write-Error "`n[ERROR] Failed to install $($comp.displayName)"
        Write-Error $_.Exception.Message
    }
}

# Remove component
function Remove-Component {
    param([string]$ComponentName)
    
    $config = Get-Config
    $comp = $config.components.$ComponentName
    
    if (-not $comp) {
        Write-Error "Component '$ComponentName' not found!"
        return
    }
    
    Write-Warning "`nRemoving $($comp.displayName)..."
    
    try {
        Invoke-Expression $comp.commands.remove
        Refresh-Environment
        Write-Success "[SUCCESS] $($comp.displayName) removed successfully!"
    }
    catch {
        Write-Error "[ERROR] Failed to remove $($comp.displayName)"
        Write-Error $_.Exception.Message
    }
}

# Update component
function Update-Component {
    param([string]$ComponentName)
    
    $config = Get-Config
    $comp = $config.components.$ComponentName
    
    if (-not $comp) {
        Write-Error "Component '$ComponentName' not found!"
        return
    }
    
    Write-Info "`nUpdating $($comp.displayName)..."
    
    try {
        Invoke-Expression $comp.commands.update
        Refresh-Environment
        Write-Success "[SUCCESS] $($comp.displayName) updated successfully!"
        
        Test-Component $ComponentName
    }
    catch {
        Write-Error "[ERROR] Failed to update $($comp.displayName)"
        Write-Error $_.Exception.Message
    }
}

# Verify component
function Verify-Component {
    param([string]$ComponentName)
    
    $config = Get-Config
    $comp = $config.components.$ComponentName
    
    if (-not $comp) {
        Write-Error "Component '$ComponentName' not found!"
        return
    }
    
    Write-Info "Verifying $($comp.displayName)..."
    
    try {
        $result = Invoke-Expression $comp.commands.verify
        Write-Success "[SUCCESS] Verification complete"
        Write-Host $result -ForegroundColor Gray
    }
    catch {
        Write-Error "[ERROR] Verification failed"
        Write-Error $_.Exception.Message
    }
}

# Test component
function Test-ComponentFull {
    param([string]$ComponentName)
    
    $config = Get-Config
    $comp = $config.components.$ComponentName
    
    if (-not $comp) {
        Write-Error "Component '$ComponentName' not found!"
        return
    }
    
    Write-Info "Testing $($comp.displayName)..."
    
    try {
        $result = Invoke-Expression $comp.commands.test
        Write-Success "[SUCCESS] Test complete"
        Write-Host $result -ForegroundColor Gray
    }
    catch {
        Write-Error "[ERROR] Test failed"
        Write-Error $_.Exception.Message
    }
}

# Check all components
function Test-AllComponents {
    $config = Get-Config
    Write-Info "`nSystem Status Check:`n"
    
    $installed = 0
    $notInstalled = 0
    
    foreach ($component in $config.components.PSObject.Properties) {
        if (Test-Component $component.Name) {
            $installed++
        }
        else {
            $notInstalled++
        }
    }
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor DarkGray
    Write-Success "Installed: $installed"
    Write-Warning "Not Installed: $notInstalled"
    Write-Host ("=" * 60) -ForegroundColor DarkGray
    Write-Host ""
}

# Show help
function Show-Help {
    Show-Banner
    Write-Host "Usage: .\setupx.ps1 [command] [component]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  list                    List all available components" -ForegroundColor White
    Write-Host "  status                  Check status of all components" -ForegroundColor White
    Write-Host "  install [component]     Install a specific component" -ForegroundColor White
    Write-Host "  remove [component]      Remove a specific component" -ForegroundColor White
    Write-Host "  update [component]      Update a specific component" -ForegroundColor White
    Write-Host "  check [component]       Check if a component is installed" -ForegroundColor White
    Write-Host "  verify [component]      Verify component installation" -ForegroundColor White
    Write-Host "  test [component]        Test component functionality" -ForegroundColor White
    Write-Host "  refresh                 Refresh environment variables" -ForegroundColor White
    Write-Host "  help                    Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\setupx.ps1 list" -ForegroundColor Gray
    Write-Host "  .\setupx.ps1 status" -ForegroundColor Gray
    Write-Host "  .\setupx.ps1 install chocolatey" -ForegroundColor Gray
    Write-Host "  .\setupx.ps1 check nodejs" -ForegroundColor Gray
    Write-Host "  .\setupx.ps1 update git" -ForegroundColor Gray
    Write-Host ""
}

# Main execution
Show-Banner

switch ($Command.ToLower()) {
    "list" { Show-Components }
    "status" { Test-AllComponents }
    "install" { 
        if ($Component) { Install-Component $Component }
        else { Write-Error "Please specify a component to install" }
    }
    "remove" { 
        if ($Component) { Remove-Component $Component }
        else { Write-Error "Please specify a component to remove" }
    }
    "update" { 
        if ($Component) { Update-Component $Component }
        else { Write-Error "Please specify a component to update" }
    }
    "check" { 
        if ($Component) { Test-Component $Component }
        elseif ($All) { Test-AllComponents }
        else { Write-Error "Please specify a component to check" }
    }
    "verify" { 
        if ($Component) { Verify-Component $Component }
        else { Write-Error "Please specify a component to verify" }
    }
    "test" { 
        if ($Component) { Test-ComponentFull $Component }
        else { Write-Error "Please specify a component to test" }
    }
    "refresh" { Refresh-Environment }
    "help" { Show-Help }
    default { Show-Help }
}

