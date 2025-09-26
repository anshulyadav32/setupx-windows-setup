# setupx Menu Helpers
# Interactive menu functions for modules

# Import component manager
. "$PSScriptRoot\component-manager.ps1"

function Show-ModuleMenu {
    <#
    .SYNOPSIS
    Shows interactive menu for a module with options: Auto Config, Custom Install, Status, Exit
    #>
    param(
        [string]$ModuleName,
        [string]$ModulePath
    )

    # Load module configuration
    $moduleConfigPath = Join-Path $ModulePath "module.json"
    if (-not (Test-Path $moduleConfigPath)) {
        Write-SetupxOutput "✗ Module configuration not found: $moduleConfigPath" $Global:SetupxColors.Red
        return
    }

    $moduleConfig = Get-Content $moduleConfigPath | ConvertFrom-Json

    do {
        Clear-Host
        Show-ModuleBanner -ModuleName $ModuleName -ModuleConfig $moduleConfig

        Write-SetupxOutput "`n╔═══════════════════════════════════════╗" $Global:SetupxColors.Cyan
        Write-SetupxOutput "║           MODULE MENU OPTIONS         ║" $Global:SetupxColors.Cyan
        Write-SetupxOutput "╚═══════════════════════════════════════╝" $Global:SetupxColors.Cyan
        Write-SetupxOutput ""
        Write-SetupxOutput "  [1] 🚀 Auto Config     - Install all components automatically" $Global:SetupxColors.White
        Write-SetupxOutput "  [2] 🛠️  Custom Install  - Choose specific components to install" $Global:SetupxColors.White
        Write-SetupxOutput "  [3] 📊 Status          - Check installation status of all components" $Global:SetupxColors.White
        Write-SetupxOutput "  [4] 🔄 Update All      - Update all installed components" $Global:SetupxColors.White
        Write-SetupxOutput "  [5] 🧪 Test All        - Test all installed components" $Global:SetupxColors.White
        Write-SetupxOutput "  [6] ❌ Exit            - Return to main menu" $Global:SetupxColors.White
        Write-SetupxOutput ""

        $choice = Read-Host "Select option (1-6)"

        switch ($choice) {
            "1" { Invoke-AutoConfig -ModuleName $ModuleName -ModuleConfig $moduleConfig -ModulePath $ModulePath }
            "2" { Invoke-CustomInstall -ModuleName $ModuleName -ModuleConfig $moduleConfig -ModulePath $ModulePath }
            "3" { Invoke-StatusCheck -ModuleName $ModuleName -ModuleConfig $moduleConfig -ModulePath $ModulePath }
            "4" { Invoke-UpdateAll -ModuleName $ModuleName -ModuleConfig $moduleConfig -ModulePath $ModulePath }
            "5" { Invoke-TestAll -ModuleName $ModuleName -ModuleConfig $moduleConfig -ModulePath $ModulePath }
            "6" { return }
            default {
                Write-SetupxOutput "Invalid option. Please select 1-6." $Global:SetupxColors.Red
                Start-Sleep 2
            }
        }

        if ($choice -in @("1", "2", "3", "4", "5")) {
            Write-SetupxOutput "`nPress any key to continue..." $Global:SetupxColors.Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }

    } while ($choice -ne "6")
}

function Show-ModuleBanner {
    param(
        [string]$ModuleName,
        [object]$ModuleConfig
    )

    Write-SetupxOutput "╔══════════════════════════════════════════════════════════════╗" $Global:SetupxColors.Cyan
    Write-SetupxOutput "║                        setupx                                 ║" $Global:SetupxColors.Cyan
    Write-SetupxOutput "╚══════════════════════════════════════════════════════════════╝" $Global:SetupxColors.Cyan
    Write-SetupxOutput ""
    Write-SetupxOutput "📦 Module: $($ModuleConfig.displayName)" $Global:SetupxColors.Magenta
    Write-SetupxOutput "📋 Description: $($ModuleConfig.description)" $Global:SetupxColors.White
    Write-SetupxOutput "🔧 Components: $($ModuleConfig.components.Count)" $Global:SetupxColors.Gray
    Write-SetupxOutput "⚡ Auto-install available: $($ModuleConfig.supportsAutoInstall)" $Global:SetupxColors.Gray
}

