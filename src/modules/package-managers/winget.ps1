# WinGet Installation Script
# Installs WinGet package manager

function Install-WinGet {
    <#
    .SYNOPSIS
    Installs WinGet package manager
    #>
    
    Write-Host "Installing WinGet..." -ForegroundColor Yellow
    
    # Check if WinGet is already installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "WinGet is already installed" -ForegroundColor Green
        winget --version
        return $true
    }
    
    try {
        # WinGet is usually pre-installed on Windows 10/11
        # If not available, install from Microsoft Store
        Write-Host "WinGet should be available on Windows 10/11" -ForegroundColor Yellow
        Write-Host "If not available, install from Microsoft Store: 'App Installer'" -ForegroundColor Yellow
        
        # Try to run winget with proper error handling
        $wingetOutput = winget --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            # Refresh environment if available
            if (Get-Command refreshenv -ErrorAction SilentlyContinue) {
                refreshenv
            }
            Write-Host "WinGet is working!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "WinGet is not available. Please install 'App Installer' from Microsoft Store" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "WinGet is not available. Please install 'App Installer' from Microsoft Store" -ForegroundColor Red
        return $false
    }
}

function Test-WinGet {
    <#
    .SYNOPSIS
    Tests if WinGet is working
    #>
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "WinGet is installed and working" -ForegroundColor Green
        winget --version
        return $true
    } else {
        Write-Host "WinGet is not installed" -ForegroundColor Red
        return $false
    }
}

function Update-WinGet {
    <#
    .SYNOPSIS
    Updates WinGet to latest version
    #>
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Updating WinGet..." -ForegroundColor Yellow
        winget upgrade --all
        Write-Host "WinGet updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "WinGet is not installed" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-WinGet
}
