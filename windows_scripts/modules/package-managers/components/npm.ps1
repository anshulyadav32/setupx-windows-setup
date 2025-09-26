# npm Component for setupx
# Configures npm (Node Package Manager) for global package management

# Component configuration
$ComponentConfig = @{
    name = "npm"
    displayName = "npm (Global Setup)"
    description = "Node Package Manager global configuration"

    # Executables to test
    executableNames = @("npm.exe", "npm")

    # Version commands
    versionCommands = @("npm --version")

    # Test commands
    testCommands = @(
        "npm --version",
        "npm list -g --depth=0"
    )

    # npm comes with Node.js, so we don't install it separately
    installCommands = @()

    # Installation settings
    requiresAdmin = $false  # npm global config doesn't require admin
    category = "package-manager"

    # Post-install commands (global configuration)
    postInstallCommands = @(
        "npm install -g npm@latest",
        "npm config set fund false",
        "npm config set audit-level moderate"
    )

    # Test paths
    testPaths = @()
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-NPM {
    param([switch]$Force, [switch]$SkipTest)

    Write-SetupxOutput "`n📦 Configuring npm (Node Package Manager)" $Global:SetupxColors.Green

    # Check if npm is available (comes with Node.js)
    if (-not (Get-Command "npm" -ErrorAction SilentlyContinue)) {
        Write-SetupxOutput "❌ npm not found. Please install Node.js first." $Global:SetupxColors.Red
        Write-SetupxOutput "💡 Suggestion: Install the web-development module or Node.js component first." $Global:SetupxColors.Cyan

        $errorResult = [ComponentResult]::new()
        $errorResult.Name = $ComponentConfig.displayName
        $errorResult.Success = $false
        $errorResult.Status = [ComponentStatus]::NotInstalled
        $errorResult.Message = "npm requires Node.js to be installed first"
        return $errorResult
    }

    # Check current status
    if (-not $Force -and -not $SkipTest) {
        $testResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig
        if ($testResult.Success) {
            Write-SetupxOutput "✅ npm is already configured and working!" $Global:SetupxColors.Green
            return $testResult
        }
    }

    Write-SetupxOutput "Configuring npm..." $Global:SetupxColors.Yellow

    try {
        # Update npm to latest version
        Write-SetupxOutput "Updating npm to latest version..." $Global:SetupxColors.White
        npm install -g npm@latest
        Write-SetupxOutput "✅ npm updated to latest version" $Global:SetupxColors.Green

        # Configure npm settings
        Write-SetupxOutput "Configuring npm settings..." $Global:SetupxColors.White

        # Disable funding messages
        npm config set fund false
        Write-SetupxOutput "✅ Disabled funding messages" $Global:SetupxColors.Green

        # Set audit level to moderate
        npm config set audit-level moderate
        Write-SetupxOutput "✅ Set audit level to moderate" $Global:SetupxColors.Green

        # Set progress to false for cleaner output
        npm config set progress false
        Write-SetupxOutput "✅ Disabled progress bars for cleaner output" $Global:SetupxColors.Green

        # Install essential global packages
        Write-SetupxOutput "Installing essential global packages..." $Global:SetupxColors.White

        $essentialPackages = @(
            @{ name = "yarn"; description = "Alternative package manager" },
            @{ name = "pnpm"; description = "Fast, disk space efficient package manager" },
            @{ name = "typescript"; description = "TypeScript compiler" },
            @{ name = "ts-node"; description = "TypeScript execution environment" },
            @{ name = "nodemon"; description = "Development server with auto-restart" },
            @{ name = "npm-check-updates"; description = "Update package.json dependencies" },
            @{ name = "http-server"; description = "Simple HTTP server" },
            @{ name = "live-server"; description = "Development server with live reload" }
        )

        $installedPackages = @()
        foreach ($package in $essentialPackages) {
            try {
                Write-SetupxOutput "Installing $($package.name)..." $Global:SetupxColors.Yellow
                npm install -g $package.name --silent
                Write-SetupxOutput "✅ $($package.name) - $($package.description)" $Global:SetupxColors.Green
                $installedPackages += $package.name
            }
            catch {
                Write-SetupxOutput "⚠️  Failed to install $($package.name)" $Global:SetupxColors.Yellow
            }
        }

        # Verify installation
        $verifyResult = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

        if ($verifyResult.Success) {
            Write-SetupxOutput "✅ npm configuration completed!" $Global:SetupxColors.Green
            Write-SetupxOutput "`n📦 Installed global packages:" $Global:SetupxColors.Cyan
            foreach ($packageName in $installedPackages) {
                Write-SetupxOutput "  • $packageName" $Global:SetupxColors.White
            }

            Write-SetupxOutput "`n📋 Useful npm commands:" $Global:SetupxColors.Cyan
            Write-SetupxOutput "  npm list -g --depth=0        # List global packages" $Global:SetupxColors.White
            Write-SetupxOutput "  npm outdated -g              # Check for outdated global packages" $Global:SetupxColors.White
            Write-SetupxOutput "  npm update -g                # Update all global packages" $Global:SetupxColors.White
            Write-SetupxOutput "  npm config list              # Show npm configuration" $Global:SetupxColors.White
            Write-SetupxOutput "  npm init                     # Initialize new project" $Global:SetupxColors.White
            Write-SetupxOutput "  npm audit                    # Check for vulnerabilities" $Global:SetupxColors.White

            Write-SetupxOutput "`n💡 Alternative package managers:" $Global:SetupxColors.Cyan
            Write-SetupxOutput "  yarn --version               # Yarn by Facebook" $Global:SetupxColors.White
            Write-SetupxOutput "  pnpm --version               # PNPM for fast installs" $Global:SetupxColors.White
        }

        return $verifyResult

    }
    catch {
        $errorResult = [ComponentResult]::new()
        $errorResult.Name = $ComponentConfig.displayName
        $errorResult.Success = $false
        $errorResult.Status = [ComponentStatus]::Unknown
        $errorResult.Message = "Configuration failed: $($_.Exception.Message)"

        Write-SetupxOutput "❌ npm configuration failed: $($_.Exception.Message)" $Global:SetupxColors.Red
        return $errorResult
    }
}

function Test-NPM {
    Write-SetupxOutput "`n🧪 Testing npm Configuration" $Global:SetupxColors.Cyan

    $result = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result.Success) {
        # Additional npm specific tests
        try {
            $globalList = npm list -g --depth=0 --json 2>$null | ConvertFrom-Json
            $packageCount = ($globalList.dependencies | Get-Member -MemberType NoteProperty).Count
            Write-SetupxOutput "✅ $packageCount global packages installed" $Global:SetupxColors.Green
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Could not count global packages" $Global:SetupxColors.Yellow
        }

        # Test registry access
        try {
            $registry = npm config get registry
            Write-SetupxOutput "✅ Registry configured: $registry" $Global:SetupxColors.Green

            # Test registry connectivity
            $testPackage = npm view express version --silent 2>$null
            if ($testPackage) {
                Write-SetupxOutput "✅ Registry is accessible" $Global:SetupxColors.Green
            }
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Registry connectivity test failed" $Global:SetupxColors.Yellow
        }

        # Check for essential packages
        $essentialPackages = @("yarn", "typescript", "nodemon")
        $missingPackages = @()

        foreach ($package in $essentialPackages) {
            if (-not (Get-Command $package -ErrorAction SilentlyContinue)) {
                $missingPackages += $package
            }
        }

        if ($missingPackages.Count -eq 0) {
            Write-SetupxOutput "✅ All essential packages are available" $Global:SetupxColors.Green
        } else {
            Write-SetupxOutput "⚠️  Missing packages: $($missingPackages -join ', ')" $Global:SetupxColors.Yellow
        }

        # Show npm configuration
        try {
            $npmConfig = npm config list --json 2>$null | ConvertFrom-Json
            Write-SetupxOutput "📋 Key configurations:" $Global:SetupxColors.Gray
            if ($npmConfig.fund -eq $false) {
                Write-SetupxOutput "  ✅ Funding messages disabled" $Global:SetupxColors.Gray
            }
            if ($npmConfig.'audit-level') {
                Write-SetupxOutput "  ✅ Audit level: $($npmConfig.'audit-level')" $Global:SetupxColors.Gray
            }
        }
        catch {
            Write-SetupxOutput "ℹ️  Could not display configuration details" $Global:SetupxColors.Gray
        }
    }

    return $result
}

