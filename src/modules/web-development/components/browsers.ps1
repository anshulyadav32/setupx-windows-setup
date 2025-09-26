# Modern Browsers Component for setupx
# Installs Chrome, Firefox, and Edge browsers for web development testing

# Component configuration
$ComponentConfig = @{
    name = "browsers"
    displayName = "Modern Browsers"
    description = "Chrome, Firefox, and Edge browsers for testing"

    # Executables to test (multiple browsers)
    executableNames = @("chrome.exe", "firefox.exe", "msedge.exe")

    # Version commands (different for each browser)
    versionCommands = @()

    # Test commands (check if browsers can be launched)
    testCommands = @()

    # Package manager IDs for each browser
    browsers = @{
        chrome = @{
            name = "Google Chrome"
            wingetId = "Google.Chrome"
            chocoId = "googlechrome"
            testPath = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
            testPathAlt = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
        }
        firefox = @{
            name = "Mozilla Firefox"
            wingetId = "Mozilla.Firefox"
            chocoId = "firefox"
            testPath = "${env:ProgramFiles}\Mozilla Firefox\firefox.exe"
            testPathAlt = "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe"
        }
        edge = @{
            name = "Microsoft Edge"
            wingetId = "Microsoft.Edge"
            chocoId = "microsoft-edge"
            testPath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
            testPathAlt = "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe"
        }
    }

    # Installation settings
    requiresAdmin = $true
    category = "tools"

    # Test paths
    testPaths = @()
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-Browsers {
    param([switch]$Force, [switch]$SkipTest)

    Write-SetupxOutput "`n🌐 Installing Modern Browsers for Web Development" $Global:SetupxColors.Blue

    $results = @()
    $browsersToInstall = @()

    # Check current status of each browser
    if (-not $Force -and -not $SkipTest) {
        Write-SetupxOutput "Checking installed browsers..." $Global:SetupxColors.White

        foreach ($browserKey in $ComponentConfig.browsers.Keys) {
            $browser = $ComponentConfig.browsers[$browserKey]
            $installed = Test-BrowserInstalled -Browser $browser

            if ($installed) {
                Write-SetupxOutput "✅ $($browser.name) is already installed" $Global:SetupxColors.Green
            } else {
                Write-SetupxOutput "❌ $($browser.name) not found" $Global:SetupxColors.Red
                $browsersToInstall += $browserKey
            }
        }

        if ($browsersToInstall.Count -eq 0) {
            $result = [ComponentResult]::new()
            $result.Name = $ComponentConfig.displayName
            $result.Success = $true
            $result.Status = [ComponentStatus]::Installed
            $result.Message = "All browsers are already installed"
            return $result
        }
    } else {
        $browsersToInstall = $ComponentConfig.browsers.Keys
    }

    # Check administrator privileges
    if (-not (Test-Administrator)) {
        throw "Browser installation requires Administrator privileges"
    }

    Write-SetupxOutput "`nInstalling browsers: $($browsersToInstall -join ', ')" $Global:SetupxColors.Cyan

    # Install each browser
    foreach ($browserKey in $browsersToInstall) {
        $browser = $ComponentConfig.browsers[$browserKey]

        Write-SetupxOutput "`nInstalling $($browser.name)..." $Global:SetupxColors.Yellow

        $installed = Install-SingleBrowser -Browser $browser
        if ($installed) {
            Write-SetupxOutput "✅ $($browser.name) installed successfully" $Global:SetupxColors.Green
        } else {
            Write-SetupxOutput "✗ Failed to install $($browser.name)" $Global:SetupxColors.Red
        }
    }

    # Wait for installations to complete
    Start-Sleep -Seconds 5

    # Verify installations
    Write-SetupxOutput "`n=== Verifying Browser Installations ===" $Global:SetupxColors.Cyan
    $installedCount = 0
    $totalBrowsers = $ComponentConfig.browsers.Keys.Count

    foreach ($browserKey in $ComponentConfig.browsers.Keys) {
        $browser = $ComponentConfig.browsers[$browserKey]
        $installed = Test-BrowserInstalled -Browser $browser

        if ($installed) {
            Write-SetupxOutput "✅ $($browser.name) verified" $Global:SetupxColors.Green
            $installedCount++
        } else {
            Write-SetupxOutput "✗ $($browser.name) verification failed" $Global:SetupxColors.Red
        }
    }

    # Create result
    $result = [ComponentResult]::new()
    $result.Name = $ComponentConfig.displayName
    $result.Success = $installedCount -gt 0
    $result.Status = if ($installedCount -eq $totalBrowsers) { [ComponentStatus]::Installed }
                    elseif ($installedCount -gt 0) { [ComponentStatus]::Broken }
                    else { [ComponentStatus]::NotInstalled }
    $result.Message = "$installedCount of $totalBrowsers browsers installed"

    if ($result.Success) {
        Write-SetupxOutput "`n✅ Browser installation completed!" $Global:SetupxColors.Green
        Write-SetupxOutput "📋 Installed browsers:" $Global:SetupxColors.Cyan

        foreach ($browserKey in $ComponentConfig.browsers.Keys) {
            $browser = $ComponentConfig.browsers[$browserKey]
            if (Test-BrowserInstalled -Browser $browser) {
                Write-SetupxOutput "  • $($browser.name)" $Global:SetupxColors.White
            }
        }

        Write-SetupxOutput "`n💡 Web Development Tips:" $Global:SetupxColors.Cyan
        Write-SetupxOutput "  • Use Chrome DevTools for debugging and performance analysis" $Global:SetupxColors.White
        Write-SetupxOutput "  • Firefox has excellent CSS Grid and Flexbox inspection tools" $Global:SetupxColors.White
        Write-SetupxOutput "  • Edge has great accessibility testing features" $Global:SetupxColors.White
        Write-SetupxOutput "  • Test your websites across all browsers for compatibility" $Global:SetupxColors.White
        Write-SetupxOutput "  • Consider installing browser extensions for development" $Global:SetupxColors.White

        Write-SetupxOutput "`n🔧 Recommended Extensions:" $Global:SetupxColors.Cyan
        Write-SetupxOutput "  • React Developer Tools" $Global:SetupxColors.White
        Write-SetupxOutput "  • Vue.js DevTools" $Global:SetupxColors.White
        Write-SetupxOutput "  • Redux DevTools" $Global:SetupxColors.White
        Write-SetupxOutput "  • Lighthouse (built into Chrome)" $Global:SetupxColors.White
    }

    return $result
}

function Install-SingleBrowser {
    param([hashtable]$Browser)

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            winget install --id $Browser.wingetId --silent --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
        }
        catch {
            Write-SetupxOutput "! WinGet installation failed for $($Browser.name)" $Global:SetupxColors.Yellow
        }
    }

    # Try Chocolatey as fallback
    if (Get-Command "choco" -ErrorAction SilentlyContinue) {
        try {
            choco install $Browser.chocoId -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
        }
        catch {
            Write-SetupxOutput "! Chocolatey installation failed for $($Browser.name)" $Global:SetupxColors.Yellow
        }
    }

    return $false
}

