# Angular Development Tools Installation Script
# Installs Angular development tools and utilities

function Install-AngularTools {
    <#
    .SYNOPSIS
    Installs Angular development tools
    #>
    
    Write-Host "Installing Angular development tools..." -ForegroundColor Yellow
    
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "npm not found. Please install Node.js first." -ForegroundColor Red
        return $false
    }
    
    try {
        # Install Angular CLI globally
        Write-Host "Installing Angular CLI..." -ForegroundColor Yellow
        npm install -g @angular/cli
        
        Write-Host "Angular development tools installed successfully!" -ForegroundColor Green
        Write-Host "You can now create Angular apps with: ng new my-app" -ForegroundColor Cyan
        return $true
    } catch {
        Write-Host "Failed to install Angular tools: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-AngularTools {
    <#
    .SYNOPSIS
    Tests if Angular tools are installed
    #>
    
    if (Get-Command ng -ErrorAction SilentlyContinue) {
        Write-Host "Angular CLI is installed" -ForegroundColor Green
        ng version
        return $true
    } else {
        Write-Host "Angular CLI is not installed" -ForegroundColor Red
        return $false
    }
}

function Update-AngularTools {
    <#
    .SYNOPSIS
    Updates Angular tools to latest versions
    #>
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "Updating Angular development tools..." -ForegroundColor Yellow
        npm update -g @angular/cli
        Write-Host "Angular tools updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "npm not found. Cannot update Angular tools." -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-AngularTools
}
