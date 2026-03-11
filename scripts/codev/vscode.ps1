# Installs SetupX (if needed) and then installs VS Code via CODEV module.
Set-ExecutionPolicy Bypass -Scope Process -Force

$installerUrl = "https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install.ps1"
$installerScript = Invoke-RestMethod -Uri $installerUrl
$installerBlock = [ScriptBlock]::Create($installerScript)
& $installerBlock

sx install vscode
