# JSON Architecture

SetupX uses JSON module definitions in `src/config/modules/` and a PowerShell command runner in `src/core/`.

## Flow

1. `setupx.ps1` parses the command.
2. The command resolves module aliases such as `wdev` -> `web-development`.
3. Module JSON is loaded from `src/config/modules/`.
4. `src/core/engine.ps1` runs the mapped command.

## Current Module Files

- `package-managers.json`
- `web-development.json`
- `ai-development-tools.json`
- `common-development.json`
- `cloud-development.json`
- `mobile-development.json`
- `data-science.json`
- `devops.json`
- `wsl-linux.json`

## Example Commands

```powershell
setupx ls
setupx components web-development
setupx install pgkm chocolatey
setupx install web-development nodejs
setupx -i web-development yarn
```

## Notes

- `setupx` is the main command.
- `stx` is the short alias.
- `install`, `instal`, and `-i` map to the same install flow.
- The docs should not reference `setupx-new.ps1` or raw `core/<module>/<component>.ps1` URLs.
