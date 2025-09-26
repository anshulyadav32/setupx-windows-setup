# SetupX Helper Functions
# Common utility functions used across SetupX modules

function Test-IsAdmin {
    <#
    .SYNOPSIS
    Checks if the current session is running as administrator
    #>
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-CommandExists {
    param([string]$CommandName)
    <#
    .SYNOPSIS
    Tests if a command exists in the current session
    #>
    try {
        Get-Command $CommandName -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Get-CommandVersion {
    param([string]$CommandName)
    <#
    .SYNOPSIS
    Gets the version of a command if it exists
    #>
    try {
        $version = & $CommandName --version 2>$null
        if ($version) {
            return $version
        }
    } catch {
        # Try alternative version flags
        try {
            $version = & $CommandName -v 2>$null
            if ($version) {
                return $version
            }
        } catch {
            try {
                $version = & $CommandName version 2>$null
                if ($version) {
                    return $version
                }
            } catch {
                return "Unknown"
            }
        }
    }
    return "Not installed"
}

function Invoke-SafeCommand {
    param(
        [string]$Command,
        [string]$Description = "Command"
    )
    <#
    .SYNOPSIS
    Safely executes a command with error handling
    #>
    try {
        Write-SetupxInfo "Executing: $Description"
        $result = Invoke-Expression $Command
        if ($LASTEXITCODE -eq 0) {
            Write-SetupxSuccess "$Description completed successfully"
            return $true
        } else {
            Write-SetupxError "$Description failed with exit code $LASTEXITCODE"
            return $false
        }
    } catch {
        Write-SetupxError "$Description failed: $($_.Exception.Message)"
        return $false
    }
}

function Get-SetupxConfig {
    <#
    .SYNOPSIS
    Gets SetupX configuration from config files
    #>
    $configPath = Join-Path $PSScriptRoot "..\config\setupx.json"
    if (Test-Path $configPath) {
        try {
            return Get-Content $configPath | ConvertFrom-Json
        } catch {
            Write-SetupxWarning "Failed to load config, using defaults"
        }
    }
    
    # Return default config
    return @{
        InstallPath = "C:\setupx"
        LogLevel = "INFO"
        AutoUpdate = $true
    }
}

# Export functions for use in other modules
Export-ModuleMember -Function Test-IsAdmin, Test-CommandExists, Get-CommandVersion, Invoke-SafeCommand, Get-SetupxConfig
