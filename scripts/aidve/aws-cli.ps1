# Installs SetupX (if needed) and then installs AWS CLI via AIDEV module.
Set-ExecutionPolicy Bypass -Scope Process -Force

$installerUrl = "https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install.ps1"
$installerScript = Invoke-RestMethod -Uri $installerUrl
$installerBlock = [ScriptBlock]::Create($installerScript)
& $installerBlock

sx install aws-cli