function Update-NPM {
    Write-SetupxOutput "`n🔄 Updating npm and Global Packages" $Global:SetupxColors.Cyan

    try {
        # Update npm itself
        Write-SetupxOutput "Updating npm..." $Global:SetupxColors.White
        npm install -g npm@latest
        Write-SetupxOutput "✅ npm updated!" $Global:SetupxColors.Green

        # Check for outdated global packages
        Write-SetupxOutput "Checking for outdated global packages..." $Global:SetupxColors.White
        $outdated = npm outdated -g --json 2>$null

        if ($outdated) {
            $outdatedPackages = $outdated | ConvertFrom-Json
            if ($outdatedPackages) {
                Write-SetupxOutput "📋 Found outdated packages:" $Global:SetupxColors.Yellow
                $outdatedPackages.PSObject.Properties | ForEach-Object {
                    Write-SetupxOutput "  • $($_.Name): $($_.Value.current) → $($_.Value.latest)" $Global:SetupxColors.Gray
                }

                $updateAll = Read-Host "Do you want to update all global packages? (y/N)"
                if ($updateAll -eq "y" -or $updateAll -eq "Y") {
                    Write-SetupxOutput "Updating all global packages..." $Global:SetupxColors.White
                    npm update -g
                    Write-SetupxOutput "✅ All global packages updated!" $Global:SetupxColors.Green
                }
            } else {
                Write-SetupxOutput "✅ All global packages are up to date" $Global:SetupxColors.Green
            }
        } else {
            Write-SetupxOutput "✅ All global packages are up to date" $Global:SetupxColors.Green
        }

        return $true
    }
    catch {
        Write-SetupxOutput "❌ Failed to update npm: $($_.Exception.Message)" $Global:SetupxColors.Red
        return $false
    }
}

