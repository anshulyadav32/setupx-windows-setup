# Fix Flutter Paths - Permanent Setup
# This script adds Flutter and related tools to your system PATH permanently

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Flutter PATH Fix - Permanent Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Get current User PATH
$currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Define paths to add
$pathsToAdd = @(
    "C:\tools\flutter\bin",
    "C:\Android\android-sdk\platform-tools",
    "C:\Android\android-sdk\cmdline-tools\latest\bin",
    "C:\Android\android-sdk\tools",
    "C:\Program Files\Android\Android Studio\jbr\bin"
)

# Check and add each path
$modified = $false
foreach ($pathToAdd in $pathsToAdd) {
    if (Test-Path $pathToAdd) {
        if ($currentUserPath -notlike "*$pathToAdd*") {
            Write-Host "[+] Adding to PATH: $pathToAdd" -ForegroundColor Green
            $currentUserPath = "$currentUserPath;$pathToAdd"
            $modified = $true
        } else {
            Write-Host "[√] Already in PATH: $pathToAdd" -ForegroundColor Gray
        }
    } else {
        Write-Host "[!] Path not found (skipping): $pathToAdd" -ForegroundColor Yellow
    }
}

# Update User PATH if modified
if ($modified) {
    [Environment]::SetEnvironmentVariable("Path", $currentUserPath, "User")
    Write-Host ""
    Write-Host "[SUCCESS] PATH updated permanently!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[INFO] All paths already configured!" -ForegroundColor Cyan
}

# Set ANDROID_HOME
Write-Host ""
Write-Host "[+] Setting ANDROID_HOME..." -ForegroundColor Cyan
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Android\android-sdk", "User")
Write-Host "[√] ANDROID_HOME = C:\Android\android-sdk" -ForegroundColor Green

# Set JAVA_HOME
Write-Host ""
Write-Host "[+] Setting JAVA_HOME..." -ForegroundColor Cyan
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Android\Android Studio\jbr", "User")
Write-Host "[√] JAVA_HOME = C:\Program Files\Android\Android Studio\jbr" -ForegroundColor Green

# Refresh current session
Write-Host ""
Write-Host "[+] Refreshing current session..." -ForegroundColor Cyan
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$env:ANDROID_HOME = "C:\Android\android-sdk"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Testing Flutter Installation" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Test Flutter
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[√] Flutter command works!" -ForegroundColor Green
        Write-Host ""
        flutter --version
    }
} catch {
    Write-Host "[!] Flutter command not working yet - restart terminal" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Close this terminal window" -ForegroundColor White
Write-Host "  2. Open a NEW PowerShell window" -ForegroundColor White
Write-Host "  3. Run: flutter doctor" -ForegroundColor White
Write-Host ""
Write-Host "The 'flutter' command will now work in ALL new terminals!" -ForegroundColor Green
Write-Host ""

