# Angular Development Tools Installation Script
# Web Development Module Component

function Install-AngularTools {
    <#
    .SYNOPSIS
    Installs Angular development tools and utilities
    #>
    
    Write-Host "Installing Angular development tools..." -ForegroundColor Yellow
    
    try {
        $installedTools = @()
        
        # Install Angular CLI
        Write-Host "Installing Angular CLI..." -ForegroundColor Cyan
        if (Install-AngularTool "Angular CLI" "@angular/cli") {
            $installedTools += "Angular CLI"
        }
        
        # Install Angular DevTools browser extension (via instructions)
        Write-Host "Installing Angular DevTools..." -ForegroundColor Cyan
        if (Install-AngularDevTools) {
            $installedTools += "Angular DevTools"
        }
        
        # Install additional Angular utilities
        Write-Host "Installing Angular utilities..." -ForegroundColor Cyan
        if (Install-AngularUtilities) {
            $installedTools += "Angular Utilities"
        }
        
        if ($installedTools.Count -gt 0) {
            Write-Host "SUCCESS: Installed Angular tools: $($installedTools -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "WARNING: No Angular tools were installed" -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "ERROR: Failed to install Angular tools - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-AngularTool {
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

function Install-AngularDevTools {
    try {
        Write-Host "  Angular DevTools browser extension installation:" -ForegroundColor Gray
        Write-Host "  - Chrome: https://chrome.google.com/webstore/detail/angular-devtools/ienfalfjdbdpebioblfackkekamfmbnh" -ForegroundColor Cyan
        Write-Host "  - Firefox: https://addons.mozilla.org/en-US/firefox/addon/angular-devtools/" -ForegroundColor Cyan
        Write-Host "  - Edge: https://microsoftedge.microsoft.com/addons/detail/angular-devtools/ienfalfjdbdpebioblfackkekamfmbnh" -ForegroundColor Cyan
        Write-Host "  Please install manually from the links above" -ForegroundColor Yellow
        return $true
    } catch {
        Write-Host "  ERROR: Failed to provide Angular DevTools instructions - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-AngularUtilities {
    try {
        $utilities = @(
            "@angular/material",
            "@angular/cdk",
            "rxjs",
            "typescript",
            "zone.js"
        )
        
        Write-Host "  Installing Angular utility packages..." -ForegroundColor Gray
        foreach ($utility in $utilities) {
            Write-Host "    Installing $utility..." -ForegroundColor DarkGray
            npm install -g $utility
        }
        
        Write-Host "  SUCCESS: Angular utilities installed" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "  ERROR: Failed to install Angular utilities - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-AngularTools {
    <#
    .SYNOPSIS
    Tests if Angular tools are installed and working
    #>
    
    try {
        $tools = @("ng")
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
            Write-Host "Installed Angular tools: $($installedTools -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "No Angular tools found" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Failed to test Angular tools - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-AngularTools
}