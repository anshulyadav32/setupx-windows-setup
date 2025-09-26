# Chocolatey Component for setupx
# Installs and configures Chocolatey package manager

# Component configuration
$ComponentConfig = @{
    name = "chocolatey"
    displayName = "Chocolatey"
    description = "The package manager for Windows"

    # Executables to test
    executableNames = @("choco.exe", "choco")

    # Version commands
    versionCommands = @("choco --version")

    # Test commands
    testCommands = @(
        "choco --version",
        "choco search chocolatey --limit-output",
        "choco list --local-only --limit-output"
    )

    # Custom installation (no package manager for package managers!)
    installCommands = @(
        'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))'
    )

    # Installation settings
    requiresAdmin = $true
    category = "package-manager"

    # Post-install commands
    postInstallCommands = @(
        "choco feature enable -n allowGlobalConfirmation",
        "choco feature enable -n allowEmptyChecksums",
        "choco feature enable -n useRememberedArgumentsForUpgrades"
    )

    # Test paths
    testPaths = @("$env:ProgramData\chocolatey\bin\choco.exe")
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-Chocolatey {
    param([switch]$Force, [switch]$SkipTest)

    Write-SetupxOutput "`n🍫 Installing Chocolatey Package Manager" $Global:SetupxColors.Magenta

    # Check if already installed first
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-SetupxOutput "✅ Chocolatey is already installed and working!" $Global:SetupxColors.Green
            return $testResult
        }
    }

    # Check administrator privileges
    if (-not (Test-Administrator)) {
        throw "Chocolatey installation requires Administrator privileges"
    }

    Write-SetupxOutput "Installing Chocolatey..." $Global:SetupxColors.Yellow

    try {
        # Set execution policy
        Set-ExecutionPolicy Bypass -Scope Process -Force

        # Enable TLS 1.2
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        # Install Chocolatey
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        Write-SetupxOutput "✅ Chocolatey installed successfully" $Global:SetupxColors.Green

        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Start-Sleep -Seconds 3

        # Configure Chocolatey features
        Write-SetupxOutput "Configuring Chocolatey features..." $Global:SetupxColors.White

        foreach ($command in $ComponentConfig.postInstallCommands) {
            try {
                Invoke-Expression $command
                Write-SetupxOutput "✅ Configured: $command" $Global:SetupxColors.Green
            }
            catch {
                Write-SetupxOutput "⚠️  Could not configure: $command" $Global:SetupxColors.Yellow
            }
        }

        # Verify installation
        $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

        if ($verifyResult.Success) {
            Write-SetupxOutput "✅ Chocolatey installation verified!" $Global:SetupxColors.Green
            Write-SetupxOutput "`n📋 Usage examples:" $Global:SetupxColors.Cyan
            Write-SetupxOutput "  choco search [package]  - Search for packages" $Global:SetupxColors.White
            Write-SetupxOutput "  choco install [package] - Install a package" $Global:SetupxColors.White
            Write-SetupxOutput "  choco upgrade all       - Update all packages" $Global:SetupxColors.White
            Write-SetupxOutput "  choco list --local-only - List installed packages" $Global:SetupxColors.White
        }

        return $verifyResult

    }
    catch {
        $errorResult = [ComponentResult]::new()
        $errorResult.Name = $ComponentConfig.displayName
        $errorResult.Success = $false
        $errorResult.Status = [ComponentStatus]::Unknown
        $errorResult.Message = "Installation failed: $($_.Exception.Message)"

        Write-SetupxOutput "❌ Chocolatey installation failed: $($_.Exception.Message)" $Global:SetupxColors.Red
        return $errorResult
    }
}

function Test-Chocolatey {
    Write-SetupxOutput "`n🧪 Testing Chocolatey Package Manager" $Global:SetupxColors.Cyan

    $result = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result.Success) {
        # Additional Chocolatey specific tests
        try {
            $chocoList = choco list --local-only --limit-output 2>$null
            $packageCount = ($chocoList | Measure-Object).Count
            Write-SetupxOutput "✅ Chocolatey has $packageCount packages installed" $Global:SetupxColors.Green
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Could not count installed packages" $Global:SetupxColors.Yellow
        }

        # Test internet connectivity for package searches
        try {
            $searchTest = choco search git --limit-output --exact 2>$null
            if ($searchTest) {
                Write-SetupxOutput "✅ Package repository is accessible" $Global:SetupxColors.Green
            }
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Package repository may not be accessible" $Global:SetupxColors.Yellow
        }
    }

    return $result
}

function Update-Chocolatey {
    Write-SetupxOutput "`n🔄 Updating Chocolatey Package Manager" $Global:SetupxColors.Cyan

    try {
        choco upgrade chocolatey -y
        if ($LASTEXITCODE -eq 0) {
            Write-SetupxOutput "✅ Chocolatey updated successfully!" $Global:SetupxColors.Green
            return $true
        } else {
            Write-SetupxOutput "⚠️  Chocolatey update completed with warnings" $Global:SetupxColors.Yellow
            return $true
        }
    }
    catch {
        Write-SetupxOutput "❌ Failed to update Chocolatey: $($_.Exception.Message)" $Global:SetupxColors.Red
        return $false
    }
}

# Main execution logic
if ($MyInvocation.InvocationName -ne '.') {
    param(
        [ValidateSet('install', 'test', 'update')]
        [string]$Action = 'install',
        [switch]$Force,
        [switch]$SkipTest
    )

    switch ($Action.ToLower()) {
        'install' { Install-Chocolatey -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-Chocolatey }
        'update' { Update-Chocolatey }
    }
}

# Export functions for module use
Export-ModuleMember -Function Install-Chocolatey, Test-Chocolatey, Update-Chocolatey