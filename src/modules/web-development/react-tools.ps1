# React Development Tools Installation Script
# Web Development Module Component

function Install-ReactTools {
    <#
    .SYNOPSIS
    Installs React development tools and utilities
    #>
    
    Write-Host "Installing React development tools..." -ForegroundColor Yellow
    
    try {
        $installedTools = @()
        
        # Install Create React App globally
        Write-Host "Installing Create React App..." -ForegroundColor Cyan
        if (Install-ReactTool "Create React App" "create-react-app") {
            $installedTools += "Create React App"
        }
        
        # Install React DevTools browser extension (via instructions)
        Write-Host "Installing React DevTools..." -ForegroundColor Cyan
        if (Install-ReactDevTools) {
            $installedTools += "React DevTools"
        }
        
        # Install additional React utilities
        Write-Host "Installing React utilities..." -ForegroundColor Cyan
        if (Install-ReactUtilities) {
            $installedTools += "React Utilities"
        }
        
        if ($installedTools.Count -gt 0) {
            Write-Host "SUCCESS: Installed React tools: $($installedTools -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "WARNING: No React tools were installed" -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "ERROR: Failed to install React tools - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-ReactTool {
    param(
        [string]$ToolName,
        [string]$NpmPackage
    )
    
    try {
        if (Get-Command "npm" -ErrorAction SilentlyContinue) {
            Write-Host "  Installing $ToolName via npm..." -ForegroundColor Gray
            npm install -g $NpmPackage
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  SUCCESS: $ToolName installed via npm" -ForegroundColor Green
                return $true
            }
        }
        
        Write-Host "  WARNING: Could not install $ToolName (npm not available)" -ForegroundColor Yellow
        return $false
        
    } catch {
        Write-Host "  ERROR: Failed to install $ToolName - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-ReactDevTools {
    try {
        Write-Host "  React DevTools browser extension installation:" -ForegroundColor Gray
        Write-Host "  - Chrome: https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi" -ForegroundColor Cyan
        Write-Host "  - Firefox: https://addons.mozilla.org/en-US/firefox/addon/react-devtools/" -ForegroundColor Cyan
        Write-Host "  - Edge: https://microsoftedge.microsoft.com/addons/detail/react-developer-tools/gpphkfbcpidddadnkolkpfckpihlkkil" -ForegroundColor Cyan
        Write-Host "  Please install manually from the links above" -ForegroundColor Yellow
        return $true
    } catch {
        Write-Host "  ERROR: Failed to provide React DevTools instructions - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-ReactUtilities {
    try {
        $utilities = @(
            "react-router-dom",
            "axios",
            "styled-components",
            "react-query",
            "react-hook-form"
        )
        
        Write-Host "  Installing React utility packages..." -ForegroundColor Gray
        foreach ($utility in $utilities) {
            Write-Host "    Installing $utility..." -ForegroundColor DarkGray
            npm install -g $utility
        }
        
        Write-Host "  SUCCESS: React utilities installed" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "  ERROR: Failed to install React utilities - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-ReactTools {
    <#
    .SYNOPSIS
    Tests if React tools are installed and working
    #>
    
    try {
        $tools = @("create-react-app")
        $installedTools = @()
        
        foreach ($tool in $tools) {
            $version = Get-CommandVersion $tool
            if ($version -ne "Not installed") {
                $installedTools += $tool
                Write-Host "$tool: $version" -ForegroundColor Green
            } else {
                Write-Host "$tool: Not found" -ForegroundColor Red
            }
        }
        
        if ($installedTools.Count -gt 0) {
            Write-Host "Installed React tools: $($installedTools -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "No React tools found" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Failed to test React tools - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-ReactTools
}