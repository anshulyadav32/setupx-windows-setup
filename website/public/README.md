# SetupX

Set up your Windows dev environment in one command.

SetupX is a modular PowerShell tool for automating installation of package managers, frameworks, and developer tools using a clean JSON-driven workflow.

Automate your Windows dev environment with one command.

[Get Started](#quick-start)
[View on GitHub](https://github.com/anshulyadav-git/setupx-windows-setup)

## Install SetupX

```powershell
iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install.ps1 | iex
```

## Install SetupX + Package Managers

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex
```

## Quick Start

```powershell
setupx help
setupx ls
setupx pgkm
setupx install web-development
setupx install pgkm chocolatey
setupx test-module pgkm
setupx check-status
```

Short alias:

```powershell
stx help
stx -i pgkm chocolatey
stx install web-development nodejs
```

## Command Guide

### List modules and components

```powershell
setupx list
setupx ls
setupx list-modules
setupx components web-development
setupx list-components pgkm
```

### Install modules

```powershell
setupx install pgkm
setupx install pgkm all
setupx install web-development
setupx install common-development
setupx install ai-development-tools
```

### Install components

```powershell
setupx install chocolatey
setupx install nodejs
setupx install pgkm chocolatey
setupx install web-development nodejs
setupx install component chocolatey
setupx install-component pgkm chocolatey
setupx instal pgkm winget
setupx -i web-development yarn
```

### Test and verify

```powershell
setupx status
setupx check-status
setupx test-module pgkm
setupx test-module web-development
setupx test-component pgkm chocolatey
setupx test-component web-development nodejs
```

### Quick setup presets

```powershell
setupx quick-setup full-stack
setupx quick-setup web-dev
setupx quick-setup mobile-dev
setupx quick-setup cloud-dev
setupx quick-setup ai-dev
```

## Package Managers

Default `pgkm` install:

```powershell
setupx pgkm
```

This installs:
- `chocolatey`
- `scoop`
- `winget`
- `npm`

Install the full package-manager set:

```powershell
setupx pgkm all
```

## License

MIT