function Invoke-AutoConfig {
    param(
        [string]$ModuleName,
        [object]$ModuleConfig,
        [string]$ModulePath
    )

    Write-SetupxOutput "`n🚀 Starting Auto Config for $($ModuleConfig.displayName)..." $Global:SetupxColors.Cyan

    if (-not $ModuleConfig.supportsAutoInstall) {
        Write-SetupxOutput "✗ Auto config is not supported for this module" $Global:SetupxColors.Red
        return
    }

    Write-SetupxOutput "This will install all components in this module:" $Global:SetupxColors.White
    foreach ($component in $ModuleConfig.components) {
        Write-SetupxOutput "  • $($component.displayName)" $Global:SetupxColors.Gray
    }

    $confirm = Read-Host "`nDo you want to continue? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-SetupxOutput "Auto config cancelled." $Global:SetupxColors.Yellow
        return
    }

    $results = @()
    $totalComponents = $ModuleConfig.components.Count
    $currentIndex = 0

    foreach ($component in $ModuleConfig.components) {
        $currentIndex++
        Write-SetupxOutput "`n[$currentIndex/$totalComponents] Processing $($component.displayName)..." $Global:SetupxColors.Cyan

        try {
            $componentPath = Join-Path $ModulePath "components\$($component.scriptName)"
            if (Test-Path $componentPath) {
                $componentConfig = Load-ComponentConfig -ComponentPath $componentPath
                $result = Install-Component -ComponentName $component.displayName -ComponentConfig $componentConfig
                $results += $result
            } else {
                Write-SetupxOutput "✗ Component script not found: $componentPath" $Global:SetupxColors.Red
            }
        }
        catch {
            Write-SetupxOutput "✗ Error installing $($component.displayName): $($_.Exception.Message)" $Global:SetupxColors.Red
        }
    }

    Show-InstallationSummary -Results $results -ModuleName $ModuleConfig.displayName
}

function Invoke-CustomInstall {
    param(
        [string]$ModuleName,
        [object]$ModuleConfig,
        [string]$ModulePath
    )

    Write-SetupxOutput "`n🛠️ Custom Install for $($ModuleConfig.displayName)" $Global:SetupxColors.Cyan

    do {
        Write-SetupxOutput "`nAvailable Components:" $Global:SetupxColors.White

        for ($i = 0; $i -lt $ModuleConfig.components.Count; $i++) {
            $component = $ModuleConfig.components[$i]
            $status = Get-ComponentQuickStatus -ComponentName $component.name -ModulePath $ModulePath
            $statusIcon = switch ($status) {
                "Installed" { "✅" }
                "NotInstalled" { "❌" }
                "Broken" { "⚠️" }
                default { "❔" }
            }

            Write-SetupxOutput "  [$($i + 1)] $statusIcon $($component.displayName) - $($component.description)" $Global:SetupxColors.White
        }

        Write-SetupxOutput "  [A] Install All" $Global:SetupxColors.Yellow
        Write-SetupxOutput "  [S] Check Status of All" $Global:SetupxColors.Cyan
        Write-SetupxOutput "  [Q] Return to Module Menu" $Global:SetupxColors.Gray

        $choice = Read-Host "`nSelect component to install (1-$($ModuleConfig.components.Count), A, S, Q)"

        if ($choice -eq "Q" -or $choice -eq "q") {
            break
        }
        elseif ($choice -eq "A" -or $choice -eq "a") {
            Invoke-AutoConfig -ModuleName $ModuleName -ModuleConfig $ModuleConfig -ModulePath $ModulePath
            break
        }
        elseif ($choice -eq "S" -or $choice -eq "s") {
            Invoke-StatusCheck -ModuleName $ModuleName -ModuleConfig $ModuleConfig -ModulePath $ModulePath
        }
        elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $ModuleConfig.components.Count) {
            $selectedComponent = $ModuleConfig.components[[int]$choice - 1]
            Install-SingleComponent -Component $selectedComponent -ModulePath $ModulePath
        }
        else {
            Write-SetupxOutput "Invalid selection. Please try again." $Global:SetupxColors.Red
            Start-Sleep 2
        }

    } while ($true)
}

