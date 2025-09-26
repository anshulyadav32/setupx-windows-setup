# setupx Module Listing Tool
# Displays comprehensive information about all available modules and components

param(
    [ValidateSet('simple', 'detailed', 'components', 'status')]
    [string]$View = 'detailed',
    [string]$Module,
    [switch]$ShowStatus
)

# Script configuration
$ScriptRoot = $PSScriptRoot
$ModulesPath = Join-Path $ScriptRoot "modules"
$SharedPath = Join-Path $ScriptRoot "shared"

# Import shared functions
. "$SharedPath\component-manager.ps1"

function Show-ModuleListBanner {
    Write-SetupxOutput "`n╔══════════════════════════════════════════════════════════════╗" $Global:SetupxColors.Cyan
    Write-SetupxOutput "║                      setupx MODULE LIST                      ║" $Global:SetupxColors.Cyan
    Write-SetupxOutput "╚══════════════════════════════════════════════════════════════╝" $Global:SetupxColors.Cyan
    Write-SetupxOutput "Complete overview of available development environment modules" $Global:SetupxColors.Gray
    Write-SetupxOutput ""
}

function Get-AllModules {
    $modules = @()
    $moduleDirectories = Get-ChildItem -Path $ModulesPath -Directory

    foreach ($moduleDir in $moduleDirectories) {
        $configPath = Join-Path $moduleDir.FullName "module.json"
        if (Test-Path $configPath) {
            try {
                $moduleConfig = Get-Content $configPath | ConvertFrom-Json

                # Add runtime status information
                $moduleConfig | Add-Member -NotePropertyName "path" -NotePropertyValue $moduleDir.FullName
                $moduleConfig | Add-Member -NotePropertyName "status" -NotePropertyValue (Get-ModuleInstallationStatus $moduleConfig $moduleDir.FullName)

                $modules += $moduleConfig
            }
            catch {
                Write-SetupxOutput "⚠️  Warning: Could not load module config for $($moduleDir.Name)" $Global:SetupxColors.Yellow
            }
        }
    }

    return $modules | Sort-Object {
        # Sort by priority: package-managers first, then alphabetically
        if ($_.name -eq "package-managers") { "0" } else { $_.displayName }
    }
}

function Get-ModuleInstallationStatus {
    param([object]$Module, [string]$ModulePath)

    $totalComponents = $Module.components.Count
    $installedComponents = 0
    $brokenComponents = 0

    foreach ($component in $Module.components) {
        try {
            $status = Get-ComponentQuickStatus -ComponentName $component.name -ModulePath $ModulePath
            switch ($status) {
                "Installed" { $installedComponents++ }
                "Broken" { $brokenComponents++ }
            }
        }
        catch {
            # Component status check failed
        }
    }

    return @{
        Total = $totalComponents
        Installed = $installedComponents
        Broken = $brokenComponents
        NotInstalled = $totalComponents - $installedComponents - $brokenComponents
        Percentage = if ($totalComponents -gt 0) { [math]::Round(($installedComponents / $totalComponents) * 100, 1) } else { 0 }
    }
}

function Get-ComponentQuickStatus {
    param([string]$ComponentName, [string]$ModulePath)

    try {
        $componentPath = Join-Path $ModulePath "components\$ComponentName.ps1"
        if (-not (Test-Path $componentPath)) {
            return "Unknown"
        }

        # Basic executable check for quick status
        $exeNames = @()

        # Try to extract executable names from component script
        $scriptContent = Get-Content $componentPath -Raw
        if ($scriptContent -match 'executableNames\s*=\s*@\(([^)]+)\)') {
            $exeString = $matches[1]
            $exeNames = $exeString -split ',' | ForEach-Object { $_.Trim().Trim('"').Trim("'") }
        }

        if ($exeNames.Count -gt 0) {
            foreach ($exe in $exeNames) {
                if (Get-Command $exe -ErrorAction SilentlyContinue) {
                    return "Installed"
                }
            }
        }

        return "NotInstalled"
    }
    catch {
        return "Unknown"
    }
}

function Show-SimpleList {
    param([array]$Modules)

    Write-SetupxOutput "📦 AVAILABLE MODULES:" $Global:SetupxColors.Magenta
    Write-SetupxOutput ""

    foreach ($module in $Modules) {
        $statusIcon = Get-StatusIcon $module.status
        $componentsInfo = "($($module.components.Count) components)"

        Write-SetupxOutput "  $statusIcon $($module.displayName.PadRight(25)) $componentsInfo" $Global:SetupxColors.White
    }

    Write-SetupxOutput ""
    Write-SetupxOutput "Legend: ✅ Fully installed  🔶 Partially installed  ❌ Not installed" $Global:SetupxColors.Gray
}

