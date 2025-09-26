# setupx Component Manager - Fixed Version
# Core logic for managing modular components with smart installation

# Component status enumeration
enum ComponentStatus {
    NotInstalled
    Installed
    Outdated
    Broken
    Unknown
}

# Component result class
class ComponentResult {
    [string]$Name
    [ComponentStatus]$Status
    [string]$Version
    [string]$Message
    [bool]$Success
    [string]$TestOutput
}

# Colors for output
$Global:SetupxColors = @{
    Green = "Green"
    Red = "Red"
    Yellow = "Yellow"
    Cyan = "Cyan"
    Magenta = "Magenta"
    White = "White"
    Gray = "Gray"
}

function Write-SetupxOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )

    if ($NoNewline) {
        Write-Host $Message -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-PackageManager {
    $managers = @()

    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        $managers += "winget"
    }
    if (Get-Command "choco" -ErrorAction SilentlyContinue) {
        $managers += "choco"
    }
    if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
        $managers += "scoop"
    }

    return $managers
}

function Test-ComponentExecutable {
    param(
        [string[]]$ExecutableNames,
        [string[]]$VersionCommands,
        [string[]]$TestCommands
    )

    $result = [ComponentResult]::new()
    $result.Success = $false

    # Test executable availability
    $availableExe = $null
    foreach ($exe in $ExecutableNames) {
        if (Get-Command $exe -ErrorAction SilentlyContinue) {
            $availableExe = $exe
            break
        }
    }

    if (-not $availableExe) {
        $result.Status = [ComponentStatus]::NotInstalled
        $result.Message = "Executable not found in PATH"
        return $result
    }

    # Test version command
    if ($VersionCommands) {
        foreach ($versionCmd in $VersionCommands) {
            try {
                $versionOutput = & $versionCmd.Split(' ')[0] $versionCmd.Split(' ')[1..$versionCmd.Split(' ').Length] 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $result.Version = ($versionOutput | Out-String).Trim()
                    break
                }
            }
            catch {
                continue
            }
        }
    }

    # Test functionality
    if ($TestCommands) {
        $testPassed = $false
        foreach ($testCmd in $TestCommands) {
            try {
                $testOutput = & $testCmd.Split(' ')[0] $testCmd.Split(' ')[1..$testCmd.Split(' ').Length] 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $testPassed = $true
                    $result.TestOutput = ($testOutput | Out-String).Trim()
                    break
                }
            }
            catch {
                continue
            }
        }

        if (-not $testPassed) {
            $result.Status = [ComponentStatus]::Broken
            $result.Message = "Component executable found but not functioning properly"
            return $result
        }
    }

    $result.Status = [ComponentStatus]::Installed
    $result.Success = $true
    $result.Message = "Component is installed and working"
    return $result
}

function Test-ComponentPath {
    param(
        [string[]]$TestPaths,
        [string]$ComponentName
    )

    if (-not $TestPaths) {
        return $true
    }

    foreach ($path in $TestPaths) {
        $expandedPath = [System.Environment]::ExpandEnvironmentVariables($path)
        if (-not (Test-Path $expandedPath)) {
            Write-SetupxOutput "! Path not found: $expandedPath" $Global:SetupxColors.Yellow
            return $false
        }
    }

    return $true
}

