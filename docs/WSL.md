# WSL Module Guide

Copy and run exactly (word to word).

## Install All WSL-Linux Components

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install.ps1 | iex; stx wsl
```

## Per Component One-Liner Links

WSL
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/core/wsl/wsl.ps1 | iex
```

Ubuntu
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/core/wsl/ubuntu.ps1 | iex
```

Docker Desktop
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/core/wsl/docker-desktop.ps1 | iex
```