function Show-DetailedList {
    param([array]$Modules)

    foreach ($module in $Modules) {
        $statusIcon = Get-StatusIcon $module.status
        $estimatedTime = if ($module.estimatedInstallTime) { "~$($module.estimatedInstallTime)" } else { "~5-10 min" }

        Write-SetupxOutput "╔═══════════════════════════════════════════════════════════════╗" $Global:SetupxColors.Cyan
        Write-SetupxOutput "║ $statusIcon $($module.displayName.PadRight(55)) ║" $Global:SetupxColors.Cyan
        Write-SetupxOutput "╚═══════════════════════════════════════════════════════════════╝" $Global:SetupxColors.Cyan

        Write-SetupxOutput "📋 Description: $($module.description)" $Global:SetupxColors.White
        Write-SetupxOutput "🏷️  Module ID: $($module.name)" $Global:SetupxColors.Gray
        Write-SetupxOutput "📦 Components: $($module.components.Count)" $Global:SetupxColors.Gray
        Write-SetupxOutput "⏱️  Install Time: $estimatedTime" $Global:SetupxColors.Gray
        Write-SetupxOutput "🔧 Auto Install: $($module.supportsAutoInstall)" $Global:SetupxColors.Gray
        Write-SetupxOutput "🔐 Requires Admin: $($module.requiresAdmin)" $Global:SetupxColors.Gray

        if ($ShowStatus -and $module.status) {
            Write-SetupxOutput "📊 Status: $($module.status.Installed)/$($module.status.Total) components installed ($($module.status.Percentage)%)" $Global:SetupxColors.Cyan

            if ($module.status.Broken -gt 0) {
                Write-SetupxOutput "⚠️  Warning: $($module.status.Broken) components may be broken" $Global:SetupxColors.Yellow
            }
        }

        if ($module.dependencies -and $module.dependencies.Count -gt 0) {
            Write-SetupxOutput "🔗 Dependencies: $($module.dependencies -join ', ')" $Global:SetupxColors.Gray
        }

        # Show component categories
        $categorizedComponents = $module.components | Group-Object category | Sort-Object Name

        Write-SetupxOutput "`n🔧 COMPONENTS:" $Global:SetupxColors.Cyan
        foreach ($category in $categorizedComponents) {
            Write-SetupxOutput "  📂 $($category.Name.ToUpper()):" $Global:SetupxColors.Yellow
            foreach ($component in $category.Group | Sort-Object priority) {
                $requiredBadge = if ($component.required) { "[Required]" } else { "[Optional]" }
                $statusBadge = if ($ShowStatus) {
                    $compStatus = Get-ComponentQuickStatus -ComponentName $component.name -ModulePath $module.path
                    switch ($compStatus) {
                        "Installed" { "✅" }
                        "NotInstalled" { "❌" }
                        "Broken" { "⚠️" }
                        default { "❔" }
                    }
                } else { "" }

                Write-SetupxOutput "    $statusBadge $($component.displayName) $requiredBadge" $Global:SetupxColors.White
                Write-SetupxOutput "      $($component.description)" $Global:SetupxColors.Gray
            }
        }

        if ($module.postInstallMessage) {
            Write-SetupxOutput "`n💡 Post-install: $($module.postInstallMessage)" $Global:SetupxColors.Green
        }

        if ($module.nextSteps -and $module.nextSteps.Count -gt 0) {
            Write-SetupxOutput "`n📝 Next Steps:" $Global:SetupxColors.Cyan
            foreach ($step in $module.nextSteps) {
                Write-SetupxOutput "  • $step" $Global:SetupxColors.Gray
            }
        }

        Write-SetupxOutput "`n" $Global:SetupxColors.White
    }
}

function Show-ComponentsOnly {
    param([array]$Modules)

    Write-SetupxOutput "🔧 ALL COMPONENTS BY MODULE:" $Global:SetupxColors.Magenta
    Write-SetupxOutput ""

    foreach ($module in $Modules) {
        Write-SetupxOutput "📦 $($module.displayName)" $Global:SetupxColors.Cyan

        foreach ($component in $module.components | Sort-Object priority) {
            $requiredBadge = if ($component.required) { "🔴" } else { "🔵" }
            $statusIcon = if ($ShowStatus) {
                $status = Get-ComponentQuickStatus -ComponentName $component.name -ModulePath $module.path
                switch ($status) {
                    "Installed" { "✅" }
                    "NotInstalled" { "❌" }
                    "Broken" { "⚠️" }
                    default { "❔" }
                }
            } else { "  " }

            Write-SetupxOutput "  $statusIcon $requiredBadge $($component.displayName)" $Global:SetupxColors.White
            Write-SetupxOutput "      ID: $($module.name)/$($component.name)" $Global:SetupxColors.Gray
        }
        Write-SetupxOutput ""
    }

    Write-SetupxOutput "Legend:" $Global:SetupxColors.Gray
    Write-SetupxOutput "🔴 Required component  🔵 Optional component" $Global:SetupxColors.Gray
    if ($ShowStatus) {
        Write-SetupxOutput "✅ Installed  ❌ Not installed  ⚠️ Broken  ❔ Unknown" $Global:SetupxColors.Gray
    }
}

