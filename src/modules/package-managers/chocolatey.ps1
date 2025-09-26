# Chocolatey Installation Script
# Installs Chocolatey package manager

function Install-Chocolatey {
    <#
    .SYNOPSIS
    Installs Chocolatey package manager
    #>
    
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    
    # Check if Chocolatey is already installed
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is already installed" -ForegroundColor Green
        choco --version
        return $true
    }
    
    try {
        # Install Chocolatey
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment
        refreshenv
        
        Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
        choco --version
        return $true
    } catch {
        Write-Host "Failed to install Chocolatey: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-Chocolatey {
    <#
    .SYNOPSIS
    Tests if Chocolatey is working
    #>
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey is installed and working" -ForegroundColor Green
        choco --version
        return $true
    } else {
        Write-Host "Chocolatey is not installed" -ForegroundColor Red
        return $false
    }
}

function Update-Chocolatey {
    <#
    .SYNOPSIS
    Updates Chocolatey to latest version
    #>
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Updating Chocolatey..." -ForegroundColor Yellow
        choco upgrade chocolatey -y
        Write-Host "Chocolatey updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Chocolatey is not installed" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-Chocolatey
}
