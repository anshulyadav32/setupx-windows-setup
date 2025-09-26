# SetupX Download - Download SetupX scripts to current directory
# This script downloads the necessary SetupX scripts to the current directory

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Download-SetupXScripts {
    Write-ColorOutput "`nSetupX Download - Getting SetupX scripts..." "Cyan"
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
}

Download-SetupXScripts