function Get-NPMInfo {
    Write-SetupxOutput "`n📊 npm Information" $Global:SetupxColors.Cyan

    try {
        # Show npm and Node.js versions
        $npmVersion = npm --version
        $nodeVersion = node --version
        Write-SetupxOutput "📦 npm version: $npmVersion" $Global:SetupxColors.White
        Write-SetupxOutput "🟢 Node.js version: $nodeVersion" $Global:SetupxColors.White

        # Show global packages
        Write-SetupxOutput "`n📋 Global packages:" $Global:SetupxColors.White
        $globalList = npm list -g --depth=0 2>$null
        $packages = $globalList -split "`n" | Where-Object { $_ -match '├──|└──' } | ForEach-Object { $_.Trim() -replace '^[├└]── ', '' }

        foreach ($package in $packages | Select-Object -First 10) {
            if ($package.Trim()) {
                Write-SetupxOutput "  • $package" $Global:SetupxColors.Gray
            }
        }

        if ($packages.Count -gt 10) {
            Write-SetupxOutput "  ... and $($packages.Count - 10) more packages" $Global:SetupxColors.Gray
        }

        # Show configuration
        Write-SetupxOutput "`n⚙️ Configuration:" $Global:SetupxColors.White
        $registry = npm config get registry
        $prefix = npm config get prefix
        Write-SetupxOutput "  Registry: $registry" $Global:SetupxColors.Gray
        Write-SetupxOutput "  Global prefix: $prefix" $Global:SetupxColors.Gray

    }
    catch {
        Write-SetupxOutput "⚠️  Could not retrieve npm information" $Global:SetupxColors.Yellow
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
        'install' { Install-NPM -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-NPM }
        'update' { Update-NPM }
        'info' { Get-NPMInfo }
    }
}

# Export functions for module use
Export-ModuleMember -Function Install-NPM, Test-NPM, Update-NPM, Get-NPMInfo