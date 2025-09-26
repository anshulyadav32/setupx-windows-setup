# Vue.js Development Tools Installation Script
# Installs Vue.js development tools and utilities

function Install-VueTools {
    <#
    .SYNOPSIS
    Installs Vue.js development tools
    #>
    
    Write-Host "Installing Vue.js development tools..." -ForegroundColor Yellow
    
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "npm not found. Please install Node.js first." -ForegroundColor Red
        return $false
    }
    
    try {
        # Install Vue.js development tools globally
        $tools = @(
            "@vue/cli",
            "vue-devtools"
        )
        
        foreach ($tool in $tools) {
            Write-Host "Installing $tool..." -ForegroundColor Yellow
            npm install -g $tool
        }
        
        Write-Host "Vue.js development tools installed successfully!" -ForegroundColor Green
        Write-Host "You can now create Vue apps with: npm init vue@latest my-project" -ForegroundColor Cyan
        return $true
    } catch {
        Write-Host "Failed to install Vue tools: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-VueTools {
    <#
    .SYNOPSIS
    Tests if Vue tools are installed
    #>
    
    if (Get-Command vue -ErrorAction SilentlyContinue) {
        Write-Host "Vue CLI is installed" -ForegroundColor Green
        vue --version
        return $true
    } else {
        Write-Host "Vue CLI is not installed" -ForegroundColor Red
        return $false
    }
}

function Update-VueTools {
    <#
    .SYNOPSIS
    Updates Vue tools to latest versions
    #>
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "Updating Vue.js development tools..." -ForegroundColor Yellow
        npm update -g @vue/cli vue-devtools
        Write-Host "Vue tools updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "npm not found. Cannot update Vue tools." -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-VueTools
}