function Invoke-StatusCheck {
    param(
        [string]$ModuleName,
        [object]$ModuleConfig,
        [string]$ModulePath
    )

    Write-SetupxOutput "`n📊 Status Check for $($ModuleConfig.displayName)" $Global:SetupxColors.Cyan
    Write-SetupxOutput "═" * 60 $Global:SetupxColors.Gray

    $results = @()

    foreach ($component in $ModuleConfig.components) {
        try {
            $componentPath = Join-Path $ModulePath "components\$($component.scriptName)"
            if (Test-Path $componentPath) {
                $componentConfig = Load-ComponentConfig -ComponentPath $componentPath
                $result = Test-Component -ComponentName $component.displayName -ComponentConfig $componentConfig
                $results += $result
            } else {
                Write-SetupxOutput "⚠️ Component script not found: $($component.scriptName)" $Global:SetupxColors.Yellow
            }
        }
        catch {
            Write-SetupxOutput "✗ Error checking $($component.displayName): $($_.Exception.Message)" $Global:SetupxColors.Red
        }
    }

    Write-SetupxOutput "`nStatus Summary:" $Global:SetupxColors.Cyan
    $installed = ($results | Where-Object { $_.Success }).Count
    $total = $results.Count
    Write-SetupxOutput "  Installed: $installed/$total components" $Global:SetupxColors.Green

    if ($installed -lt $total) {
        $missing = $total - $installed
        Write-SetupxOutput "  Missing: $missing components" $Global:SetupxColors.Red
    }
}

function Invoke-UpdateAll {
    param(
        [string]$ModuleName,
        [object]$ModuleConfig,
        [string]$ModulePath
    )

    Write-SetupxOutput "`n🔄 Updating All Components in $($ModuleConfig.displayName)" $Global:SetupxColors.Cyan

    $updatedCount = 0
    foreach ($component in $ModuleConfig.components) {
        try {
            $componentPath = Join-Path $ModulePath "components\$($component.scriptName)"
            if (Test-Path $componentPath) {
                $componentConfig = Load-ComponentConfig -ComponentPath $componentPath
                $updated = Update-Component -ComponentName $component.displayName -ComponentConfig $componentConfig
                if ($updated) { $updatedCount++ }
            }
        }
        catch {
            Write-SetupxOutput "✗ Error updating $($component.displayName): $($_.Exception.Message)" $Global:SetupxColors.Red
        }
    }

    Write-SetupxOutput "`n✓ Update completed. $updatedCount components updated." $Global:SetupxColors.Green
}

function Invoke-TestAll {
    param(
        [string]$ModuleName,
        [object]$ModuleConfig,
        [string]$ModulePath
    )

    Write-SetupxOutput "`n🧪 Testing All Components in $($ModuleConfig.displayName)" $Global:SetupxColors.Cyan

    $testResults = @()
    foreach ($component in $ModuleConfig.components) {
        $componentPath = Join-Path $ModulePath "components\$($component.scriptName)"
        if (Test-Path $componentPath) {
            $componentConfig = Load-ComponentConfig -ComponentPath $componentPath
            $result = Test-Component -ComponentName $component.displayName -ComponentConfig $componentConfig
            $testResults += $result
        }
    }

    $passedTests = ($testResults | Where-Object { $_.Success }).Count
    $totalTests = $testResults.Count

    Write-SetupxOutput "`nTest Results: $passedTests/$totalTests passed" $Global:SetupxColors.Cyan
}

