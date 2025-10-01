# SetupX Helper Utility
# Common helper functions used across SetupX

function Test-Administrator {
    <#
    .SYNOPSIS
    Checks if the current PowerShell session is running as Administrator
    #>
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-SetupxVersion {
    <#
    .SYNOPSIS
    Gets the current version of SetupX from configuration
    #>
    try {
        $configPath = Join-Path $PSScriptRoot "..\..\src\config\setupx.json"
        if (Test-Path $configPath) {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            return $config.version
        }
        return "2.0.0"
    }
    catch {
        return "Unknown"
    }
}

function Update-EnvironmentPath {
    <#
    .SYNOPSIS
    Refreshes environment variables in the current session
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$PathToAdd
    )
    
    if ($PathToAdd -and (Test-Path $PathToAdd)) {
        $env:Path += ";$PathToAdd"
        Write-SetupxInfo "Added $PathToAdd to PATH"
    }
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-SetupxInfo "Environment PATH refreshed"
}

function Test-CommandExists {
    <#
    .SYNOPSIS
    Checks if a command exists in PATH
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Invoke-RefreshEnv {
    <#
    .SYNOPSIS
    Refreshes environment variables (similar to refreshenv in Chocolatey)
    #>
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-SetupxInfo "Environment variables refreshed"
}

# Functions are available when dot-sourced

