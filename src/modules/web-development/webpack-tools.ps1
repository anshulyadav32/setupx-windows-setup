# Webpack and Build Tools Installation Script
# Installs modern build tools and bundlers

function Install-WebpackTools {
    <#
    .SYNOPSIS
    Installs webpack and build tools
    #>
    
    Write-Host "Installing webpack and build tools..." -ForegroundColor Yellow
    
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "npm not found. Please install Node.js first." -ForegroundColor Red
        return $false
    }
    
    try {
        # Install build tools globally
        $tools = @(
            "webpack",
            "webpack-cli",
            "vite",
            "parcel-bundler",
            "rollup"
        )
        
        foreach ($tool in $tools) {
            Write-Host "Installing $tool..." -ForegroundColor Yellow
            npm install -g $tool
        }
        
        Write-Host "Build tools installed successfully!" -ForegroundColor Green
        Write-Host "You can now use webpack, vite, parcel, and rollup for building projects" -ForegroundColor Cyan
        return $true
    } catch {
        Write-Host "Failed to install build tools: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-WebpackTools {
    <#
    .SYNOPSIS
    Tests if build tools are installed
    #>
    
    $tools = @("webpack", "vite", "parcel", "rollup")
    $installed = 0
    
    foreach ($tool in $tools) {
        if (Get-Command $tool -ErrorAction SilentlyContinue) {
            Write-Host "$tool is installed" -ForegroundColor Green
            $installed++
        } else {
            Write-Host "$tool is not installed" -ForegroundColor Red
        }
    }
    
    Write-Host "Total build tools installed: $installed" -ForegroundColor $(if ($installed -gt 0) { "Green" } else { "Red" })
    return $installed -gt 0
}

function Update-WebpackTools {
    <#
    .SYNOPSIS
    Updates build tools to latest versions
    #>
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "Updating build tools..." -ForegroundColor Yellow
        npm update -g webpack webpack-cli vite parcel-bundler rollup
        Write-Host "Build tools updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "npm not found. Cannot update build tools." -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-WebpackTools
}
