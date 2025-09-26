# Node.js Component for setupx
# Installs Node.js with npm and essential global packages

# Component configuration
$ComponentConfig = @{
    name = "nodejs"
    displayName = "Node.js & npm"
    description = "JavaScript runtime with package manager"

    # Executables to test
    executableNames = @("node.exe", "node", "npm.exe", "npm")

    # Version commands
    versionCommands = @("node --version", "npm --version")

    # Test commands
    testCommands = @(
        "node --version",
        "npm --version",
        "node -e `"console.log('Hello World')`""
    )

    # Package manager IDs
    wingetId = "OpenJS.NodeJS"
    chocoId = "nodejs"
    scoopId = "nodejs"

    # Installation settings
    requiresAdmin = $true
    category = "runtime"

    # Post-install commands
    postInstallCommands = @(
        "npm install -g yarn",
        "npm install -g typescript",
        "npm install -g nodemon",
        "npm install -g http-server",
        "npm install -g live-server"
    )

    # Test paths
    testPaths = @()
}

# Import shared functions
$SharedPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. "$SharedPath\shared\component-manager.ps1"

function Install-NodeJS {
    param([switch]$Force, [switch]$SkipTest)

    Write-SetupxOutput "`n🟢 Installing Node.js Component" $Global:SetupxColors.Green

    $result = Install-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig -Force:$Force -SkipTest:$SkipTest

    if ($result.Success) {
        Write-SetupxOutput "✅ Node.js installation completed successfully!" $Global:SetupxColors.Green
        Write-SetupxOutput "`n📋 Installed global packages:" $Global:SetupxColors.Cyan
        Write-SetupxOutput "  • yarn - Alternative package manager" $Global:SetupxColors.White
        Write-SetupxOutput "  • typescript - TypeScript compiler" $Global:SetupxColors.White
        Write-SetupxOutput "  • nodemon - Development server with auto-restart" $Global:SetupxColors.White
        Write-SetupxOutput "  • http-server - Simple HTTP server for testing" $Global:SetupxColors.White
        Write-SetupxOutput "  • live-server - Development server with live reload" $Global:SetupxColors.White
    }

    return $result
}

function Test-NodeJS {
    Write-SetupxOutput "`n🧪 Testing Node.js Component" $Global:SetupxColors.Cyan

    $result = Test-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result.Success) {
        # Additional Node.js specific tests
        try {
            $npmList = npm list -g --depth=0 2>$null
            if ($npmList) {
                Write-SetupxOutput "✅ Global npm packages are accessible" $Global:SetupxColors.Green
            }
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Could not list global npm packages" $Global:SetupxColors.Yellow
        }
    }

    return $result
}

function Update-NodeJS {
    Write-SetupxOutput "`n🔄 Updating Node.js Component" $Global:SetupxColors.Cyan

    $result = Update-Component -ComponentName $ComponentConfig.displayName -ComponentConfig $ComponentConfig

    if ($result) {
        Write-SetupxOutput "✅ Node.js updated successfully!" $Global:SetupxColors.Green

        # Update global packages
        try {
            Write-SetupxOutput "Updating global npm packages..." $Global:SetupxColors.White
            npm update -g
            Write-SetupxOutput "✅ Global packages updated" $Global:SetupxColors.Green
        }
        catch {
            Write-SetupxOutput "⚠️  Warning: Could not update global packages" $Global:SetupxColors.Yellow
        }
    }

    return $result
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
        'install' { Install-NodeJS -Force:$Force -SkipTest:$SkipTest }
        'test' { Test-NodeJS }
        'update' { Update-NodeJS }
    }
}

# Export functions for module use
# Functions are available for use