function Install-ComponentWithPackageManager {
    param(
        [string]$ComponentName,
        [string]$WingetId,
        [string]$ChocoId,
        [string]$ScoopId,
        [string[]]$CustomInstallCommands,
        [switch]$Silent = $true
    )

    $managers = Get-PackageManager

    if ($managers.Count -eq 0) {
        throw "No package managers available. Please install Chocolatey, Scoop, or WinGet first."
    }

    foreach ($manager in $managers) {
        switch ($manager) {
            "winget" {
                if ($WingetId) {
                    try {
                        Write-SetupxOutput "Installing $ComponentName via WinGet..." $Global:SetupxColors.Yellow
                        $args = @("install", "--id", $WingetId, "--accept-source-agreements", "--accept-package-agreements")
                        if ($Silent) { $args += "--silent" }

                        & winget @args
                        if ($LASTEXITCODE -eq 0) {
                            Write-SetupxOutput "✓ $ComponentName installed via WinGet" $Global:SetupxColors.Green
                            return $true
                        }
                    }
                    catch {
                        Write-SetupxOutput "! WinGet installation failed: $($_.Exception.Message)" $Global:SetupxColors.Yellow
                    }
                }
            }
            "choco" {
                if ($ChocoId) {
                    try {
                        Write-SetupxOutput "Installing $ComponentName via Chocolatey..." $Global:SetupxColors.Yellow
                        $args = @("install", $ChocoId, "-y")
                        if ($Silent) { $args += "--no-progress" }

                        & choco @args
                        if ($LASTEXITCODE -eq 0) {
                            Write-SetupxOutput "✓ $ComponentName installed via Chocolatey" $Global:SetupxColors.Green
                            return $true
                        }
                    }
                    catch {
                        Write-SetupxOutput "! Chocolatey installation failed: $($_.Exception.Message)" $Global:SetupxColors.Yellow
                    }
                }
            }
            "scoop" {
                if ($ScoopId) {
                    try {
                        Write-SetupxOutput "Installing $ComponentName via Scoop..." $Global:SetupxColors.Yellow
                        & scoop install $ScoopId
                        if ($LASTEXITCODE -eq 0) {
                            Write-SetupxOutput "✓ $ComponentName installed via Scoop" $Global:SetupxColors.Green
                            return $true
                        }
                    }
                    catch {
                        Write-SetupxOutput "! Scoop installation failed: $($_.Exception.Message)" $Global:SetupxColors.Yellow
                    }
                }
            }
        }
    }

    # Try custom install commands as fallback
    if ($CustomInstallCommands) {
        Write-SetupxOutput "Trying custom installation commands..." $Global:SetupxColors.Yellow
        foreach ($command in $CustomInstallCommands) {
            try {
                Invoke-Expression $command
                if ($LASTEXITCODE -eq 0) {
                    Write-SetupxOutput "✓ $ComponentName installed via custom command" $Global:SetupxColors.Green
                    return $true
                }
            }
            catch {
                Write-SetupxOutput "! Custom installation failed: $($_.Exception.Message)" $Global:SetupxColors.Yellow
            }
        }
    }

    return $false
}

function Install-Component {
    param(
        [string]$ComponentName,
        [hashtable]$ComponentConfig,
        [switch]$Force,
        [switch]$SkipTest
    )

    Write-SetupxOutput "`n=== Installing Component: $ComponentName ===" $Global:SetupxColors.Cyan

    # Test current status
    if (-not $Force -and -not $SkipTest) {
        Write-SetupxOutput "Checking current installation status..." $Global:SetupxColors.White
        $testResult = Test-ComponentExecutable -ExecutableNames $ComponentConfig.executableNames -VersionCommands $ComponentConfig.versionCommands -TestCommands $ComponentConfig.testCommands

        if ($testResult.Success) {
            Write-SetupxOutput "✓ $ComponentName is already installed and working" $Global:SetupxColors.Green
            if ($testResult.Version) {
                Write-SetupxOutput "  Version: $($testResult.Version)" $Global:SetupxColors.Gray
            }
            return $testResult
        }
        elseif ($testResult.Status -eq [ComponentStatus]::Broken) {
            Write-SetupxOutput "! $ComponentName is installed but not working properly. Reinstalling..." $Global:SetupxColors.Yellow
        }
        else {
            Write-SetupxOutput "Component not found. Installing..." $Global:SetupxColors.White
        }
    }

    # Check administrator privileges if required
    if ($ComponentConfig.requiresAdmin -and -not (Test-Administrator)) {
        throw "$ComponentName requires Administrator privileges for installation"
    }

    # Install component
    $installSuccess = Install-ComponentWithPackageManager -ComponentName $ComponentName -WingetId $ComponentConfig.wingetId -ChocoId $ComponentConfig.chocoId -ScoopId $ComponentConfig.scoopId -CustomInstallCommands $ComponentConfig.installCommands

    if (-not $installSuccess) {
        $result = [ComponentResult]::new()
        $result.Name = $ComponentName
        $result.Status = [ComponentStatus]::Unknown
        $result.Success = $false
        $result.Message = "Installation failed with all available methods"
        return $result
    }

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Start-Sleep -Seconds 3

    # Verify installation
    Write-SetupxOutput "Verifying installation..." $Global:SetupxColors.White
    $verifyResult = Test-ComponentExecutable -ExecutableNames $ComponentConfig.executableNames -VersionCommands $ComponentConfig.versionCommands -TestCommands $ComponentConfig.testCommands

    if ($verifyResult.Success) {
        Write-SetupxOutput "✓ $ComponentName installation verified successfully" $Global:SetupxColors.Green
        if ($verifyResult.Version) {
            Write-SetupxOutput "  Version: $($verifyResult.Version)" $Global:SetupxColors.Gray
        }
    }
    else {
        Write-SetupxOutput "✗ Installation verification failed" $Global:SetupxColors.Red
        $verifyResult.Message = "Installation completed but verification failed"
    }

    return $verifyResult
}