function Test-BrowserInstalled {
    param([hashtable]$Browser)

    # Test primary path
    $expandedPath = [System.Environment]::ExpandEnvironmentVariables($Browser.testPath)
    if (Test-Path $expandedPath) {
        return $true
    }

    # Test alternative path
    if ($Browser.testPathAlt) {
        $expandedAltPath = [System.Environment]::ExpandEnvironmentVariables($Browser.testPathAlt)
        if (Test-Path $expandedAltPath) {
            return $true
        }
    }

    # Try to find in PATH
    $exeName = Split-Path $Browser.testPath -Leaf
    if (Get-Command $exeName -ErrorAction SilentlyContinue) {
        return $true
    }

    return $false
}

function Test-Browsers {
    Write-SetupxOutput "`n🧪 Testing Browser Installations" $Global:SetupxColors.Cyan

    $installedBrowsers = @()
    $missingBrowsers = @()

    foreach ($browserKey in $ComponentConfig.browsers.Keys) {
        $browser = $ComponentConfig.browsers[$browserKey]
        $installed = Test-BrowserInstalled -Browser $browser

        if ($installed) {
            Write-SetupxOutput "✅ $($browser.name) is installed" $Global:SetupxColors.Green
            $installedBrowsers += $browser.name

            # Try to get version info
            try {
                $exePath = [System.Environment]::ExpandEnvironmentVariables($browser.testPath)
                if (-not (Test-Path $exePath) -and $browser.testPathAlt) {
                    $exePath = [System.Environment]::ExpandEnvironmentVariables($browser.testPathAlt)
                }

                if (Test-Path $exePath) {
                    $versionInfo = (Get-ItemProperty $exePath).VersionInfo
                    if ($versionInfo.FileVersion) {
                        Write-SetupxOutput "  Version: $($versionInfo.FileVersion)" $Global:SetupxColors.Gray
                    }
                }
            }
            catch {
                # Version check failed, but browser is installed
            }
        } else {
            Write-SetupxOutput "❌ $($browser.name) not found" $Global:SetupxColors.Red
            $missingBrowsers += $browser.name
        }
    }

    # Create result
    $result = [ComponentResult]::new()
    $result.Name = $ComponentConfig.displayName
    $result.Success = $installedBrowsers.Count -gt 0

    if ($installedBrowsers.Count -eq $ComponentConfig.browsers.Keys.Count) {
        $result.Status = [ComponentStatus]::Installed
        $result.Message = "All browsers are installed and accessible"
    }
    elseif ($installedBrowsers.Count -gt 0) {
        $result.Status = [ComponentStatus]::Broken
        $result.Message = "Some browsers are missing: $($missingBrowsers -join ', ')"
    }
    else {
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "No browsers are installed"
    }

    Write-SetupxOutput "`n📊 Browser Status:" $Global:SetupxColors.Cyan
    Write-SetupxOutput "  Installed: $($installedBrowsers.Count)/$($ComponentConfig.browsers.Keys.Count)" $Global:SetupxColors.White
    if ($installedBrowsers.Count -gt 0) {
        Write-SetupxOutput "  Available: $($installedBrowsers -join ', ')" $Global:SetupxColors.Green
    }
    if ($missingBrowsers.Count -gt 0) {
        Write-SetupxOutput "  Missing: $($missingBrowsers -join ', ')" $Global:SetupxColors.Red
    }

    return $result
}

