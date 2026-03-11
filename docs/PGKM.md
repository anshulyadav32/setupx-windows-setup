# PGKM Module Guide

This document explains how to use the `pgkm` alias in `sx` to manage package managers on Windows.

## Quick Start

Install `sx` and all package managers in one line:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex
```

## Core PGKM Commands

```powershell
# Install all package managers
sx pgkm

# List all package managers in the module
sx list-module pgkm

# Install a specific package manager
sx install chocolatey
sx install winget
sx install scoop

# Verify or test a specific manager
sx check chocolatey
sx test scoop

# Test all package managers
sx test-module pgkm
```

## Common Components in PGKM

- chocolatey
- scoop
- winget
- nvm
- nodejs
- npm
- yarn
- pnpm
- bun
- pip
- pipx
- conda
- mamba
- cargo
- go
- composer
- gem
- dotnet-tool
- nuget
- vcpkg

## Commands For Each CMD

Use these patterns for any component name:

```powershell
sx install <component>
sx check <component>
sx test <component>
sx update <component>
sx remove <component>
```

One-liner format for each command (install flow + command in one line):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install <component>
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx check <component>
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx test <component>
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx update <component>
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx remove <component>
```

Ready-to-run install commands for each PGKM component:

```powershell
sx install chocolatey
sx install scoop
sx install winget
sx install nvm
sx install nodejs
sx install npm
sx install yarn
sx install pnpm
sx install bun
sx install pip
sx install pipx
sx install conda
sx install mamba
sx install cargo
sx install go
sx install composer
sx install gem
sx install dotnet-tool
sx install nuget
sx install vcpkg
```

Ready-to-run one-liners for each install command:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install scoop
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install winget
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install nvm
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install nodejs
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install npm
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install yarn
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install pnpm
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install bun
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install pip
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install pipx
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install conda
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install mamba
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install cargo
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install go
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install composer
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install gem
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install dotnet-tool
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install nuget
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex; sx install vcpkg
```

Ready-to-run check commands for each PGKM component:

```powershell
sx check chocolatey
sx check scoop
sx check winget
sx check nvm
sx check nodejs
sx check npm
sx check yarn
sx check pnpm
sx check bun
sx check pip
sx check pipx
sx check conda
sx check mamba
sx check cargo
sx check go
sx check composer
sx check gem
sx check dotnet-tool
sx check nuget
sx check vcpkg
```

Module-level commands:

```powershell
sx list-module pgkm
sx install-module pgkm
sx test-module pgkm
sx pgkm
```

## Troubleshooting

- Run PowerShell as Administrator for tools that require elevated privileges.
- If `sx` is not recognized in a new terminal, restart the terminal and run `sx help`.
- If `winget` checks are skipped on older Windows builds, update Windows App Installer.
- If a manager fails to install due to network restrictions, retry with VPN/proxy settings configured.

## Whole Setup Links

### Start Here

- [README.md](../README.md)
- [docs/README-USAGE.md](README-USAGE.md)

### Install Scripts

- [install.ps1](../install.ps1)
- [install-all-pkgm.ps1](../install-all-pkgm.ps1)
- [sx.ps1](../sx.ps1)
- [setupx.ps1](../setupx.ps1)

### Core Engine

- [src/core/engine.ps1](../src/core/engine.ps1)
- [src/core/json-loader.ps1](../src/core/json-loader.ps1)

### Module Definitions

- [src/config/modules/package-managers.json](../src/config/modules/package-managers.json)
- [src/config/modules/web-development.json](../src/config/modules/web-development.json)
- [src/config/modules/common-development.json](../src/config/modules/common-development.json)
- [src/config/modules/mobile-development.json](../src/config/modules/mobile-development.json)
- [src/config/modules/cloud-development.json](../src/config/modules/cloud-development.json)
- [src/config/modules/ai-development-tools.json](../src/config/modules/ai-development-tools.json)
- [src/config/modules/data-science.json](../src/config/modules/data-science.json)
- [src/config/modules/devops.json](../src/config/modules/devops.json)
- [src/config/modules/wsl-linux.json](../src/config/modules/wsl-linux.json)

### Setup and Architecture Docs

- [SETUP-SUMMARY.md](../SETUP-SUMMARY.md)
- [IMPLEMENTATION_SUMMARY.md](../IMPLEMENTATION_SUMMARY.md)
- [CHANGES_SUMMARY.md](../CHANGES_SUMMARY.md)
- [docs/FINAL-STRUCTURE.md](FINAL-STRUCTURE.md)
- [docs/JSON-ARCHITECTURE.md](JSON-ARCHITECTURE.md)

### Testing

- [__test__/README.md](../__test__/README.md)
- [__test__/run-all-tests.ps1](../__test__/run-all-tests.ps1)
- [__test__/test-all-quick.ps1](../__test__/test-all-quick.ps1)
- [docs/TEST-RESULTS.md](TEST-RESULTS.md)
- [TEST_RESULTS_SUMMARY.md](../TEST_RESULTS_SUMMARY.md)
