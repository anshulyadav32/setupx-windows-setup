# Yarn Installation Script
# Installs Yarn package manager

function Install-Yarn {
    <#
    .SYNOPSIS
    Installs Yarn package manager
    #>
    
    Write-Host "Installing Yarn..." -ForegroundColor Yellow
    
    # Check if Yarn is already installed
    if (Get-Command yarn -ErrorAction SilentlyContinue) {
        Write-Host "Yarn is already installed" -ForegroundColor Green
        yarn --version
        return $true
    }
    
    try {
        # Install Yarn using npm
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            Write-Host "Installing Yarn via npm..." -ForegroundColor Yellow
            npm install -g yarn
            
            Write-Host "Yarn installed successfully!" -ForegroundColor Green
            yarn --version
            return $true
        } else {
            Write-Host "npm not found. Please install Node.js first." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Failed to install Yarn: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-Yarn {
    <#
    .SYNOPSIS
    Tests if Yarn is working
    #>
    
    if (Get-Command yarn -ErrorAction SilentlyContinue) {
        Write-Host "Yarn is installed and working" -ForegroundColor Green
        yarn --version
        return $true
    } else {
        Write-Host "Yarn is not installed" -ForegroundColor Red
        return $false
    }
}

function Update-Yarn {
    <#
    .SYNOPSIS
    Updates Yarn to latest version
    #>
    
    if (Get-Command yarn -ErrorAction SilentlyContinue) {
        Write-Host "Updating Yarn..." -ForegroundColor Yellow
        npm install -g yarn@latest
        Write-Host "Yarn updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Yarn is not installed" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-Yarn
}
