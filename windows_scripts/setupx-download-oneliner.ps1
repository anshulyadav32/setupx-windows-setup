# SetupX Download One-Liner - Download and run SetupX from anywhere
# This script downloads SetupX scripts and makes them available immediately

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Download-And-Run-SetupX {
    Write-ColorOutput "`nSetupX Download One-Liner" "Cyan"
    Write-ColorOutput "Downloading SetupX scripts to current directory..." "White"
    Write-ColorOutput ""

    $baseUrl = "https://raw.githubusercontent.com/anshulyadav32/setupx-windows-setup/main/windows_scripts/"
    $scripts = @(
        "setupx-main.ps1",
        "setupx-now.ps1", 
        "quick-setupx.ps1",
        "install-setupx-command.ps1"
    )

    foreach ($script in $scripts) {
        try {
            Write-ColorOutput "Downloading $script..." "Yellow"
            $url = $baseUrl + $script
            Invoke-RestMethod -Uri $url -OutFile $script
            Write-ColorOutput "  SUCCESS: $script downloaded" "Green"
        } catch {
            Write-ColorOutput "  ERROR: Failed to download $script - $($_.Exception.Message)" "Red"
        }
    }

    Write-ColorOutput ""
    Write-ColorOutput "SetupX scripts downloaded successfully!" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "Now you can use:" "Cyan"
    Write-ColorOutput "  .\setupx-now.ps1 -h          # Show help" "White"
    Write-ColorOutput "  .\setupx-now.ps1 list        # List modules" "White"
    Write-ColorOutput "  .\setupx-now.ps1 status      # Show status" "White"
    Write-ColorOutput "  .\setupx-now.ps1 menu        # Interactive menu" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Or install as global command:" "Cyan"
    Write-ColorOutput "  .\install-setupx-command.ps1" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Running SetupX now..." "Magenta"
    
    # Run SetupX immediately
    if (Test-Path "setupx-now.ps1") {
        & ".\setupx-now.ps1"
    } else {
        Write-ColorOutput "ERROR: setupx-now.ps1 not found" "Red"
    }
}

Download-And-Run-SetupX
