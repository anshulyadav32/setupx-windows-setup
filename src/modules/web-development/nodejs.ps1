# Node.js & npm Installation Script
# Web Development Module Component

function Install-NodeJS {
    <#
    .SYNOPSIS
    Installs Node.js and npm for web development
    #>
    
    Write-Host "Installing Node.js and npm..." -ForegroundColor Yellow
    
    try {
        # Check if Node.js is already installed
        $nodeVersion = Get-CommandVersion "node"
        if ($nodeVersion -ne "Not installed") {
            Write-Host "Node.js is already installed: $nodeVersion" -ForegroundColor Green
            return $true
        }
        
        # Try to install via Chocolatey first
        if (Get-Command "choco" -ErrorAction SilentlyContinue) {
            Write-Host "Installing Node.js via Chocolatey..." -ForegroundColor Cyan
            choco install nodejs -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: Node.js installed via Chocolatey" -ForegroundColor Green
                refreshenv
                return $true
            }
        }
        
        # Try to install via Scoop
        if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
            Write-Host "Installing Node.js via Scoop..." -ForegroundColor Cyan
            scoop install nodejs
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: Node.js installed via Scoop" -ForegroundColor Green
                refreshenv
                return $true
            }
        }
        
        # Try to install via WinGet
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            Write-Host "Installing Node.js via WinGet..." -ForegroundColor Cyan
            winget install OpenJS.NodeJS
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: Node.js installed via WinGet" -ForegroundColor Green
                refreshenv
                return $true
            }
        }
        
        Write-Host "WARNING: Could not install Node.js automatically" -ForegroundColor Yellow
        Write-Host "Please install Node.js manually from https://nodejs.org/" -ForegroundColor Cyan
        return $false
        
    } catch {
        Write-Host "ERROR: Failed to install Node.js - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-NodeJS {
    <#
    .SYNOPSIS
    Tests if Node.js and npm are working correctly
    #>
    
    try {
        $nodeVersion = Get-CommandVersion "node"
        $npmVersion = Get-CommandVersion "npm"
        
        if ($nodeVersion -ne "Not installed" -and $npmVersion -ne "Not installed") {
            Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
            Write-Host "npm: $npmVersion" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Node.js or npm not found" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Failed to test Node.js - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Update-NodeJS {
    <#
    .SYNOPSIS
    Updates Node.js to the latest version
    #>
    
    Write-Host "Updating Node.js..." -ForegroundColor Yellow
    
    try {
        # Update via npm
        if (Get-Command "npm" -ErrorAction SilentlyContinue) {
            Write-Host "Updating npm..." -ForegroundColor Cyan
            npm install -g npm@latest
            
            Write-Host "SUCCESS: Node.js updated" -ForegroundColor Green
            return $true
        } else {
            Write-Host "npm not found, cannot update Node.js" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Failed to update Node.js - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-NodeJS
}