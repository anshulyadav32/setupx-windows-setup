# Test Results

This document tracks the current testing approach rather than old point-in-time install output.

## Recommended Checks

```powershell
setupx help
setupx ls
setupx components pgkm
setupx test-module pgkm
setupx test-module web-development
setupx test-component pgkm chocolatey
setupx check-status
```

## Current Notes

- `check-status` may report filesystem-based detection for some tools even when the command is not callable in the current shell.
- The most reliable validation is direct command execution through `test-module`, `test-component`, or the tool executable itself.
- If the installed copy under `C:\tools\setupx` behaves differently from this repository, reinstall SetupX with the latest `install.ps1`.
