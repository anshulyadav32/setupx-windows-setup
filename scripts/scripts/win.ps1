# Windows environment helper with menu loop

$ErrorActionPreference = 'SilentlyContinue'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$configPath = Join-Path $repoRoot "data\win.json"
$pkgmScriptDir = Join-Path $repoRoot "data\windows\pkgm"

if (-not (Test-Path $configPath)) {
    Write-Host "Config file not found: $configPath" -ForegroundColor Red
    exit 1
}

$winConfig = Get-Content $configPath -Raw | ConvertFrom-Json

function Invoke-SafeExpression {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [string]$Context = "command"
    )

    try {
        $global:LASTEXITCODE = $null
        Invoke-Expression $Command | Out-Host
        if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            Write-Host "$Context returned exit code $LASTEXITCODE." -ForegroundColor Yellow
            return $false
        }
        return $true
    }
    catch {
        Write-Host "$Context failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-Admin {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Show-WindowsInfo {
    try {
        Write-Host "`n=== Windows Quick Info ===" -ForegroundColor Cyan
        if ($winConfig.quickInfoCommand) {
            Invoke-Expression $winConfig.quickInfoCommand | Format-Table -AutoSize
        }
        else {
            Get-CimInstance Win32_OperatingSystem |
                Select-Object Caption, Version, BuildNumber |
                Format-Table -AutoSize
        }

        Write-Host "`n=== Network / Host ===" -ForegroundColor Cyan
        Write-Host "Hostname: $(hostname)"
        ipconfig | Out-Host
    }
    catch {
        Write-Host "Failed to show Windows info: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-PackageManagerStatus {
    param([string]$Name)

    $managerScript = Join-Path $pkgmScriptDir ("{0}.ps1" -f $Name)
    if (Test-Path $managerScript) {
        try {
            & $managerScript -Action check | Out-Null
            return ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE)
        }
        catch {
            return $false
        }
    }

    $entry = $winConfig.managedManagers.$Name
    if (-not $entry) {
        return $false
    }

    if (-not $entry.checkCommand) {
        return [bool](Get-Command $Name)
    }

    return (Invoke-SafeExpression -Command $entry.checkCommand -Context "Check $Name")
}

function Show-PackageManagerStatus {
    try {
        Write-Host "`n=== Package Manager Availability ===" -ForegroundColor Cyan
        $managers = $winConfig.managedManagers.PSObject.Properties.Name

        foreach ($manager in $managers) {
            if (Get-PackageManagerStatus -Name $manager) {
                Write-Host "[OK]      $manager" -ForegroundColor Green
            }
            else {
                Write-Host "[MISSING] $manager" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "Failed to check package managers: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Install-Manager {
    param([string]$Name)

    $key = $Name.ToLower()
    $managerScript = Join-Path $pkgmScriptDir ("{0}.ps1" -f $key)

    if (Test-Path $managerScript) {
        if (Get-PackageManagerStatus -Name $key) {
            Write-Host "$key is already installed."
            return
        }

        if ($key -ne "choco" -and -not (Get-PackageManagerStatus -Name "choco")) {
            $entryBootstrap = $winConfig.managedManagers.$key
            if ($entryBootstrap -and $entryBootstrap.installCommand -match '^choco ') {
                Install-Manager -Name "choco"
                if (-not (Get-PackageManagerStatus -Name "choco")) {
                    Write-Host "$key install skipped because choco is not available." -ForegroundColor Yellow
                    return
                }
            }
        }

        Write-Host "Reconciling $key (check/install/path/update)..." -ForegroundColor Cyan
        try {
            & $managerScript -Action reconcile | Out-Host
            if ($LASTEXITCODE -ne 0) {
                Write-Host "$key reconcile failed with exit code $LASTEXITCODE" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "$key reconcile command failed." -ForegroundColor Yellow
        }
        return
    }

    $entry = $winConfig.managedManagers.$key

    if (-not $entry) {
        Write-Host "Unknown package manager: $Name" -ForegroundColor Yellow
        return
    }

    if (Get-PackageManagerStatus -Name $key) {
        Write-Host "$key is already installed."
        return
    }

    if ($entry.adminRequired -and -not (Test-Admin)) {
        Write-Host "$key install requires Administrator rights." -ForegroundColor Yellow
        return
    }

    # If install uses Chocolatey and choco is missing, install choco first.
    if ($key -ne "choco" -and $entry.installCommand -match '^choco ' -and -not (Get-PackageManagerStatus -Name "choco")) {
        Install-Manager -Name "choco"
        if (-not (Get-PackageManagerStatus -Name "choco")) {
            Write-Host "$key install skipped because choco is not available." -ForegroundColor Yellow
            return
        }
    }

    Write-Host "Installing $key..." -ForegroundColor Cyan
    $ok = Invoke-SafeExpression -Command $entry.installCommand -Context "Install $key"
    if (-not $ok) {
        Write-Host "$key install command failed." -ForegroundColor Yellow
    }
}

function Install-AllManagers {
    $managers = $winConfig.managedManagers.PSObject.Properties.Name
    foreach ($manager in $managers) {
        Write-Host "`n--- Installing $manager ---" -ForegroundColor Cyan
        Install-Manager -Name $manager
    }
}

function Show-InstallMenu {
    do {
        Write-Host "`n=== Install Menu ===" -ForegroundColor DarkCyan
        Write-Host "1) Install all package managers"
        Write-Host "2) Install one package manager"
        Write-Host "3) Back"

        $installChoice = Read-Host "Select option (1-3)"

        switch ($installChoice) {
            "1" {
                try {
                    Install-AllManagers
                    Show-PackageManagerStatus
                }
                catch {
                    Write-Host "Install all failed: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            "2" {
                try {
                    $options = ($winConfig.managedManagers.PSObject.Properties.Name -join "/")
                    $name = Read-Host "Enter manager name ($options)"
                    Install-Manager -Name $name
                    Show-PackageManagerStatus
                }
                catch {
                    Write-Host "Install one failed: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            "3" { }
            default { Write-Host "Invalid option. Choose 1-3." -ForegroundColor Yellow }
        }
    } while ($installChoice -ne "3")
}

do {
    Write-Host "`n=== Windows Package Manager Menu ===" -ForegroundColor Magenta
    Write-Host "1) Show Windows info"
    Write-Host "2) Check package managers"
    Write-Host "3) Install menu"
    Write-Host "4) Quick install all package managers"
    Write-Host "5) Exit"

    $choice = Read-Host "Select option (1-5)"

    switch ($choice) {
        "1" {
            try { Show-WindowsInfo } catch { Write-Host "Menu action failed: $($_.Exception.Message)" -ForegroundColor Red }
        }
        "2" {
            try { Show-PackageManagerStatus } catch { Write-Host "Menu action failed: $($_.Exception.Message)" -ForegroundColor Red }
        }
        "3" {
            Show-InstallMenu
        }
        "4" {
            try {
                Install-AllManagers
                Show-PackageManagerStatus
            }
            catch {
                Write-Host "Quick install all failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "5" { Write-Host "Exiting..." -ForegroundColor Green }
        default { Write-Host "Invalid option. Choose 1-5." -ForegroundColor Yellow }
    }
} while ($choice -ne "5")
