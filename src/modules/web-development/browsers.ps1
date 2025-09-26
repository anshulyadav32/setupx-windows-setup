# Browsers Installation Script
# Installs modern browsers for web development

function Install-Browsers {
    <#
    .SYNOPSIS
    Installs modern browsers for web development
    #>
    
    Write-Host "Installing modern browsers..." -ForegroundColor Yellow
    
    $browsers = @(
        @{ Name = "Google Chrome"; Package = "googlechrome" },
        @{ Name = "Mozilla Firefox"; Package = "firefox" },
        @{ Name = "Microsoft Edge"; Package = "microsoft-edge" }
    )
    
    $installed = 0
    
    foreach ($browser in $browsers) {
        try {
            Write-Host "Installing $($browser.Name)..." -ForegroundColor Yellow
            
            if (Get-Command choco -ErrorAction SilentlyContinue) {
                choco install $browser.Package -y
                $installed++
                Write-Host "$($browser.Name) installed successfully!" -ForegroundColor Green
            } else {
                Write-Host "Chocolatey not found. Cannot install $($browser.Name)." -ForegroundColor Red
            }
        } catch {
            Write-Host "Failed to install $($browser.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($installed -gt 0) {
        Write-Host "Browsers installation completed! $installed browsers installed." -ForegroundColor Green
        return $true
    } else {
        Write-Host "No browsers were installed." -ForegroundColor Red
        return $false
    }
}

function Test-Browsers {
    <#
    .SYNOPSIS
    Tests if browsers are installed
    #>
    
    $browsers = @("chrome", "firefox", "msedge")
    $installed = 0
    
    foreach ($browser in $browsers) {
        if (Get-Command $browser -ErrorAction SilentlyContinue) {
            Write-Host "$browser is installed" -ForegroundColor Green
            $installed++
        } else {
            Write-Host "$browser is not installed" -ForegroundColor Red
        }
    }
    
    Write-Host "Total browsers installed: $installed" -ForegroundColor $(if ($installed -gt 0) { "Green" } else { "Red" })
    return $installed -gt 0
}

function Update-Browsers {
    <#
    .SYNOPSIS
    Updates browsers to latest versions
    #>
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Updating browsers..." -ForegroundColor Yellow
        choco upgrade all -y
        Write-Host "Browsers updated successfully!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Chocolatey not found. Cannot update browsers." -ForegroundColor Red
        return $false
    }
}

# Execute installation when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Install-Browsers
}
