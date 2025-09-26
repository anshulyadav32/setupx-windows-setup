# Modern Browsers Installation Script
# Web Development Module Component

function Install-Browsers {
    <#
    .SYNOPSIS
    Installs modern browsers for web development and testing
    #>
    
    Write-Host "Installing modern browsers..." -ForegroundColor Yellow
    
    try {
        $installedBrowsers = @()
        
        # Install Google Chrome
        Write-Host "Installing Google Chrome..." -ForegroundColor Cyan
        if (Install-Browser "Google Chrome" "Google.Chrome") {
            $installedBrowsers += "Chrome"
        }
        
        # Install Mozilla Firefox
        Write-Host "Installing Mozilla Firefox..." -ForegroundColor Cyan
        if (Install-Browser "Mozilla Firefox" "Mozilla.Firefox") {
            $installedBrowsers += "Firefox"
        }
        
        # Install Microsoft Edge (usually pre-installed on Windows 10/11)
        Write-Host "Checking Microsoft Edge..." -ForegroundColor Cyan
        if (Test-Browser "Microsoft Edge") {
            $installedBrowsers += "Edge"
        } else {
            Write-Host "Microsoft Edge not found (may need manual installation)" -ForegroundColor Yellow
        }
        
        if ($installedBrowsers.Count -gt 0) {
            Write-Host "SUCCESS: Installed browsers: $($installedBrowsers -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "WARNING: No browsers were installed automatically" -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "ERROR: Failed to install browsers - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-Browser {
    param(
        [string]$BrowserName,
        [string]$WinGetPackage
    )
    
    try {
        # Try WinGet first
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            Write-Host "  Installing $BrowserName via WinGet..." -ForegroundColor Gray
            winget install $WinGetPackage --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  SUCCESS: $BrowserName installed via WinGet" -ForegroundColor Green
                return $true
            }
        }
        
        # Try Chocolatey
        if (Get-Command "choco" -ErrorAction SilentlyContinue) {
            Write-Host "  Installing $BrowserName via Chocolatey..." -ForegroundColor Gray
            $chocoPackage = switch ($BrowserName) {
                "Google Chrome" { "googlechrome" }
                "Mozilla Firefox" { "firefox" }
                default { $BrowserName.ToLower() }
            }
            choco install $chocoPackage -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  SUCCESS: $BrowserName installed via Chocolatey" -ForegroundColor Green
                return $true
            }
        }
        
        # Try Scoop
        if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
            Write-Host "  Installing $BrowserName via Scoop..." -ForegroundColor Gray
            $scoopPackage = switch ($BrowserName) {
                "Google Chrome" { "googlechrome" }
                "Mozilla Firefox" { "firefox" }
                default { $BrowserName.ToLower() }
            }
            scoop install $scoopPackage
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  SUCCESS: $BrowserName installed via Scoop" -ForegroundColor Green
                return $true
            }
        }
        
        Write-Host "  WARNING: Could not install $BrowserName automatically" -ForegroundColor Yellow
        return $false
        
    } catch {
        Write-Host "  ERROR: Failed to install $BrowserName - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-Browser {
    param([string]$BrowserName)
    
    try {
        $browserPath = switch ($BrowserName) {
            "Google Chrome" { "C:\Program Files\Google\Chrome\Application\chrome.exe" }
            "Mozilla Firefox" { "C:\Program Files\Mozilla Firefox\firefox.exe" }
            "Microsoft Edge" { "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" }
            default { $null }
        }
        
        if ($browserPath -and (Test-Path $browserPath)) {
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

function Test-Browsers {
    <#
    .SYNOPSIS
    Tests if browsers are installed and working
    #>
    
    try {
        $browsers = @("Google Chrome", "Mozilla Firefox", "Microsoft Edge")
        $installedBrowsers = @()
        
        foreach ($browser in $browsers) {
            if (Test-Browser $browser) {
                $installedBrowsers += $browser
                Write-Host "$browser: Installed" -ForegroundColor Green
            } else {
                Write-Host "$browser: Not found" -ForegroundColor Red
            }
        }
        
        if ($installedBrowsers.Count -gt 0) {
            Write-Host "Installed browsers: $($installedBrowsers -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "No browsers found" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Failed to test browsers - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-Browsers
}