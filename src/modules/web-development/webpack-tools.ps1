# Build Tools (Webpack, Vite) Installation Script
# Web Development Module Component

function Install-WebpackTools {
    <#
    .SYNOPSIS
    Installs modern build tools and bundlers
    #>
    
    Write-Host "Installing build tools and bundlers..." -ForegroundColor Yellow
    
    try {
        $installedTools = @()
        
        # Install Webpack
        Write-Host "Installing Webpack..." -ForegroundColor Cyan
        if (Install-BuildTool "Webpack" "webpack") {
            $installedTools += "Webpack"
        }
        
        # Install Vite
        Write-Host "Installing Vite..." -ForegroundColor Cyan
        if (Install-BuildTool "Vite" "vite") {
            $installedTools += "Vite"
        }
        
        # Install Rollup
        Write-Host "Installing Rollup..." -ForegroundColor Cyan
        if (Install-BuildTool "Rollup" "rollup") {
            $installedTools += "Rollup"
        }
        
        # Install Parcel
        Write-Host "Installing Parcel..." -ForegroundColor Cyan
        if (Install-BuildTool "Parcel" "parcel") {
            $installedTools += "Parcel"
        }
        
        # Install additional build utilities
        Write-Host "Installing build utilities..." -ForegroundColor Cyan
        if (Install-BuildUtilities) {
            $installedTools += "Build Utilities"
        }
        
        if ($installedTools.Count -gt 0) {
            Write-Host "SUCCESS: Installed build tools: $($installedTools -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "WARNING: No build tools were installed" -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "ERROR: Failed to install build tools - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-BuildTool {
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

function Install-BuildUtilities {
    try {
        $utilities = @(
            "webpack-cli",
            "webpack-dev-server",
            "terser",
            "css-loader",
            "style-loader",
            "babel-loader",
            "eslint",
            "prettier"
        )
        
        Write-Host "  Installing build utility packages..." -ForegroundColor Gray
        foreach ($utility in $utilities) {
            Write-Host "    Installing $utility..." -ForegroundColor DarkGray
            npm install -g $utility
        }
        
        Write-Host "  SUCCESS: Build utilities installed" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "  ERROR: Failed to install build utilities - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-WebpackTools {
    <#
    .SYNOPSIS
    Tests if build tools are installed and working
    #>
    
    try {
        $tools = @("webpack", "vite", "rollup", "parcel")
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
            Write-Host "Installed build tools: $($installedTools -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "No build tools found" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Failed to test build tools - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-WebpackTools
}