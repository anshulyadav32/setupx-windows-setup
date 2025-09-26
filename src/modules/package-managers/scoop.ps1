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
    
    # Check if running as Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    if ($isAdmin) {
        Write-Host "NOTE: Running as Administrator" -ForegroundColor Yellow
        Write-Host "Attempting Scoop Admin install..." -ForegroundColor Cyan

        try {
            Invoke-RestMethod -Uri https://get.scoop.sh -OutFile "$env:TEMP\install.ps1"
            & "$env:TEMP\install.ps1" -RunAsAdmin

            if (Get-Command scoop -ErrorAction SilentlyContinue) {
                Write-Host "Scoop installed successfully (Admin mode)!" -ForegroundColor Green
                scoop --version
                return $true
            }
        } catch {
            Write-Host "Failed to install Scoop in Admin mode: $($_.Exception.Message)" -ForegroundColor Red

            # Fallback: Chocolatey
            if (Get-Command choco -ErrorAction SilentlyContinue) {
                Write-Host "Attempting Scoop installation via Chocolatey..." -ForegroundColor Yellow
                try {
                    choco install scoop -y
                    if (Get-Command scoop -ErrorAction SilentlyContinue) {
                        Write-Host "Scoop installed successfully via Chocolatey!" -ForegroundColor Green
                        return $true
                    }
                } catch {
                    Write-Host "Failed to install Scoop via Chocolatey: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            return $false
        }
    } else {
        try {
            # Set execution policy
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

            # Install Scoop (user mode)
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

            # Refresh environment if available
            if (Get-Command refreshenv -ErrorAction SilentlyContinue) {
                refreshenv
            }

            Write-Host "Scoop installed successfully (User mode)!" -ForegroundColor Green
            scoop --version
            return $true
        } catch {
            Write-Host "Failed to install Scoop: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
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
