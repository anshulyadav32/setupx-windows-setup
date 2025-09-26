# NPM Global Setup Script
# Configures NPM for global package installation

function Install-NPM {
    <#
    .SYNOPSIS
    Sets up NPM for global package installation
    #>
    
    Write-Host "Setting up NPM for global packages..." -ForegroundColor Yellow
    
    # Check if NPM is available
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "NPM is not installed. Please install Node.js first." -ForegroundColor Red
        Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
        return $false
    }
    
    try {
        # Configure NPM for global packages
        npm config set prefix "$env:APPDATA\npm-global"
        
        # Add to PATH if not already there
        $npmPath = "$env:APPDATA\npm-global"
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        
        if ($currentPath -notlike "*$npmPath*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$npmPath", "User")
            Write-Host "Added NPM global path to user PATH" -ForegroundColor Green
        }
        
        # Refresh environment
        refreshenv
        
        Write-Host "NPM global setup completed!" -ForegroundColor Green
        npm --version
        return $true
    } catch {
        Write-Host "Failed to setup NPM: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-NPM {
    <#
    .SYNOPSIS
    Tests if NPM is working
    #>
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "NPM is installed and working" -ForegroundColor Green
        npm --version
        return $true
    } else {
        Write-Host "NPM is not installed" -ForegroundColor Red
        return $false
    }
}

function Update-NPM {
    <#
    .SYNOPSIS
    Updates NPM to latest version
    #>
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "Updating NPM..." -ForegroundColor Yellow
        npm install -g npm@latest
        Write-Host "NPM updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "NPM is not installed" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-NPM
}
