# Yarn Package Manager Installation Script
# Web Development Module Component

function Install-Yarn {
    <#
    .SYNOPSIS
    Installs Yarn package manager for Node.js
    #>
    
    Write-Host "Installing Yarn package manager..." -ForegroundColor Yellow
    
    try {
        # Check if Yarn is already installed
        $yarnVersion = Get-CommandVersion "yarn"
        if ($yarnVersion -ne "Not installed") {
            Write-Host "Yarn is already installed: $yarnVersion" -ForegroundColor Green
            return $true
        }
        
        # Try to install via npm (recommended method)
        if (Get-Command "npm" -ErrorAction SilentlyContinue) {
            Write-Host "Installing Yarn via npm..." -ForegroundColor Cyan
            npm install -g yarn
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: Yarn installed via npm" -ForegroundColor Green
                refreshenv
                return $true
            }
        }
        
        # Try to install via Chocolatey
        if (Get-Command "choco" -ErrorAction SilentlyContinue) {
            Write-Host "Installing Yarn via Chocolatey..." -ForegroundColor Cyan
            choco install yarn -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: Yarn installed via Chocolatey" -ForegroundColor Green
                refreshenv
                return $true
            }
        }
        
        # Try to install via Scoop
        if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
            Write-Host "Installing Yarn via Scoop..." -ForegroundColor Cyan
            scoop install yarn
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: Yarn installed via Scoop" -ForegroundColor Green
                refreshenv
                return $true
            }
        }
        
        # Try to install via WinGet
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            Write-Host "Installing Yarn via WinGet..." -ForegroundColor Cyan
            winget install Yarn.Yarn
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: Yarn installed via WinGet" -ForegroundColor Green
                refreshenv
                return $true
            }
        }
        
        Write-Host "WARNING: Could not install Yarn automatically" -ForegroundColor Yellow
        Write-Host "Please install Yarn manually from https://yarnpkg.com/" -ForegroundColor Cyan
        return $false
        
    } catch {
        Write-Host "ERROR: Failed to install Yarn - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-Yarn {
    <#
    .SYNOPSIS
    Tests if Yarn is working correctly
    #>
    
    try {
        $yarnVersion = Get-CommandVersion "yarn"
        
        if ($yarnVersion -ne "Not installed") {
            Write-Host "Yarn: $yarnVersion" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Yarn not found" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Failed to test Yarn - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Update-Yarn {
    <#
    .SYNOPSIS
    Updates Yarn to the latest version
    #>
    
    Write-Host "Updating Yarn..." -ForegroundColor Yellow
    
    try {
        # Update via npm
        if (Get-Command "npm" -ErrorAction SilentlyContinue) {
            Write-Host "Updating Yarn via npm..." -ForegroundColor Cyan
            npm install -g yarn@latest
            
            Write-Host "SUCCESS: Yarn updated" -ForegroundColor Green
            return $true
        } else {
            Write-Host "npm not found, cannot update Yarn" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Failed to update Yarn - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-Yarn
}