# Scoop Installation Script
# Installs Scoop package manager

function Install-Scoop {
    <#
    .SYNOPSIS
    Installs Scoop package manager
    #>
    
    Write-Host "Installing Scoop..." -ForegroundColor Yellow
    
    # Check if Scoop is already installed
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Scoop is already installed" -ForegroundColor Green
        scoop --version
        return $true
    }
    
    try {
        # Set execution policy
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        
        # Install Scoop
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        
        # Refresh environment
        refreshenv
        
        Write-Host "Scoop installed successfully!" -ForegroundColor Green
        scoop --version
        return $true
    } catch {
        Write-Host "Failed to install Scoop: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Note: Scoop installation may be restricted when running as Administrator" -ForegroundColor Yellow
        return $false
    }
}

function Test-Scoop {
    <#
    .SYNOPSIS
    Tests if Scoop is working
    #>
    
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Scoop is installed and working" -ForegroundColor Green
        scoop --version
        return $true
    } else {
        Write-Host "Scoop is not installed" -ForegroundColor Red
        return $false
    }
}

function Update-Scoop {
    <#
    .SYNOPSIS
    Updates Scoop to latest version
    #>
    
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Updating Scoop..." -ForegroundColor Yellow
        scoop update
        Write-Host "Scoop updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Scoop is not installed" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-Scoop
}