function Test-Component {
    param(
        [string]$ComponentName,
        [hashtable]$ComponentConfig
    )

    Write-SetupxOutput "`n=== Testing Component: $ComponentName ===" $Global:SetupxColors.Cyan

    $result = Test-ComponentExecutable -ExecutableNames $ComponentConfig.executableNames -VersionCommands $ComponentConfig.versionCommands -TestCommands $ComponentConfig.testCommands
    $result.Name = $ComponentName

    # Additional path testing
    if ($ComponentConfig.testPaths) {
        $pathsValid = Test-ComponentPath -TestPaths $ComponentConfig.testPaths -ComponentName $ComponentName
        if (-not $pathsValid -and $result.Success) {
            $result.Status = [ComponentStatus]::Broken
            $result.Success = $false
            $result.Message += " (Required paths missing)"
        }
    }

    # Display results
    switch ($result.Status) {
        ([ComponentStatus]::NotInstalled) {
            Write-SetupxOutput "✗ $ComponentName is not installed" $Global:SetupxColors.Red
        }
        ([ComponentStatus]::Installed) {
            Write-SetupxOutput "✓ $ComponentName is installed and working" $Global:SetupxColors.Green
            if ($result.Version) {
                Write-SetupxOutput "  Version: $($result.Version)" $Global:SetupxColors.Gray
            }
        }
        ([ComponentStatus]::Broken) {
            Write-SetupxOutput "⚠ $ComponentName is installed but not functioning properly" $Global:SetupxColors.Yellow
        }
        ([ComponentStatus]::Outdated) {
            Write-SetupxOutput "! $ComponentName is installed but may be outdated" $Global:SetupxColors.Yellow
        }
        default {
            Write-SetupxOutput "? $ComponentName status is unknown" $Global:SetupxColors.Gray
        }
    }

    if ($result.Message) {
        Write-SetupxOutput "  $($result.Message)" $Global:SetupxColors.Gray
    }

    return $result
}

function Update-Component {
    param(
        [string]$ComponentName,
        [hashtable]$ComponentConfig
    )

    Write-SetupxOutput "`n=== Updating Component: $ComponentName ===" $Global:SetupxColors.Cyan

    $managers = Get-PackageManager
    $updated = $false

    foreach ($manager in $managers) {
        switch ($manager) {
            "winget" {
                if ($ComponentConfig.wingetId) {
                    try {
                        & winget upgrade --id $ComponentConfig.wingetId --silent
                        if ($LASTEXITCODE -eq 0) {
                            Write-SetupxOutput "✓ $ComponentName updated via WinGet" $Global:SetupxColors.Green
                            $updated = $true
                            break
                        }
                    }
                    catch {
                        Write-SetupxOutput "! WinGet update failed" $Global:SetupxColors.Yellow
                    }
                }
            }
            "choco" {
                if ($ComponentConfig.chocoId) {
                    try {
                        & choco upgrade $ComponentConfig.chocoId -y
                        if ($LASTEXITCODE -eq 0) {
                            Write-SetupxOutput "✓ $ComponentName updated via Chocolatey" $Global:SetupxColors.Green
                            $updated = $true
                            break
                        }
                    }
                    catch {
                        Write-SetupxOutput "! Chocolatey update failed" $Global:SetupxColors.Yellow
                    }
                }
            }
            "scoop" {
                if ($ComponentConfig.scoopId) {
                    try {
                        & scoop update $ComponentConfig.scoopId
                        if ($LASTEXITCODE -eq 0) {
                            Write-SetupxOutput "✓ $ComponentName updated via Scoop" $Global:SetupxColors.Green
                            $updated = $true
                            break
                        }
                    }
                    catch {
                        Write-SetupxOutput "! Scoop update failed" $Global:SetupxColors.Yellow
                    }
                }
            }
        }
    }

    if (-not $updated) {
        Write-SetupxOutput "! Could not update $ComponentName. Try reinstalling." $Global:SetupxColors.Yellow
        return $false
    }

    # Verify update
    Start-Sleep -Seconds 3
    $verifyResult = Test-Component -ComponentName $ComponentName -ComponentConfig $ComponentConfig
    return $verifyResult.Success
}

# Export functions
Export-ModuleMember -Function Test-Component, Install-Component, Update-Component, Test-ComponentExecutable, Test-ComponentPath
