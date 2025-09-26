# WinGet Component for setupx
# Configures and tests Microsoft's Windows Package Manager

# Component configuration
$ComponentConfig = @{
    name = "winget"
    displayName = "WinGet"
    description = "Microsoft's official Windows package manager"

    # Executables to test
    executableNames = @("winget.exe", "winget")

    # Version commands
    versionCommands = @("winget --version")

    # Test commands
    testCommands = @(
        "winget --version",
        "winget search notepad --count 1",
        "winget list --count 1"
    )

    # WinGet is usually pre-installed or requires Microsoft Store
    installCommands = @()

    # Installation settings
    requiresAdmin = $false  # WinGet can work without admin for most operations
    category = "package-manager"

    # Post-install commands (configuration)
    postInstallCommands = @(
        "winget source update"
    )

    # Test paths - WinGet location varies by installation method
    testPaths = @()
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-WinGet {
    param([switch]$Force, [switch]$SkipTest)

    Write-SetupxOutput "`n📦 Configuring WinGet Package Manager" $Global:SetupxColors.Blue

    # Check if already available
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-SetupxOutput "✅ WinGet is already available and working!" $Global:SetupxColors.Green
            return $testResult
        }
    }

    Write-SetupxOutput "Checking WinGet availability..." $Global:SetupxColors.Yellow

    # Try to find WinGet
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        Write-SetupxOutput "✅ WinGet found in PATH" $Global:SetupxColors.Green
    }
    else {
        # Check common locations
        $wingetPaths = @(
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe",
            "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller*\winget.exe"
        )

        $foundWinGet = $false
        foreach ($path in $wingetPaths) {
            $expandedPath = [System.Environment]::ExpandEnvironmentVariables($path)
            if ($path -like "*`**") {
                $matches = Get-ChildItem -Path (Split-Path $expandedPath) -Filter (Split-Path $expandedPath -Leaf) -ErrorAction SilentlyContinue
                if ($matches) {
                    $foundWinGet = $true
                    Write-SetupxOutput "✅ WinGet found at: $($matches[0].FullName)" $Global:SetupxColors.Green
                    break
                }
            }
            elseif (Test-Path $expandedPath) {
                $foundWinGet = $true
                Write-SetupxOutput "✅ WinGet found at: $expandedPath" $Global:SetupxColors.Green
                break
            }
        }

        if (-not $foundWinGet) {
            Write-SetupxOutput "⚠️  WinGet not found in common locations" $Global:SetupxColors.Yellow
            Write-SetupxOutput "`n📋 WinGet Installation Options:" $Global:SetupxColors.Cyan
            Write-SetupxOutput "1. 🏪 Install from Microsoft Store:" $Global:SetupxColors.White
            Write-SetupxOutput "   • Search for 'App Installer' in Microsoft Store" $Global:SetupxColors.Gray
            Write-SetupxOutput "   • Or visit: https://aka.ms/getwinget" $Global:SetupxColors.Gray
            Write-SetupxOutput ""
            Write-SetupxOutput "2. 📁 Manual installation:" $Global:SetupxColors.White
            Write-SetupxOutput "   • Download from: https://github.com/microsoft/winget-cli/releases" $Global:SetupxColors.Gray
            Write-SetupxOutput "   • Install the .msixbundle file" $Global:SetupxColors.Gray
            Write-SetupxOutput ""
            Write-SetupxOutput "3. 🆕 Windows Update:" $Global:SetupxColors.White
            Write-SetupxOutput "   • WinGet comes pre-installed on Windows 11" $Global:SetupxColors.Gray
            Write-SetupxOutput "   • Update Windows 10 to get WinGet automatically" $Global:SetupxColors.Gray

            # Try to open Microsoft Store
            $openStore = Read-Host "`nWould you like to open Microsoft Store to install WinGet? (y/N)"
            if ($openStore -eq "y" -or $openStore -eq "Y") {
                try {
                    Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
                    Write-SetupxOutput "📱 Microsoft Store opened. Please install 'App Installer'" $Global:SetupxColors.Green
                }
                catch {
                    Write-SetupxOutput "Could not open Microsoft Store. Please install manually." $Global:SetupxColors.Yellow
                }
            }

            $errorResult = [ComponentResult]::new()
            $errorResult.Name = $ComponentConfig.displayName
            $errorResult.Success = $false
            $errorResult.Status = [ComponentStatus]::NotInstalled
            $errorResult.Message = "WinGet not found - manual installation required"
            return $errorResult
        }
    }

    # Configure WinGet
    Write-SetupxOutput "Configuring WinGet..." $Global:SetupxColors.White

    try {
        # Update sources
        Write-SetupxOutput "Updating WinGet sources..." $Global:SetupxColors.White
        winget source update 2>$null
        Write-SetupxOutput "✅ WinGet sources updated" $Global:SetupxColors.Green

        # Accept source agreements (this helps with future automation)
        Write-SetupxOutput "Accepting source agreements..." $Global:SetupxColors.White
        winget search Microsoft.PowerToys --accept-source-agreements >$null 2>&1
        Write-SetupxOutput "✅ Source agreements accepted" $Global:SetupxColors.Green

        # Verify installation
        $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

        if ($verifyResult.Success) {
            Write-SetupxOutput "✅ WinGet configuration completed!" $Global:SetupxColors.Green
            Write-SetupxOutput "`n📋 Usage examples:" $Global:SetupxColors.Cyan
            Write-SetupxOutput "  winget search <app>           - Search for applications" $Global:SetupxColors.White
            Write-SetupxOutput "  winget install <id>           - Install an application" $Global:SetupxColors.White
            Write-SetupxOutput "  winget upgrade --all          - Update all applications" $Global:SetupxColors.White
            Write-SetupxOutput "  winget list                   - List installed applications" $Global:SetupxColors.White
            Write-SetupxOutput "  winget source list            - List configured sources" $Global:SetupxColors.White
            Write-SetupxOutput "  winget show <id>              - Show application details" $Global:SetupxColors.White

            Write-SetupxOutput "`n💡 Pro Tips:" $Global:SetupxColors.Cyan
            Write-SetupxOutput "  • Use --silent for automated installs" $Global:SetupxColors.White
            Write-SetupxOutput "  • Use --accept-source-agreements to skip prompts" $Global:SetupxColors.White
            Write-SetupxOutput "  • Use --accept-package-agreements for faster installs" $Global:SetupxColors.White
        }

        return $verifyResult

    }
    catch {
        $errorResult = [ComponentResult]::new()
        $errorResult.Name = $ComponentConfig.displayName
        $errorResult.Success = $false
        $errorResult.Status = [ComponentStatus]::Broken
        $errorResult.Message = "Configuration failed: $($_.Exception.Message)"

        Write-SetupxOutput "❌ WinGet configuration failed: $($_.Exception.Message)" $Global:SetupxColors.Red
        return $errorResult
    }
}