function Update-Browsers {
    Write-SetupxOutput "`n🔄 Updating Browsers" $Global:SetupxColors.Cyan

    $updated = 0

    foreach ($browserKey in $ComponentConfig.browsers.Keys) {
        $browser = $ComponentConfig.browsers[$browserKey]

        if (Test-BrowserInstalled -Browser $browser) {
            Write-SetupxOutput "Updating $($browser.name)..." $Global:SetupxColors.White

            # Try WinGet update first
            if (Get-Command "winget" -ErrorAction SilentlyContinue) {
                try {
                    winget upgrade --id $browser.wingetId --silent
                    if ($LASTEXITCODE -eq 0) {
                        Write-SetupxOutput "✅ $($browser.name) updated via WinGet" $Global:SetupxColors.Green
                        $updated++
                        continue
                    }
                }
                catch { }
            }

            # Try Chocolatey update
            if (Get-Command "choco" -ErrorAction SilentlyContinue) {
                try {
                    choco upgrade $browser.chocoId -y
                    if ($LASTEXITCODE -eq 0) {
                        Write-SetupxOutput "✅ $($browser.name) updated via Chocolatey" $Global:SetupxColors.Green
                        $updated++
                        continue
                    }
                }
                catch { }
            }

            Write-SetupxOutput "! Could not update $($browser.name) - try updating manually" $Global:SetupxColors.Yellow
        } else {
            Write-SetupxOutput "⚠️  $($browser.name) not installed - skipping update" $Global:SetupxColors.Yellow
        }
    }

    Write-SetupxOutput "✅ Browser updates completed. $updated browsers updated." $Global:SetupxColors.Green
    return $updated -gt 0
}

# Main execution logic
if ($MyInvocation.InvocationName -ne '.') {
    param(
        [ValidateSet('install', 'test', 'update')]
        [string]$Action = 'install',
        [switch]$Force,
        [switch]$SkipTest
    )

    switch ($Action.ToLower()) {
        'install' { Install-Browsers -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-Browsers }
        'update' { Update-Browsers }
    }
}

# Export functions for module use
Export-ModuleMember -Function Install-Browsers, Test-Browsers, Update-Browsers