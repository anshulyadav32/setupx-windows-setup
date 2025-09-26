# Scoop Component for setupx
# Installs and configures Scoop package manager

# Component configuration
$ComponentConfig = @{
    name = "scoop"
    displayName = "Scoop"
    description = "Command-line installer for Windows - portable applications"

    # Executables to test
    executableNames = @("scoop.exe", "scoop")

    # Version commands
    versionCommands = @("scoop --version")

    # Test commands
    testCommands = @(
        "scoop --version",
        "scoop search git"
    )

    # Custom installation (no package manager for package managers!)
    installCommands = @(
        'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; iwr -useb get.scoop.sh | iex'
    )

    # Installation settings
    requiresAdmin = $false  # Scoop can install without admin
    category = "package-manager"

    # Post-install commands
    postInstallCommands = @(
        "scoop bucket add extras",
        "scoop bucket add versions",
        "scoop bucket add nonportable"
    )

    # Test paths
    testPaths = @("$env:USERPROFILE\scoop\shims\scoop.cmd")
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-Scoop {
    param([switch]$Force, [switch]$SkipTest)

    Write-SetupxOutput "`n🪣 Installing Scoop Package Manager" $Global:SetupxColors.Blue

    # Check if already installed first
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-SetupxOutput "✅ Scoop is already installed and working!" $Global:SetupxColors.Green
            return $testResult
        }
    }

    Write-SetupxOutput "Installing Scoop..." $Global:SetupxColors.Yellow

    try {
        # Set execution policy for current user
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

        # Install Scoop
        iwr -useb get.scoop.sh | iex

        Write-SetupxOutput "✅ Scoop installed successfully" $Global:SetupxColors.Green

        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Start-Sleep -Seconds 3

        # Add useful buckets
        Write-SetupxOutput "Adding Scoop buckets..." $Global:SetupxColors.White

        $buckets = @(
            @{ name = "extras"; description = "Extra applications and utilities" },
            @{ name = "versions"; description = "Alternative versions of applications" },
            @{ name = "nonportable"; description = "Non-portable applications" },
            @{ name = "java"; description = "Java applications and JDKs" },
            @{ name = "games"; description = "Games and gaming utilities" }
        )

        foreach ($bucket in $buckets) {
            try {
                scoop bucket add $bucket.name
                Write-SetupxOutput "✅ Added bucket '$($bucket.name)' - $($bucket.description)" $Global:SetupxColors.Green
            }
            catch {
                Write-SetupxOutput "⚠️  Could not add bucket '$($bucket.name)'" $Global:SetupxColors.Yellow
            }
        }

        # Verify installation
        $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

        if ($verifyResult.Success) {
            Write-SetupxOutput "✅ Scoop installation verified!" $Global:SetupxColors.Green
            Write-SetupxOutput "`n📋 Usage examples:" $Global:SetupxColors.Cyan
            Write-SetupxOutput "  scoop search <app>      - Search for applications" $Global:SetupxColors.White
            Write-SetupxOutput "  scoop install <app>     - Install an application" $Global:SetupxColors.White
            Write-SetupxOutput "  scoop update *          - Update all applications" $Global:SetupxColors.White
            Write-SetupxOutput "  scoop list              - List installed applications" $Global:SetupxColors.White
            Write-SetupxOutput "  scoop bucket list       - List available buckets" $Global:SetupxColors.White
            Write-SetupxOutput "  scoop cleanup *         - Remove old versions" $Global:SetupxColors.White

            Write-SetupxOutput "`n🪣 Available buckets:" $Global:SetupxColors.Cyan
            Write-SetupxOutput "  • extras - Additional apps (recommended)" $Global:SetupxColors.White
            Write-SetupxOutput "  • versions - Alternative app versions" $Global:SetupxColors.White
            Write-SetupxOutput "  • nonportable - Traditional installers" $Global:SetupxColors.White
            Write-SetupxOutput "  • java - Java development tools" $Global:SetupxColors.White
        }

        return $verifyResult

    }
    catch {
        $errorResult = [ComponentResult]::new()
        $errorResult.Name = $ComponentConfig.displayName
        $errorResult.Success = $false
        $errorResult.Status = [ComponentStatus]::Unknown
        $errorResult.Message = "Installation failed: $($_.Exception.Message)"

        Write-SetupxOutput "❌ Scoop installation failed: $($_.Exception.Message)" $Global:SetupxColors.Red
        return $errorResult
    }
}

