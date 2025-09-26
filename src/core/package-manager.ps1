# SetupX Package Manager
# Handles package manager detection, installation, and status checking

# Import dependencies
. "$PSScriptRoot\..\utils\logger.ps1"
. "$PSScriptRoot\..\utils\helpers.ps1"

function Get-PackageManagerStatus {
    <#
    .SYNOPSIS
    Gets the status of all package managers
    #>
    $status = @{
        WinGet = @{
            Name = "WinGet"
            Description = "Microsoft Official"
            Installed = $false
            Version = "Not installed"
        }
        Chocolatey = @{
            Name = "Chocolatey"
            Description = "Community Package Manager"
            Installed = $false
            Version = "Not installed"
        }
        Scoop = @{
            Name = "Scoop"
            Description = "Portable Apps Manager"
            Installed = $false
            Version = "Not installed"
        }
        NPM = @{
            Name = "NPM"
            Description = "Node Package Manager"
            Installed = $false
            Version = "Not installed"
        }
    }
    
    # Check WinGet
    if (Test-CommandExists "winget") {
        $status.WinGet.Installed = $true
        $status.WinGet.Version = Get-CommandVersion "winget"
    }
    
    # Check Chocolatey
    if (Test-CommandExists "choco") {
        $status.Chocolatey.Installed = $true
        $status.Chocolatey.Version = Get-CommandVersion "choco"
    }
    
    # Check Scoop
    if (Test-CommandExists "scoop") {
        $status.Scoop.Installed = $true
        $status.Scoop.Version = Get-CommandVersion "scoop"
    }
    
    # Check NPM
    if (Test-CommandExists "npm") {
        $status.NPM.Installed = $true
        $status.NPM.Version = Get-CommandVersion "npm"
    }
    
    return $status
}

function Show-PackageManagerStatus {
    <#
    .SYNOPSIS
    Displays the status of all package managers
    #>
    $status = Get-PackageManagerStatus
    
    Write-SetupxInfo "Package Manager Status:"
    Write-Host ""
    
    foreach ($manager in $status.GetEnumerator()) {
        $name = $manager.Value.Name
        $description = $manager.Value.Description
        $installed = $manager.Value.Installed
        $version = $manager.Value.Version
        
        if ($installed) {
            Write-Host "✅ $name ($description)" -ForegroundColor Green
            Write-Host "   Version: $version" -ForegroundColor White
        } else {
            Write-Host "❌ $name ($description)" -ForegroundColor Red
            Write-Host "   Status: Not installed" -ForegroundColor Yellow
        }
        Write-Host ""
    }
}

function Install-PackageManager {
    param([string]$ManagerName)
    <#
    .SYNOPSIS
    Installs a specific package manager
    #>
    switch ($ManagerName.ToLower()) {
        "winget" {
            Write-SetupxInfo "WinGet is usually pre-installed on Windows 10/11"
            Write-SetupxInfo "If not available, install from Microsoft Store"
        }
        "chocolatey" {
            Write-SetupxInfo "Installing Chocolatey..."
            $installScript = @"
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
"@
            Invoke-SafeCommand $installScript "Chocolatey Installation"
        }
        "scoop" {
            Write-SetupxInfo "Installing Scoop..."
            if (Test-IsAdmin) {
                Write-SetupxWarning "Running as Administrator - Scoop installation may be restricted"
                Write-SetupxInfo "For best results, run as regular user"
            }
            $env:SCOOP_ALLOW_ADMIN_INSTALL = "true"
            Invoke-SafeCommand "Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression" "Scoop Installation"
        }
        "npm" {
            Write-SetupxInfo "Installing Node.js and NPM..."
            Write-SetupxInfo "Please install Node.js from https://nodejs.org or use:"
            Write-SetupxInfo "  choco install nodejs"
            Write-SetupxInfo "  winget install OpenJS.NodeJS"
        }
        default {
            Write-SetupxError "Unknown package manager: $ManagerName"
        }
    }
}

# Export functions for use in other modules
Export-ModuleMember -Function Get-PackageManagerStatus, Show-PackageManagerStatus, Install-PackageManager
