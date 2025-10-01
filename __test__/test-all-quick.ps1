# Quick Test All Components
# Fast overview of all components

. "$PSScriptRoot\..\src\core\engine.ps1"
. "$PSScriptRoot\..\src\core\json-loader.ps1"

Write-Host "`n=== Quick Component Status Check ===" -ForegroundColor Cyan

$allComponents = Get-AllComponents
$totalComponents = $allComponents.Count
$installedCount = 0
$notInstalledCount = 0

Write-Host "`nTotal components: $totalComponents" -ForegroundColor Yellow
Write-Host ""

# Group by module
$byModule = $allComponents | Group-Object -Property moduleName

foreach ($moduleGroup in $byModule | Sort-Object Name) {
    $moduleName = $moduleGroup.Name
    Write-Host "`n$moduleName" -ForegroundColor Cyan
    Write-Host ("-" * 60) -ForegroundColor DarkGray
    
    foreach ($component in $moduleGroup.Group | Sort-Object displayName) {
        $isInstalled = Test-ComponentInstalled -Component $component
        
        if ($isInstalled) {
            $installedCount++
            Write-Host "  [+] " -ForegroundColor Green -NoNewline
        }
        else {
            $notInstalledCount++
            Write-Host "  [ ] " -ForegroundColor Gray -NoNewline
        }
        
        Write-Host "$($component.displayName)" -ForegroundColor White -NoNewline
        Write-Host " ($($component.name))" -ForegroundColor DarkGray
    }
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Total: $totalComponents" -ForegroundColor White
Write-Host "  Installed: $installedCount" -ForegroundColor Green
Write-Host "  Not Installed: $notInstalledCount" -ForegroundColor Gray
Write-Host "  Coverage: $([math]::Round(($installedCount / $totalComponents) * 100, 1))%" -ForegroundColor Cyan
Write-Host ""