function Install-SingleComponent {
    param(
        [object]$Component,
        [string]$ModulePath
    )

    Write-SetupxOutput "`n🔧 Installing $($Component.displayName)..." $Global:SetupxColors.Cyan

    $componentPath = Join-Path $ModulePath "components\$($Component.scriptName)"
    if (-not (Test-Path $componentPath)) {
        Write-SetupxOutput "✗ Component script not found: $componentPath" $Global:SetupxColors.Red
        return
    }

    try {
        $componentConfig = Load-ComponentConfig -ComponentPath $componentPath
        $result = Install-Component -ComponentName $Component.displayName -ComponentConfig $componentConfig

        if ($result.Success) {
            Write-SetupxOutput "✓ $($Component.displayName) installed successfully!" $Global:SetupxColors.Green
        } else {
            Write-SetupxOutput "✗ Failed to install $($Component.displayName): $($result.Message)" $Global:SetupxColors.Red
        }
    }
    catch {
        Write-SetupxOutput "✗ Error during installation: $($_.Exception.Message)" $Global:SetupxColors.Red
    }
}

function Get-ComponentQuickStatus {
    param(
        [string]$ComponentName,
        [string]$ModulePath
    )

    try {
        $componentPath = Join-Path $ModulePath "components\$ComponentName.ps1"
        if (-not (Test-Path $componentPath)) {
            return "Unknown"
        }

        $componentConfig = Load-ComponentConfig -ComponentPath $componentPath
        $result = Test-ComponentExecutable -ExecutableNames $componentConfig.executableNames -VersionCommands $componentConfig.versionCommands -TestCommands $componentConfig.testCommands

        return $result.Status.ToString()
    }
    catch {
        return "Unknown"
    }
}

function Load-ComponentConfig {
    param([string]$ComponentPath)

    # Load component configuration from script
    # This will be implemented to extract configuration from component scripts
    # For now, return a basic structure
    return @{
        executableNames = @()
        versionCommands = @()
        testCommands = @()
        wingetId = ""
        chocoId = ""
        scoopId = ""
    }
}

function Show-InstallationSummary {
    param(
        [array]$Results,
        [string]$ModuleName
    )

    Write-SetupxOutput "`n╔═══════════════════════════════════════╗" $Global:SetupxColors.Cyan
    Write-SetupxOutput "║         INSTALLATION SUMMARY          ║" $Global:SetupxColors.Cyan
    Write-SetupxOutput "╚═══════════════════════════════════════╝" $Global:SetupxColors.Cyan

    $successful = ($Results | Where-Object { $_.Success }).Count
    $total = $Results.Count

    Write-SetupxOutput "`n📦 Module: $ModuleName" $Global:SetupxColors.White
    Write-SetupxOutput "✅ Successful: $successful/$total components" $Global:SetupxColors.Green

    if ($successful -lt $total) {
        Write-SetupxOutput "❌ Failed: $($total - $successful) components" $Global:SetupxColors.Red
        Write-SetupxOutput "`nFailed components:" $Global:SetupxColors.Yellow

        $failedResults = $Results | Where-Object { -not $_.Success }
        foreach ($failed in $failedResults) {
            Write-SetupxOutput "  • $($failed.Name): $($failed.Message)" $Global:SetupxColors.Red
        }
    }

    if ($successful -eq $total) {
        Write-SetupxOutput "`n🎉 All components installed successfully!" $Global:SetupxColors.Green
    }
}

Export-ModuleMember -Function Show-ModuleMenu, Show-ModuleBanner, Invoke-AutoConfig, Invoke-CustomInstall, Invoke-StatusCheck