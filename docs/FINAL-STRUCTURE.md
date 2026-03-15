# Final Structure

Current runtime structure:

```text
setupx-windows-setup/
├── src/
│   ├── core/
│   └── config/
│       └── modules/
├── docs/
├── website/
├── setupx.ps1
└── stx.ps1
```

Current shipped modules:
- `package-managers` (`pgkm`)
- `web-development` (`wdev`)
- `ai-development-tools` (`aidve`)
- `common-development` (`codev`)
- `cloud-development` (`cdev`)
- `mobile-development` (`mdev`)
- `data-science` (`dscience`)
- `devops`
- `wsl-linux` (`wsl`)

Examples:

```powershell
setupx ls
setupx install web-development
setupx install web-development nodejs
stx wdev
stx -i pgkm chocolatey
```
