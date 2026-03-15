# Installs SetupX (if needed) and then installs Pip via PGKM module.
Set-ExecutionPolicy Bypass -Scope Process -Force

$installerUrl = "https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1"
$installerScript = Invoke-RestMethod -Uri $installerUrl
$installerBlock = [ScriptBlock]::Create($installerScript)
& $installerBlock

setupx install pip

