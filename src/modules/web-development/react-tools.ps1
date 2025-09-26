# React Development Tools Installation Script
# Installs React development tools and utilities

function Install-ReactTools {
    <#
    .SYNOPSIS
    Installs React development tools
    #>
    
    Write-Host "Installing React development tools..." -ForegroundColor Yellow
    
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "npm not found. Please install Node.js first." -ForegroundColor Red
        return $false
    }
    
    try {
        # Install React development tools globally
        $tools = @(
            "create-react-app",
            "react-devtools",
            "eslint",
            "prettier"
        )
        
        foreach ($tool in $tools) {
            Write-Host "Installing $tool..." -ForegroundColor Yellow
            npm install -g $tool
        }
        
        Write-Host "React development tools installed successfully!" -ForegroundColor Green
        Write-Host "You can now create React apps with: npx create-react-app my-app" -ForegroundColor Cyan
        return $true
    } catch {
        Write-Host "Failed to install React tools: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-ReactTools {
    <#
    .SYNOPSIS
    Tests if React tools are installed
    #>
    
    $tools = @("create-react-app", "eslint", "prettier")
    $installed = 0
    
    foreach ($tool in $tools) {
        if (Get-Command $tool -ErrorAction SilentlyContinue) {
            Write-Host "$tool is installed" -ForegroundColor Green
            $installed++
        } else {
            Write-Host "$tool is not installed" -ForegroundColor Red
        }
    }
    
    Write-Host "Total React tools installed: $installed" -ForegroundColor $(if ($installed -gt 0) { "Green" } else { "Red" })
    return $installed -gt 0
}

function Update-ReactTools {
    <#
    .SYNOPSIS
    Updates React tools to latest versions
    #>
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "Updating React development tools..." -ForegroundColor Yellow
        npm update -g create-react-app react-devtools eslint prettier
        Write-Host "React tools updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "npm not found. Cannot update React tools." -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-ReactTools
}