function Test-WinGet {
    Write-SetupxOutput "`n🧪 Testing WinGet Package Manager" $Global:SetupxColors.Cyan

    $result = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result.Success) {
        # Additional WinGet specific tests
        try {
            $wingetList = winget list --accept-source-agreements 2>$null
            $appCount = ($wingetList | Where-Object { $_ -match '^\w+' -and $_ -notmatch 'Name.*Id.*Version' } | Measure-Object).Count
            Write-SetupxOutput "✅ WinGet can see $appCount installed applications" $Global:SetupxColors.Green
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Could not list installed applications" $Global:SetupxColors.Yellow
        }

        # Test sources
        try {
            $sources = winget source list 2>$null
            if ($sources) {
                $sourceCount = ($sources | Where-Object { $_ -match '^\w+' -and $_ -notmatch 'Name.*Argument' } | Measure-Object).Count
                Write-SetupxOutput "✅ $sourceCount WinGet sources are configured" $Global:SetupxColors.Green
            }
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Could not list sources" $Global:SetupxColors.Yellow
        }

        # Test search functionality
        try {
            $searchTest = winget search notepad --count 1 --accept-source-agreements 2>$null
            if ($searchTest) {
                Write-SetupxOutput "✅ Package search is working" $Global:SetupxColors.Green
            }
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Package search may have issues" $Global:SetupxColors.Yellow
        }

        # Check for updates
        try {
            $updates = winget upgrade --accept-source-agreements 2>$null
            $updateCount = ($updates | Where-Object { $_ -match '^\w+.*\d+\.\d+' } | Measure-Object).Count
            if ($updateCount -gt 0) {
                Write-SetupxOutput "📋 $updateCount applications have updates available" $Global:SetupxColors.Cyan
            } else {
                Write-SetupxOutput "✅ All applications are up to date" $Global:SetupxColors.Green
            }
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Could not check for updates" $Global:SetupxColors.Yellow
        }
    }

    return $result
}