function Show-StatusSummary {
    param([array]$Modules)

    Write-SetupxOutput "📊 INSTALLATION STATUS SUMMARY:" $Global:SetupxColors.Magenta
    Write-SetupxOutput ""

    $totalComponents = 0
    $totalInstalled = 0
    $totalBroken = 0

    foreach ($module in $Modules) {
        $status = $module.status
        $totalComponents += $status.Total
        $totalInstalled += $status.Installed
        $totalBroken += $status.Broken

        $statusIcon = Get-StatusIcon $status
        $progressBar = Get-ProgressBar $status.Percentage

        Write-SetupxOutput "$statusIcon $($module.displayName.PadRight(25)) $progressBar $($status.Percentage.ToString().PadLeft(5))% ($($status.Installed)/$($status.Total))" $Global:SetupxColors.White
    }

    Write-SetupxOutput ""
    Write-SetupxOutput "═" * 80 $Global:SetupxColors.Gray

    $overallPercentage = if ($totalComponents -gt 0) { [math]::Round(($totalInstalled / $totalComponents) * 100, 1) } else { 0 }
    $overallProgressBar = Get-ProgressBar $overallPercentage

    Write-SetupxOutput "🎯 OVERALL PROGRESS: $overallProgressBar $($overallPercentage.ToString().PadLeft(5))% ($totalInstalled/$totalComponents components)" $Global:SetupxColors.Cyan

    if ($totalBroken -gt 0) {
        Write-SetupxOutput "⚠️  WARNING: $totalBroken components may be broken and need attention" $Global:SetupxColors.Yellow
    }

    if ($overallPercentage -eq 100) {
        Write-SetupxOutput "🎉 Congratulations! Your development environment is fully installed!" $Global:SetupxColors.Green
    }
    elseif ($overallPercentage -ge 75) {
        Write-SetupxOutput "👍 Great progress! You're almost there!" $Global:SetupxColors.Green
    }
    elseif ($overallPercentage -ge 50) {
        Write-SetupxOutput "📈 Good progress! Keep going!" $Global:SetupxColors.Yellow
    }
    else {
        Write-SetupxOutput "🚀 Ready to build your development environment?" $Global:SetupxColors.Cyan
    }
}

function Get-StatusIcon {
    param([object]$Status)

    if ($Status.Installed -eq $Status.Total) {
        return "✅"  # Fully installed
    }
    elseif ($Status.Installed -gt 0) {
        return "🔶"  # Partially installed
    }
    else {
        return "❌"  # Not installed
    }
}

function Get-ProgressBar {
    param([double]$Percentage)

    $barLength = 20
    $filledLength = [math]::Round(($Percentage / 100) * $barLength)
    $emptyLength = $barLength - $filledLength

    $filled = "█" * $filledLength
    $empty = "░" * $emptyLength

    return "[$filled$empty]"
}

function Show-SingleModule {
    param([string]$ModuleName, [array]$Modules)

    $module = $Modules | Where-Object { $_.name -eq $ModuleName -or $_.displayName -like "*$ModuleName*" }

    if (-not $module) {
        Write-SetupxOutput "❌ Module not found: $ModuleName" $Global:SetupxColors.Red
        Write-SetupxOutput "`nAvailable modules:" $Global:SetupxColors.Cyan
        foreach ($m in $Modules) {
            Write-SetupxOutput "  • $($m.name) ($($m.displayName))" $Global:SetupxColors.Gray
        }
        return
    }

    Show-DetailedList @($module)
}

# Main execution
function Main {
    Show-ModuleListBanner

    $modules = Get-AllModules

    if ($modules.Count -eq 0) {
        Write-SetupxOutput "❌ No modules found in $ModulesPath" $Global:SetupxColors.Red
        return
    }

    if ($Module) {
        Show-SingleModule -ModuleName $Module -Modules $modules
        return
    }

    switch ($View.ToLower()) {
        'simple' {
            Show-SimpleList -Modules $modules
        }
        'detailed' {
            Show-DetailedList -Modules $modules
        }
        'components' {
            Show-ComponentsOnly -Modules $modules
        }
        'status' {
            Show-StatusSummary -Modules $modules
        }
        default {
            Show-DetailedList -Modules $modules
        }
    }

    Write-SetupxOutput "💡 Usage Tips:" $Global:SetupxColors.Cyan
    Write-SetupxOutput "  setupx <module-name>                    # Open module menu" $Global:SetupxColors.Gray
    Write-SetupxOutput "  setupx install <module-name>           # Install entire module" $Global:SetupxColors.Gray
    Write-SetupxOutput "  setupx install <module>/<component>    # Install specific component" $Global:SetupxColors.Gray
    Write-SetupxOutput "  .\list-modules.ps1 -View status        # Show installation status" $Global:SetupxColors.Gray
    Write-SetupxOutput "  .\list-modules.ps1 -Module web-dev     # Show specific module details" $Global:SetupxColors.Gray
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    Main
}