function Test-Scoop {
    Write-SetupxOutput "`n🧪 Testing Scoop Package Manager" $Global:SetupxColors.Cyan

    $result = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result.Success) {
        # Additional Scoop specific tests
        try {
            $scoopList = scoop list 2>$null
            $appCount = ($scoopList | Where-Object { $_ -match '^\s*\w+' } | Measure-Object).Count
            Write-SetupxOutput "✅ Scoop has $appCount applications installed" $Global:SetupxColors.Green
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Could not count installed applications" $Global:SetupxColors.Yellow
        }

        # Test bucket access
        try {
            $buckets = scoop bucket list 2>$null
            $bucketCount = ($buckets | Measure-Object).Count
            Write-SetupxOutput "✅ $bucketCount buckets are configured" $Global:SetupxColors.Green
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Could not list buckets" $Global:SetupxColors.Yellow
        }

        # Test search functionality
        try {
            $searchTest = scoop search git --brief 2>$null
            if ($searchTest) {
                Write-SetupxOutput "✅ Package search is working" $Global:SetupxColors.Green
            }
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Package search may not be accessible" $Global:SetupxColors.Yellow
        }

        # Check Scoop directory
        $scoopDir = "$env:USERPROFILE\scoop"
        if (Test-Path $scoopDir) {
            $size = (Get-ChildItem $scoopDir -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
            Write-SetupxOutput "✅ Scoop directory: $scoopDir ($([math]::Round($size, 1)) MB)" $Global:SetupxColors.Green
        }
    }

    return $result
}

function Update-Scoop {
    Write-SetupxOutput "`n🔄 Updating Scoop Package Manager" $Global:SetupxColors.Cyan

    try {
        # Update Scoop itself
        scoop update
        Write-SetupxOutput "✅ Scoop updated successfully!" $Global:SetupxColors.Green

        # Update all installed applications
        $updateApps = Read-Host "Do you want to update all installed applications? (y/N)"
        if ($updateApps -eq "y" -or $updateApps -eq "Y") {
            Write-SetupxOutput "Updating all applications..." $Global:SetupxColors.White
            scoop update *
            Write-SetupxOutput "✅ All applications updated!" $Global:SetupxColors.Green

            # Clean up old versions
            $cleanup = Read-Host "Do you want to clean up old versions? (y/N)"
            if ($cleanup -eq "y" -or $cleanup -eq "Y") {
                scoop cleanup *
                Write-SetupxOutput "✅ Cleanup completed!" $Global:SetupxColors.Green
            }
        }

        return $true
    }
    catch {
        Write-SetupxOutput "❌ Failed to update Scoop: $($_.Exception.Message)" $Global:SetupxColors.Red
        return $false
    }
}

function Get-ScoopInfo {
    Write-SetupxOutput "`n📊 Scoop Information" $Global:SetupxColors.Cyan

    try {
        $scoopDir = "$env:USERPROFILE\scoop"
        if (Test-Path $scoopDir) {
            Write-SetupxOutput "📁 Installation: $scoopDir" $Global:SetupxColors.White

            # Show installed apps
            $apps = scoop list 2>$null | Where-Object { $_ -match '^\s*\w+' }
            Write-SetupxOutput "📦 Installed applications: $($apps.Count)" $Global:SetupxColors.White

            # Show buckets
            $buckets = scoop bucket list 2>$null
            Write-SetupxOutput "🪣 Configured buckets: $($buckets.Count)" $Global:SetupxColors.White

            if ($buckets.Count -gt 0) {
                Write-SetupxOutput "  Buckets:" $Global:SetupxColors.Gray
                foreach ($bucket in $buckets) {
                    Write-SetupxOutput "    • $bucket" $Global:SetupxColors.Gray
                }
            }

            # Show directory size
            $size = (Get-ChildItem $scoopDir -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
            Write-SetupxOutput "💾 Directory size: $([math]::Round($size, 1)) MB" $Global:SetupxColors.White
        }
    }
    catch {
        Write-SetupxOutput "⚠️  Could not retrieve Scoop information" $Global:SetupxColors.Yellow
    }
}

# Main execution logic
if ($MyInvocation.InvocationName -ne '.') {
    param(
        [ValidateSet('install', 'test', 'update', 'info')]
        [string]$Action = 'install',
        [switch]$Force,
        [switch]$SkipTest
    )

    switch ($Action.ToLower()) {
        'install' { Install-Scoop -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-Scoop }
        'update' { Update-Scoop }
        'info' { Get-ScoopInfo }
    }
}

# Export functions for module use
# Functions are available for use
