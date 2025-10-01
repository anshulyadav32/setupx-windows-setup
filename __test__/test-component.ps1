# Test Specific Component
# Detailed test of a single component

param(
    [Parameter(Mandatory=$true)]
    [string]$ComponentName
)

. "$PSScriptRoot\..\src\core\engine.ps1"
. "$PSScriptRoot\..\src\core\json-loader.ps1"

Write-Host "`n=== Detailed Component Test ===" -ForegroundColor Cyan

$component = Get-ComponentByName -ComponentName $ComponentName

if (-not $component) {
    Write-Host "Component '$ComponentName' not found!" -ForegroundColor Red
    Write-Host "Use 'setupx list-all' to see available components" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nComponent Information:" -ForegroundColor Yellow
Write-Host "  Name: $($component.name)" -ForegroundColor White
Write-Host "  Display Name: $($component.displayName)" -ForegroundColor White
Write-Host "  Description: $($component.description)" -ForegroundColor White
Write-Host "  Category: $($component.category)" -ForegroundColor White
Write-Host "  Module: $($component.moduleName)" -ForegroundColor White

if ($component.website) {
    Write-Host "  Website: $($component.website)" -ForegroundColor White
}

Write-Host "`nAvailable Commands:" -ForegroundColor Yellow
foreach ($cmd in $component.commands.PSObject.Properties) {
    Write-Host "  $($cmd.Name):" -ForegroundColor Cyan
    Write-Host "    $($cmd.Value)" -ForegroundColor Gray
}

Write-Host "`nInstallation Status:" -ForegroundColor Yellow
$isInstalled = Test-ComponentInstalled -Component $component

if ($isInstalled) {
    Write-Host "  [+] INSTALLED" -ForegroundColor Green
    
    # Run check command
    if ($component.commands.check) {
        Write-Host "`nVersion Information:" -ForegroundColor Yellow
        try {
            $output = Invoke-Expression $component.commands.check 2>&1
            $output | ForEach-Object {
                Write-Host "  $_" -ForegroundColor White
            }
        }
        catch {
            Write-Host "  Error: $_" -ForegroundColor Red
        }
    }
    
    # Run verify command if available
    if ($component.commands.verify) {
        Write-Host "`nVerification:" -ForegroundColor Yellow
        try {
            $output = Invoke-Expression $component.commands.verify 2>&1
            $output | ForEach-Object {
                Write-Host "  $_" -ForegroundColor White
            }
        }
        catch {
            Write-Host "  Error: $_" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "  [-] NOT INSTALLED" -ForegroundColor Red
    Write-Host "`nTo install, run:" -ForegroundColor Yellow
    Write-Host "  setupx install $($component.name)" -ForegroundColor Cyan
    Write-Host "  wsx install $($component.name)" -ForegroundColor Cyan
}

Write-Host ""

