# Flutter Installation Script
# Installs Flutter SDK for cross-platform development

#Requires -RunAsAdministrator

param([switch]$Verbose)

$ErrorActionPreference = "Continue"
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

function Write-ColorOutput($Message, $Color = "White") {
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Flutter {
    Write-ColorOutput "`n=== Installing Flutter SDK ===" $Cyan

    if (-not (Test-Administrator)) {
        Write-ColorOutput "✗ This script requires Administrator privileges." $Red
        exit 1
    }

    # Check if already installed
    if (Get-Command "flutter" -ErrorAction SilentlyContinue) {
        $version = flutter --version | Select-Object -First 1
        Write-ColorOutput "✓ Flutter is already installed: $version" $Green

        $update = Read-Host "Do you want to update Flutter? (y/n)"
        if ($update -eq "y" -or $update -eq "Y") {
            Write-ColorOutput "Updating Flutter..." $Yellow
            flutter upgrade
            return
        } else {
            return
        }
    }

    Write-ColorOutput "Installing Flutter SDK..." $Yellow

    # Try WinGet first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        try {
            winget install --id Google.Flutter --silent --accept-source-agreements --accept-package-agreements
            Write-ColorOutput "✓ Flutter installed via WinGet" $Green
        } catch {
            Write-ColorOutput "! WinGet installation failed, trying Chocolatey..." $Yellow

            # Fallback to Chocolatey
            if (Get-Command "choco" -ErrorAction SilentlyContinue) {
                choco install flutter -y
                Write-ColorOutput "✓ Flutter installed via Chocolatey" $Green
            } else {
                Write-ColorOutput "! Package manager installation failed, trying manual installation..." $Yellow
                Install-FlutterManual
                return
            }
        }
    } elseif (Get-Command "choco" -ErrorAction SilentlyContinue) {
        choco install flutter -y
        Write-ColorOutput "✓ Flutter installed via Chocolatey" $Green
    } else {
        Write-ColorOutput "! No package manager available, trying manual installation..." $Yellow
        Install-FlutterManual
        return
    }

    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # Wait a moment for installation to complete
    Start-Sleep -Seconds 5

    # Verify installation and run flutter doctor
    Verify-FlutterInstallation
}

function Install-FlutterManual {
    Write-ColorOutput "Performing manual Flutter installation..." $Yellow

    $flutterPath = "C:\flutter"
    $flutterZip = "$env:TEMP\flutter_windows.zip"

    try {
        # Download Flutter
        Write-ColorOutput "Downloading Flutter SDK..." $Yellow
        $url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip"
        Invoke-WebRequest -Uri $url -OutFile $flutterZip

        # Extract to C:\flutter
        Write-ColorOutput "Extracting Flutter SDK..." $Yellow
        if (Test-Path $flutterPath) {
            Remove-Item $flutterPath -Recurse -Force
        }
        Expand-Archive -Path $flutterZip -DestinationPath "C:\" -Force

        # Add to PATH
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*$flutterPath\bin*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterPath\bin", "Machine")
            Write-ColorOutput "✓ Flutter added to system PATH" $Green
        }

        # Clean up
        Remove-Item $flutterZip -Force

        Write-ColorOutput "✓ Flutter installed manually" $Green

    } catch {
        Write-ColorOutput "✗ Manual installation failed: $($_.Exception.Message)" $Red
        return
    }

    # Refresh environment for current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Verify-FlutterInstallation {
    Write-ColorOutput "`n=== Verifying Flutter Installation ===" $Cyan

    if (Get-Command "flutter" -ErrorAction SilentlyContinue) {
        $version = flutter --version | Select-Object -First 1
        Write-ColorOutput "✓ Flutter installed successfully: $version" $Green

        # Run flutter doctor
        Write-ColorOutput "`n=== Running Flutter Doctor ===" $Cyan
        flutter doctor

        Write-ColorOutput "`n=== Installation Complete ===" $Green
        Write-ColorOutput "Flutter SDK has been installed successfully!" $Green

        Write-ColorOutput "`n=== Next Steps ===" $Cyan
        Write-ColorOutput "1. Install Android Studio for Android development" $White
        Write-ColorOutput "2. Install Xcode for iOS development (Mac only)" $White
        Write-ColorOutput "3. Install Visual Studio Code with Flutter extension" $White
        Write-ColorOutput "4. Run 'flutter doctor' to check for any missing dependencies" $White

        Write-ColorOutput "`n=== Useful Flutter Commands ===" $Cyan
        Write-ColorOutput "• flutter create my_app - Create new Flutter project" $White
        Write-ColorOutput "• flutter run - Run the app" $White
        Write-ColorOutput "• flutter build apk - Build Android APK" $White
        Write-ColorOutput "• flutter build web - Build for web" $White
        Write-ColorOutput "• flutter upgrade - Update Flutter" $White

    } else {
        Write-ColorOutput "✗ Flutter installation verification failed" $Red
        Write-ColorOutput "Please restart your terminal and try again." $Yellow
    }
}

Install-Flutter
Write-ColorOutput "`nPress any key to exit..." $Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")