function Update-WinGet {
    Write-SetupxOutput "`n🔄 Updating WinGet and Applications" $Global:SetupxColors.Cyan

    try {
        # Update WinGet sources first
        Write-SetupxOutput "Updating WinGet sources..." $Global:SetupxColors.White
        winget source update --accept-source-agreements
        Write-SetupxOutput "✅ WinGet sources updated!" $Global:SetupxColors.Green

        # Check for WinGet itself updates (it's usually auto-updated via Microsoft Store)
        Write-SetupxOutput "Checking WinGet version..." $Global:SetupxColors.White
        $version = winget --version
        Write-SetupxOutput "Current WinGet version: $version" $Global:SetupxColors.Gray

        # Update all applications
        $updateAll = Read-Host "Do you want to update all applications? (y/N)"
        if ($updateAll -eq "y" -or $updateAll -eq "Y") {
            Write-SetupxOutput "Updating all applications..." $Global:SetupxColors.White
            winget upgrade --all --accept-source-agreements --accept-package-agreements --silent
            Write-SetupxOutput "✅ Application updates completed!" $Global:SetupxColors.Green
        }

        return $true
    }
    catch {
        Write-SetupxOutput "❌ Failed to update WinGet: $($_.Exception.Message)" $Global:SetupxColors.Red
        return $false
    }
}

function Get-WinGetInfo {
    Write-SetupxOutput "`n📊 WinGet Information" $Global:SetupxColors.Cyan

    try {
        # Show version
        $version = winget --version 2>$null
        Write-SetupxOutput "📝 Version: $version" $Global:SetupxColors.White

        # Show sources
        Write-SetupxOutput "📡 Configured sources:" $Global:SetupxColors.White
        $sources = winget source list 2>$null
        foreach ($source in $sources) {
            if ($source -match '^\w+' -and $source -notmatch 'Name.*Argument') {
                Write-SetupxOutput "    • $source" $Global:SetupxColors.Gray
            }
        }

        # Show available updates
        Write-SetupxOutput "`n🔄 Available updates:" $Global:SetupxColors.White
        $updates = winget upgrade --accept-source-agreements 2>$null
        $updateLines = $updates | Where-Object { $_ -match '^\w+.*\d+\.\d+' }

        if ($updateLines.Count -gt 0) {
            Write-SetupxOutput "📋 $($updateLines.Count) applications have updates available" $Global:SetupxColors.Cyan
            foreach ($update in $updateLines | Select-Object -First 5) {
                Write-SetupxOutput "    • $update" $Global:SetupxColors.Gray
            }
            if ($updateLines.Count -gt 5) {
                Write-SetupxOutput "    ... and $($updateLines.Count - 5) more" $Global:SetupxColors.Gray
            }
        } else {
            Write-SetupxOutput "✅ All applications are up to date" $Global:SetupxColors.Green
        }

        # Show some popular packages
        Write-SetupxOutput "`n🌟 Popular packages you can install:" $Global:SetupxColors.Cyan
        $popularPackages = @(
            "Microsoft.VisualStudioCode - Visual Studio Code",
            "Git.Git - Git Version Control",
            "Google.Chrome - Google Chrome Browser",
            "Mozilla.Firefox - Firefox Browser",
            "Microsoft.PowerToys - Windows PowerToys",
            "7zip.7zip - 7-Zip File Archiver"
        )

        foreach ($package in $popularPackages) {
            Write-SetupxOutput "    • $package" $Global:SetupxColors.Gray
        }

    }
    catch {
        Write-SetupxOutput "⚠️  Could not retrieve WinGet information" $Global:SetupxColors.Yellow
    }
}

# Main execution logic
if ($MyInvocation.InvocationName -ne '.') {
    param(
        [ValidateSet('install', 'test', 'update', 'info')]
        [string]$Action = 'install',
        [switch]$Force,
        [switch]$SkipTest
    )

    switch ($Action.ToLower()) {
        'install' { Install-WinGet -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-WinGet }
        'update' { Update-WinGet }
        'info' { Get-WinGetInfo }
    }
}

# Export functions for module use
# Functions are available for use
