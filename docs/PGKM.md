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

Ready-to-run one-liners for each component script:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/choco.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/scoop.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/winget.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/nvm.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/nodejs.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/npm.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/yarn.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/pnpm.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/bun.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/pip.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/pipx.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/conda.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/mamba.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/cargo.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/go.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/composer.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/gem.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/dotnet-tool.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/nuget.ps1 | iex
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/vcpkg.ps1 | iex
```

## Direct One-Liner Link For Every Component

Copy one block at a time.

Chocolatey
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/choco.ps1 | iex
```

Scoop
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/scoop.ps1 | iex
```

Winget
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/winget.ps1 | iex
```

NVM
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/nvm.ps1 | iex
```

Node.js
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/nodejs.ps1 | iex
```

NPM
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/npm.ps1 | iex
```

Yarn
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/yarn.ps1 | iex
```

PNPM
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/pnpm.ps1 | iex
```

Bun
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/bun.ps1 | iex
```

Pip
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/pip.ps1 | iex
```

Pipx
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/pipx.ps1 | iex
```

Conda
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/conda.ps1 | iex
```

Mamba
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/mamba.ps1 | iex
```

Cargo
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/cargo.ps1 | iex
```

Go
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/go.ps1 | iex
```

Composer
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/composer.ps1 | iex
```

Gem
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/gem.ps1 | iex
```

Dotnet Tool
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/dotnet-tool.ps1 | iex
```

Nuget
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/nuget.ps1 | iex
```

Vcpkg
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/scripts/pgkm/vcpkg.ps1 | iex
```

## Component Script Files

You can also run a dedicated script per component from `scripts/pgkm`.

Run any script like this:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\pgkm\scoop.ps1
```

Available component scripts:

- [scripts/pgkm/choco.ps1](../scripts/pgkm/choco.ps1)
- [scripts/pgkm/chocolatey.ps1](../scripts/pgkm/chocolatey.ps1)
- [scripts/pgkm/scoop.ps1](../scripts/pgkm/scoop.ps1)
- [scripts/pgkm/winget.ps1](../scripts/pgkm/winget.ps1)
- [scripts/pgkm/nvm.ps1](../scripts/pgkm/nvm.ps1)
- [scripts/pgkm/nodejs.ps1](../scripts/pgkm/nodejs.ps1)
- [scripts/pgkm/npm.ps1](../scripts/pgkm/npm.ps1)
- [scripts/pgkm/yarn.ps1](../scripts/pgkm/yarn.ps1)
- [scripts/pgkm/pnpm.ps1](../scripts/pgkm/pnpm.ps1)
- [scripts/pgkm/bun.ps1](../scripts/pgkm/bun.ps1)
- [scripts/pgkm/pip.ps1](../scripts/pgkm/pip.ps1)
- [scripts/pgkm/pipx.ps1](../scripts/pgkm/pipx.ps1)
- [scripts/pgkm/conda.ps1](../scripts/pgkm/conda.ps1)
- [scripts/pgkm/mamba.ps1](../scripts/pgkm/mamba.ps1)
- [scripts/pgkm/cargo.ps1](../scripts/pgkm/cargo.ps1)
- [scripts/pgkm/go.ps1](../scripts/pgkm/go.ps1)
- [scripts/pgkm/composer.ps1](../scripts/pgkm/composer.ps1)
- [scripts/pgkm/gem.ps1](../scripts/pgkm/gem.ps1)
- [scripts/pgkm/dotnet-tool.ps1](../scripts/pgkm/dotnet-tool.ps1)
- [scripts/pgkm/nuget.ps1](../scripts/pgkm/nuget.ps1)
- [scripts/pgkm/vcpkg.ps1](../scripts/pgkm/vcpkg.ps1)

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

### PGKM Component Scripts

- [scripts/pgkm/choco.ps1](../scripts/pgkm/choco.ps1)
- [scripts/pgkm/chocolatey.ps1](../scripts/pgkm/chocolatey.ps1)
- [scripts/pgkm/scoop.ps1](../scripts/pgkm/scoop.ps1)
- [scripts/pgkm/winget.ps1](../scripts/pgkm/winget.ps1)
- [scripts/pgkm/nvm.ps1](../scripts/pgkm/nvm.ps1)
- [scripts/pgkm/nodejs.ps1](../scripts/pgkm/nodejs.ps1)
- [scripts/pgkm/npm.ps1](../scripts/pgkm/npm.ps1)
- [scripts/pgkm/yarn.ps1](../scripts/pgkm/yarn.ps1)
- [scripts/pgkm/pnpm.ps1](../scripts/pgkm/pnpm.ps1)
- [scripts/pgkm/bun.ps1](../scripts/pgkm/bun.ps1)
- [scripts/pgkm/pip.ps1](../scripts/pgkm/pip.ps1)
- [scripts/pgkm/pipx.ps1](../scripts/pgkm/pipx.ps1)
- [scripts/pgkm/conda.ps1](../scripts/pgkm/conda.ps1)
- [scripts/pgkm/mamba.ps1](../scripts/pgkm/mamba.ps1)
- [scripts/pgkm/cargo.ps1](../scripts/pgkm/cargo.ps1)
- [scripts/pgkm/go.ps1](../scripts/pgkm/go.ps1)
- [scripts/pgkm/composer.ps1](../scripts/pgkm/composer.ps1)
- [scripts/pgkm/gem.ps1](../scripts/pgkm/gem.ps1)
- [scripts/pgkm/dotnet-tool.ps1](../scripts/pgkm/dotnet-tool.ps1)
- [scripts/pgkm/nuget.ps1](../scripts/pgkm/nuget.ps1)
- [scripts/pgkm/vcpkg.ps1](../scripts/pgkm/vcpkg.ps1)

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
