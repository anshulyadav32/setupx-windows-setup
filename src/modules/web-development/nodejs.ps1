# Node.js Installation Script
# Installs Node.js and npm

function Install-NodeJS {
    <#
    .SYNOPSIS
    Installs Node.js and npm
    #>
    
    Write-Host "Installing Node.js and npm..." -ForegroundColor Yellow
    
    # Check if Node.js is already installed
    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Host "Node.js is already installed" -ForegroundColor Green
        node --version
        npm --version
        return $true
    }
    
    try {
        # Install Node.js using Chocolatey
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "Installing Node.js via Chocolatey..." -ForegroundColor Yellow
            choco install nodejs -y
            
            # Refresh environment
            if (Get-Command refreshenv -ErrorAction SilentlyContinue) {
                refreshenv
            }
            
            Write-Host "Node.js installed successfully!" -ForegroundColor Green
            node --version
            npm --version
            return $true
        } else {
            Write-Host "Chocolatey not found. Please install package managers first." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Failed to install Node.js: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-NodeJS {
    <#
    .SYNOPSIS
    Tests if Node.js is working
    #>
    
    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Host "Node.js is installed and working" -ForegroundColor Green
        node --version
        npm --version
        return $true
    } else {
        Write-Host "Node.js is not installed" -ForegroundColor Red
        return $false
    }
}

function Update-NodeJS {
    <#
    .SYNOPSIS
    Updates Node.js to latest version
    #>
    
    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Host "Updating Node.js..." -ForegroundColor Yellow
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            choco upgrade nodejs -y
            Write-Host "Node.js updated successfully!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Chocolatey not found. Cannot update Node.js." -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "Node.js is not installed" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-NodeJS
}
