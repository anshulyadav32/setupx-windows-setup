# Check if Chocolatey is installed
if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Please install Chocolatey first."
    exit 1
}

# Uninstall both package variants to support Server and Desktop installs
choco uninstall docker-engine docker-desktop -y --no-progress

if ($LASTEXITCODE -eq 0) {
    Write-Host "Docker packages have been successfully uninstalled."
} else {
    Write-Host "There was an issue uninstalling one or more Docker packages."
    Write-Host "Check C:\ProgramData\chocolatey\logs\chocolatey.log"
    exit 1
}