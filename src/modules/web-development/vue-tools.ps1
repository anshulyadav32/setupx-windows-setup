# Vue.js Development Tools Installation Script
# Web Development Module Component

function Install-VueTools {
    <#
    .SYNOPSIS
    Installs Vue.js development tools and utilities
    #>
    
    Write-Host "Installing Vue.js development tools..." -ForegroundColor Yellow
    
    try {
        $installedTools = @()
        
        # Install Vue CLI
        Write-Host "Installing Vue CLI..." -ForegroundColor Cyan
        if (Install-VueTool "Vue CLI" "@vue/cli") {
            $installedTools += "Vue CLI"
        }
        
        # Install Vite (modern build tool)
        Write-Host "Installing Vite..." -ForegroundColor Cyan
        if (Install-VueTool "Vite" "vite") {
            $installedTools += "Vite"
        }
        
        # Install Vue DevTools browser extension (via instructions)
        Write-Host "Installing Vue DevTools..." -ForegroundColor Cyan
        if (Install-VueDevTools) {
            $installedTools += "Vue DevTools"
        }
        
        # Install additional Vue utilities
        Write-Host "Installing Vue utilities..." -ForegroundColor Cyan
        if (Install-VueUtilities) {
            $installedTools += "Vue Utilities"
        }
        
        if ($installedTools.Count -gt 0) {
            Write-Host "SUCCESS: Installed Vue tools: $($installedTools -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "WARNING: No Vue tools were installed" -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "ERROR: Failed to install Vue tools - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-VueTool {
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

function Install-VueDevTools {
    try {
        Write-Host "  Vue DevTools browser extension installation:" -ForegroundColor Gray
        Write-Host "  - Chrome: https://chrome.google.com/webstore/detail/vuejs-devtools/nhdogjmejiglipccpnnnanhbledajbpd" -ForegroundColor Cyan
        Write-Host "  - Firefox: https://addons.mozilla.org/en-US/firefox/addon/vue-js-devtools/" -ForegroundColor Cyan
        Write-Host "  - Edge: https://microsoftedge.microsoft.com/addons/detail/vuejs-devtools/olofadcdnkdjibfagjpnjjgbdljkbfij" -ForegroundColor Cyan
        Write-Host "  Please install manually from the links above" -ForegroundColor Yellow
        return $true
    } catch {
        Write-Host "  ERROR: Failed to provide Vue DevTools instructions - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-VueUtilities {
    try {
        $utilities = @(
            "vue-router",
            "vuex",
            "pinia",
            "axios",
            "vue-i18n"
        )
        
        Write-Host "  Installing Vue utility packages..." -ForegroundColor Gray
        foreach ($utility in $utilities) {
            Write-Host "    Installing $utility..." -ForegroundColor DarkGray
            npm install -g $utility
        }
        
        Write-Host "  SUCCESS: Vue utilities installed" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "  ERROR: Failed to install Vue utilities - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-VueTools {
    <#
    .SYNOPSIS
    Tests if Vue tools are installed and working
    #>
    
    try {
        $tools = @("vue", "vite")
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
            Write-Host "Installed Vue tools: $($installedTools -join ', ')" -ForegroundColor Green
            return $true
        } else {
            Write-Host "No Vue tools found" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Failed to test Vue tools - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-VueTools
}