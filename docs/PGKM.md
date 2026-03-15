# Package Managers

Use `setupx` or `stx` after installation.

## Install SetupX

```powershell
iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install.ps1 | iex
```

## Install Core Package Managers

```powershell
setupx pgkm
# or
stx pgkm
# or
setupx install pgkm
```

This installs:
- `chocolatey`
- `scoop`
- `winget`
- `npm`

## Install All Package Managers

```powershell
setupx pgkm all
# or
setupx install pgkm all
```

## List Components

```powershell
setupx list-components pgkm
# or
setupx components pgkm
```

## Install Individual Components

```powershell
setupx install pgkm chocolatey
setupx install pgkm scoop
setupx install pgkm winget
setupx install pgkm npm

# aliases
setupx instal pgkm chocolatey
setupx -i pgkm chocolatey
```

## Test

```powershell
setupx test-module pgkm
setupx test-component pgkm chocolatey
setupx check-status
```
